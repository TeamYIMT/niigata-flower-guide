export const OUTPUT_SCHEMA = {
  plan: [
    {
      id: "",
      startOffsetMin: 0,
      stayMin: 40,
      reason: ""
    }
  ],
  notes: ""
};

export const OUTPUT_SCHEMA_STR = JSON.stringify(OUTPUT_SCHEMA);

export type MiniSpot = {
  id: string;
  name: string;
  lat: number;
  lng: number;
  tags: string[];
  seasons: string[];
};

export function buildPrompt(params: {
  origin: { lat: number; lng: number };
  durationHours: number;
  keywords: string[];
  includePoi: boolean;
  candidates: MiniSpot[];
}) {
  const { origin, durationHours, keywords, includePoi, candidates } = params;
  const candidatesJson = JSON.stringify(candidates);
  const lines: string[] = [];
  lines.push(
    "あなたは新潟の観光・花スポットの旅程プランナーです。",
    "次の制約を厳守してJSONのみを出力してください（説明文は禁止）。",
    "- 出力は厳密に次のスキーマとすること: " + OUTPUT_SCHEMA_STR,
    "- plan配列の要素数は3〜6件",
    "- stayMinは各40〜90の範囲",
    "- reasonには必ず『季節:〜』『距離:〜』『体験価値:〜』の3点を含め、日本語で簡潔に",
    "- 並び順は移動の順序（最初が出発直後）",
    "- JSON以外（前後の説明/コードブロック/改行装飾等）は出力禁止",
  );
  lines.push("入力条件:");
  lines.push(
    JSON.stringify({
      origin,
      durationHours,
      keywords,
      includePoi,
    })
  );
  lines.push("候補スポット（必要十分なサブセット）:");
  lines.push(candidatesJson);
  lines.push("これらを用いて上記スキーマのJSONのみ出力してください。");
  return lines.join("\n");
}


