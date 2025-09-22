import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { buildPrompt, OUTPUT_SCHEMA } from "./prompt.js";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Optional: Vertex AI（環境が整っているときのみ使用）
let maybeVertex: any = null;
try {
  // Lazy import to avoid emulator issues when credentials are missing
  const mod = await import("@google-cloud/vertexai");
  maybeVertex = mod;
} catch {}

type InputBody = {
  origin?: { lat: number; lng: number };
  durationHours?: number;
  keywords?: string[];
  includePoi?: boolean;
};

type Spot = {
  id: string;
  name: string;
  prefecture: string;
  lat: number;
  lng: number;
  tags: string[];
  seasons: string[];
};

const REGION = process.env.FUNCTIONS_REGION || "asia-northeast1";
const PROJECT_ID = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT || process.env.FIREBASE_CONFIG && (() => {
  try { return JSON.parse(process.env.FIREBASE_CONFIG as string).projectId as string; } catch { return undefined; }
})() || "";
const VERTEX_MODEL = process.env.VERTEX_MODEL || "gemini-1.5-flash";
const USE_VERTEX = process.env.USE_VERTEX === "1";

function toRad(d: number) { return (d * Math.PI) / 180; }
function haversineMeters(a: {lat:number;lng:number}, b: {lat:number;lng:number}) {
  const R = 6371000;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const sa = Math.sin(dLat/2)**2 + Math.cos(toRad(a.lat))*Math.cos(toRad(b.lat))*Math.sin(dLng/2)**2;
  return 2 * R * Math.asin(Math.sqrt(sa));
}

async function loadSpots(): Promise<Spot[]> {
  // 実行時は lib/plan.js からの相対で ../data/spots.json を参照
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const primary = path.join(__dirname, "../data/spots.json");
  try {
    const json = await readFile(primary, "utf-8");
    return JSON.parse(json) as Spot[];
  } catch (e) {
    // 開発中に src 配下を参照したいケースのフォールバック
    const fallback = path.join(__dirname, "../src/data/spots.json");
    const json = await readFile(fallback, "utf-8");
    return JSON.parse(json) as Spot[];
  }
}

function preprocess(spots: Spot[], origin: {lat:number;lng:number}, keywords: string[], includePoi: boolean): Spot[] {
  let filtered = spots;
  if (keywords && keywords.length > 0) {
    const kw = new Set(keywords.map(k => k.toLowerCase()));
    filtered = filtered.filter(s => s.tags.some(t => kw.has(t.toLowerCase())) || s.name && [...kw].some(k => s.name.toLowerCase().includes(k)));
  }
  if (!includePoi) {
    filtered = filtered.filter(s => !s.tags.includes("poi"));
  }
  // 距離ソートし、上位をサブセットに
  const withDist = filtered.map(s => ({ s, d: haversineMeters(origin, {lat:s.lat, lng:s.lng}) }));
  withDist.sort((a,b) => a.d - b.d);
  // コスト最適化: モデル入力の候補を最大12件に圧縮
  return withDist.slice(0, Math.min(12, withDist.length)).map(x => x.s);
}

function fallbackPlan(candidates: Spot[], origin: {lat:number;lng:number}, durationHours: number) {
  const maxStops = Math.min(4, candidates.length);
  const chosen = candidates.slice(0, maxStops);
  const plan = chosen.map((c, idx) => ({
    id: c.id,
    startOffsetMin: idx * Math.floor((durationHours*60) / Math.max(1, maxStops)),
    stayMin: 40,
    reason: `距離が近く、季節(${c.seasons.join("/")})や体験価値（${c.tags.join(",")})が合致`
  }));
  return { plan, notes: "fallback" };
}

export const plan = onRequest({ region: REGION }, async (req, res) => {
  // CORS (開発用)
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  if (req.method === "OPTIONS") { res.status(204).send(""); return; }
  if (req.method !== "POST") { res.status(405).json({ error: "Method Not Allowed" }); return; }

  try {
    const body = (req.body || {}) as InputBody;
    const origin = body.origin ?? { lat: 37.9161, lng: 139.0364 };
    const durationHours = body.durationHours ?? 4;
    const keywords = Array.isArray(body.keywords) ? body.keywords : [];
    const includePoi = body.includePoi ?? true;

    const spots = await loadSpots();
    const subset = preprocess(spots, origin, keywords, includePoi);

    // Vertex AI（有効時のみ）
    if (USE_VERTEX && maybeVertex && PROJECT_ID) {
      try {
        const { VertexAI } = maybeVertex as any;
        const vertex = new VertexAI({ project: PROJECT_ID, location: REGION });
        const model = vertex.getGenerativeModel({ model: VERTEX_MODEL });
        const prompt = buildPrompt({ origin, durationHours, keywords, includePoi, candidates: subset.map(s => ({ id:s.id, name:s.name, lat:s.lat, lng:s.lng, tags:s.tags, seasons:s.seasons })) });
        const request = {
          contents: [{ role: "user", parts: [{ text: prompt }] }],
          generationConfig: {
            responseMimeType: "application/json",
            temperature: 0,
            topP: 0,
            topK: 1,
            candidateCount: 1,
            maxOutputTokens: 1024,
          },
        } as any;
        const resp = await model.generateContent(request);
        const text = resp?.response?.candidates?.[0]?.content?.parts?.[0]?.text || resp?.response?.text || "";
        const parsed = JSON.parse(text);
        if (parsed && Array.isArray(parsed.plan) && typeof parsed.notes === "string") {
          // 安全化: stayMin等の型整形
          parsed.plan = parsed.plan.map((it: any, idx: number) => ({
            id: String(it.id ?? subset[idx % subset.length]?.id ?? `s${idx+1}`),
            startOffsetMin: Number.isFinite(it.startOffsetMin) ? Math.floor(it.startOffsetMin) : idx * 45,
            stayMin: Number.isFinite(it.stayMin) ? Math.floor(it.stayMin) : 40,
            reason: String(it.reason ?? "AI提案")
          }));
          res.status(200).json(parsed);
          return;
        }
        logger.warn("Vertex応答のJSON検証に失敗。フォールバックに切替");
      } catch (ve: any) {
        logger.warn(`Vertex呼び出し失敗。フォールバック使用: ${ve?.message || ve}`);
      }
    }

    // フォールバック
    const fb = fallbackPlan(subset, origin, durationHours);
    res.status(200).json(fb);
  } catch (e: any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
});


