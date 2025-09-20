import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

export const plan = onRequest({ region: "asia-northeast1" }, async (req, res) => {
  // CORS (開発用): Flutter Web dev サーバからのクロスオリジンを許可
  const allowOrigin = "*"; // Day2以降、本番では限定推奨
  res.setHeader("Access-Control-Allow-Origin", allowOrigin);
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ error: "Method Not Allowed" });
    return;
  }
  try {
    // Day1: Hello World 応答（固定JSON）。Day2でVertex呼び出しに置換
    logger.info("/api/plan hello world");
    res.status(200).json({
      plan: [
        { id: "s1", startOffsetMin: 0, stayMin: 40, reason: "雛形応答" },
        { id: "s2", startOffsetMin: 50, stayMin: 40, reason: "雛形応答" }
      ],
      notes: "hello"
    });
  } catch (e: any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
});


