const pptxgen = require("pptxgenjs");

const pres = new pptxgen();

// A1 poster size: 23.39" x 33.07"
pres.defineLayout({ name: "POSTER_A1", width: 23.39, height: 33.07 });
pres.layout = "POSTER_A1";

const slide = pres.addSlide();
slide.background = { color: "0D1117" };

// ── Colors ──────────────────────────────────────────────────────────────────
const C = {
  bg:      "0D1117",
  card:    "161B22",
  card2:   "1A2233",
  border:  "30363D",
  orange:  "FF8C42",  // 다람쥐
  red:     "E63946",  // 개미
  yellow:  "FFD166",  // 사자
  brown:   "A0522D",  // 비버
  teal:    "06B6D4",
  purple:  "7C3AED",
  green:   "10B981",
  white:   "FFFFFF",
  gray:    "8B949E",
  gray2:   "C9D1D9",
};

// ── Helpers ─────────────────────────────────────────────────────────────────
const M = 0.55;           // left/right margin
const W = 23.39 - M * 2; // usable width

function pill(x, y, w, h, color, label, fontSize = 16) {
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, rectRadius: h / 2,
    fill: { color },
    line: { color, width: 0 },
  });
  slide.addText(label, {
    x, y, w, h,
    fontSize, bold: true, color: C.white,
    align: "center", valign: "middle", margin: 0,
  });
}

function card(x, y, w, h, borderColor) {
  slide.addShape(pres.shapes.RECTANGLE, {
    x, y, w, h,
    fill: { color: C.card },
    line: { color: borderColor || C.border, width: 1.5 },
    shadow: { type: "outer", blur: 10, offset: 3, angle: 135, color: "000000", opacity: 0.4 },
  });
  // left accent bar
  if (borderColor) {
    slide.addShape(pres.shapes.RECTANGLE, {
      x, y: y + 0.12, w: 0.10, h: h - 0.24,
      fill: { color: borderColor },
      line: { color: borderColor, width: 0 },
    });
  }
}

// ────────────────────────────────────────────────────────────────────────────
// HEADER
// ────────────────────────────────────────────────────────────────────────────

// Background gradient effect via stacked shapes
slide.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 0, w: 23.39, h: 5.0,
  fill: { color: "0F1721" },
  line: { color: "0F1721", width: 0 },
});
slide.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: 4.6, w: 23.39, h: 0.5,
  fill: { color: "0D1117" },
  line: { color: "0D1117", width: 0 },
});

// Decorative accent circles
slide.addShape(pres.shapes.OVAL, {
  x: -1.5, y: -1.5, w: 5, h: 5,
  fill: { color: C.orange, transparency: 85 },
  line: { color: C.orange, width: 0 },
});
slide.addShape(pres.shapes.OVAL, {
  x: 19, y: -1, w: 4, h: 4,
  fill: { color: C.teal, transparency: 85 },
  line: { color: C.teal, width: 0 },
});

// Main title
slide.addText([
  { text: "소리  ", options: { color: C.yellow, bold: true } },
  { text: "(Sori)", options: { color: C.gray2, bold: false } },
], {
  x: M, y: 0.5, w: W, h: 1.8,
  fontSize: 80, bold: true, align: "center", valign: "middle",
  fontFace: "Malgun Gothic",
});

// Sparkle emoji decoration text
slide.addText("✦", { x: 12.8, y: 0.4, w: 1, h: 0.8, fontSize: 36, color: C.teal, align: "left" });
slide.addText("✦", { x: 9.2, y: 1.3, w: 0.7, h: 0.6, fontSize: 20, color: C.orange, align: "left" });

// Subtitle
slide.addText("결제 1초 전, 당신을 말리는 능동형 AI 잔소리 가계부", {
  x: M, y: 2.3, w: W, h: 0.9,
  fontSize: 30, bold: false, align: "center", color: C.gray2,
  fontFace: "Malgun Gothic",
});

// Divider line
slide.addShape(pres.shapes.RECTANGLE, {
  x: M + 2, y: 3.3, w: W - 4, h: 0.02,
  fill: { color: C.border },
  line: { color: C.border, width: 0 },
});

// Team info
slide.addText("2026. 05. 기초 캡스톤 디자인   |   지도교수: 윤익준   |   팀원: 김동원, 송종민, 안준용, 최정호, 신동건", {
  x: M, y: 3.55, w: W, h: 0.7,
  fontSize: 16, align: "center", color: C.gray,
  fontFace: "Malgun Gothic",
});

// ────────────────────────────────────────────────────────────────────────────
// SECTION 1: 제안 서비스 배경
// ────────────────────────────────────────────────────────────────────────────

const s1y = 4.6;
pill(M, s1y, 3.2, 0.55, C.red, "제안 서비스 배경", 17);

// Wide card
card(M, s1y + 0.7, W, 3.8, C.red);

// Problem recognition row
slide.addText("🔴  문제 인식", {
  x: M + 0.35, y: s1y + 0.85, w: 5, h: 0.5,
  fontSize: 19, bold: true, color: C.red, fontFace: "Malgun Gothic",
});
slide.addText("2030 청년층의 욜로(YOLO) 문화 확산 및 충동구매 심화", {
  x: M + 0.35, y: s1y + 1.35, w: W - 0.7, h: 0.55,
  fontSize: 18, color: C.gray2, fontFace: "Malgun Gothic",
});

// Arrow down
slide.addShape(pres.shapes.RECTANGLE, {
  x: M + 0.8, y: s1y + 1.92, w: 0.02, h: 0.3,
  fill: { color: C.border }, line: { color: C.border, width: 0 },
});
slide.addText("↓", { x: M + 0.35, y: s1y + 1.88, w: 1, h: 0.4, fontSize: 22, color: C.gray, align: "center" });

slide.addText("🟡  기존의 한계", {
  x: M + 0.35, y: s1y + 2.25, w: 5, h: 0.5,
  fontSize: 19, bold: true, color: C.yellow, fontFace: "Malgun Gothic",
});
slide.addText("기존 가계부 앱들은 돈을 다 쓴 '후'에만 기록을 제공함", {
  x: M + 0.35, y: s1y + 2.75, w: W - 0.7, h: 0.55,
  fontSize: 18, color: C.gray2, fontFace: "Malgun Gothic",
});

slide.addText("↓", { x: M + 0.35, y: s1y + 3.22, w: 1, h: 0.4, fontSize: 22, color: C.gray, align: "center" });

slide.addText("🟢  결론", {
  x: M + 0.35, y: s1y + 3.6, w: 5, h: 0.45,
  fontSize: 19, bold: true, color: C.green, fontFace: "Malgun Gothic",
});
slide.addText("사후 기록만으로는 실질적인 과소비 통제 및 소비 습관 교정이 불가능함", {
  x: M + 0.35, y: s1y + 4.05, w: W - 0.7, h: 0.5,
  fontSize: 17, bold: true, color: C.white, fontFace: "Malgun Gothic",
});

// ────────────────────────────────────────────────────────────────────────────
// SECTION 2: 목표 및 필요성
// ────────────────────────────────────────────────────────────────────────────

const s2y = s1y + 5.0;
pill(M, s2y, 3.2, 0.55, C.orange, "목표 및 필요성", 17);

const boxW = (W - 0.4) / 3;
const boxH = 4.8;
const box2y = s2y + 0.7;

const s2boxes = [
  { x: M,              color: C.orange, label: "진짜 필요한 가계부는?",
    body: ["단순 소비 기록으로는", "행동 변화 유도 불가!", "", "결제 직전의 물리적 개입이 필요"] },
  { x: M + boxW + 0.2, color: C.yellow, label: "우리가 원하는 건?",
    body: ["획일화된 알림이 아닌,", "내 성향에 딱 맞는 조언", "", "사후 반성이 아닌 '사전 차단'"] },
  { x: M + (boxW + 0.2)*2, color: C.teal, label: "그래서 Sori는...",
    body: ["내 성향(MBTI) 기반", "4가지 페르소나 배정", "GPS 기반 위험 지역", "실시간 감지 및 즉각 개입", "뼈 때리는 AI 잔소리로", "충동구매 억제"] },
];

s2boxes.forEach(b => {
  // Card bg
  slide.addShape(pres.shapes.RECTANGLE, {
    x: b.x, y: box2y, w: boxW, h: boxH,
    fill: { color: C.card2 },
    line: { color: b.color, width: 2 },
    shadow: { type: "outer", blur: 12, offset: 4, angle: 135, color: "000000", opacity: 0.5 },
  });
  // Top accent bar
  slide.addShape(pres.shapes.RECTANGLE, {
    x: b.x, y: box2y, w: boxW, h: 0.15,
    fill: { color: b.color },
    line: { color: b.color, width: 0 },
  });
  // Header label
  slide.addText(b.label, {
    x: b.x + 0.2, y: box2y + 0.2, w: boxW - 0.4, h: 0.75,
    fontSize: 21, bold: true, color: b.color,
    fontFace: "Malgun Gothic", align: "center",
  });
  // Divider
  slide.addShape(pres.shapes.RECTANGLE, {
    x: b.x + 0.4, y: box2y + 1.0, w: boxW - 0.8, h: 0.03,
    fill: { color: C.border }, line: { color: C.border, width: 0 },
  });
  // Body text
  slide.addText(b.body.join("\n"), {
    x: b.x + 0.25, y: box2y + 1.15, w: boxW - 0.5, h: boxH - 1.3,
    fontSize: 18, color: C.gray2, fontFace: "Malgun Gothic",
    align: "center", valign: "top",
  });
});

// ────────────────────────────────────────────────────────────────────────────
// SECTION 3: 시스템 설계 및 알고리즘 시나리오
// ────────────────────────────────────────────────────────────────────────────

const s3y = s2y + boxH + 1.2;
pill(M, s3y, 4.0, 0.55, C.purple, "시스템 설계 및 알고리즘 시나리오", 17);

const flowCard = { x: M, y: s3y + 0.7, w: W, h: 5.5 };
slide.addShape(pres.shapes.RECTANGLE, {
  x: flowCard.x, y: flowCard.y, w: flowCard.w, h: flowCard.h,
  fill: { color: C.card },
  line: { color: C.purple, width: 1.5 },
  shadow: { type: "outer", blur: 10, offset: 3, angle: 135, color: "000000", opacity: 0.4 },
});
slide.addShape(pres.shapes.RECTANGLE, {
  x: flowCard.x, y: flowCard.y, w: 0.10, h: flowCard.h - 0.24 + 0.12,
  fill: { color: C.purple }, line: { color: C.purple, width: 0 },
});

// Flow header labels
const flowLabels = ["입력", "전처리", "분석", "출력"];
const flowColors = [C.orange, C.yellow, C.teal, C.green];
const fcW = (W - 0.5) / 4;
const fcY = s3y + 0.9;

flowLabels.forEach((lbl, i) => {
  const fx = M + 0.25 + i * fcW;
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: fx, y: fcY, w: fcW - 0.3, h: 0.55, rectRadius: 0.15,
    fill: { color: flowColors[i], transparency: 20 },
    line: { color: flowColors[i], width: 0 },
  });
  slide.addText(lbl, {
    x: fx, y: fcY, w: fcW - 0.3, h: 0.55,
    fontSize: 20, bold: true, color: C.white, align: "center", valign: "middle",
    fontFace: "Malgun Gothic", margin: 0,
  });
  if (i < flowLabels.length - 1) {
    slide.addText("➔", {
      x: fx + fcW - 0.3, y: fcY, w: 0.3, h: 0.55,
      fontSize: 20, color: C.gray, align: "center", valign: "middle",
    });
  }
});

// Flow steps
const steps = [
  { icon: "📍", title: "위험 지역 진입", desc: "Background GPS 감지", color: C.orange },
  { icon: "🖥️", title: "서버 중계", desc: "FastAPI 백엔드 서버 호출", color: C.yellow },
  { icon: "🗄️", title: "RAG 데이터 추출", desc: "Firestore 잔여 예산\n및 지출 패턴 조회", color: C.teal },
  { icon: "🔔", title: "AI 알림 전송", desc: "GPT-4o-mini 성향별\n맞춤 잔소리 생성\n및 푸시 알림", color: C.green },
];

steps.forEach((s, i) => {
  const sx = M + 0.25 + i * fcW;
  const sy = s3y + 1.7;
  const sh = 3.9;

  // Step box
  slide.addShape(pres.shapes.RECTANGLE, {
    x: sx, y: sy, w: fcW - 0.3, h: sh,
    fill: { color: "0F1721" },
    line: { color: s.color, width: 1.5 },
  });

  // Icon
  slide.addText(s.icon, {
    x: sx, y: sy + 0.3, w: fcW - 0.3, h: 0.9,
    fontSize: 38, align: "center",
  });

  // Title
  slide.addText(s.title, {
    x: sx + 0.1, y: sy + 1.25, w: fcW - 0.5, h: 0.65,
    fontSize: 19, bold: true, color: s.color, align: "center",
    fontFace: "Malgun Gothic",
  });

  // Desc
  slide.addText(s.desc, {
    x: sx + 0.1, y: sy + 1.95, w: fcW - 0.5, h: 1.7,
    fontSize: 16, color: C.gray2, align: "center",
    fontFace: "Malgun Gothic",
  });

  // Arrow between steps
  if (i < steps.length - 1) {
    slide.addText("➔", {
      x: sx + fcW - 0.3, y: sy + sh / 2 - 0.3, w: 0.3, h: 0.6,
      fontSize: 22, color: C.gray, align: "center", valign: "middle",
    });
  }
});

// ────────────────────────────────────────────────────────────────────────────
// SECTION 4: 웹/앱 구현 내용
// ────────────────────────────────────────────────────────────────────────────

const s4y = s3y + flowCard.h + 1.2;
pill(M, s4y, 3.0, 0.55, C.teal, "웹 / 앱 구현 내용", 17);

const scrW = (W - 0.4) / 2;
const scrH = 6.5;
const scrY = s4y + 0.75;

const screens = [
  { x: M,          color: C.orange, title: "실행 화면 1 · 홈 화면",
    tag: "실시간 GPS 방어막",
    desc: "위험 지역 진입 감지 및 즉각적 개입\n충동구매 예방 알림 즉시 발송" },
  { x: M + scrW + 0.4, color: C.teal,   title: "실행 화면 2 · AI 채팅 화면",
    tag: "AI 맞춤형 채팅",
    desc: "소비 성향을 저격하는\n실시간 잔소리 로그 표시" },
];

screens.forEach(sc => {
  // Card
  slide.addShape(pres.shapes.RECTANGLE, {
    x: sc.x, y: scrY, w: scrW, h: scrH,
    fill: { color: C.card },
    line: { color: sc.color, width: 2 },
    shadow: { type: "outer", blur: 12, offset: 4, angle: 135, color: "000000", opacity: 0.5 },
  });
  // Top accent
  slide.addShape(pres.shapes.RECTANGLE, {
    x: sc.x, y: scrY, w: scrW, h: 0.18,
    fill: { color: sc.color }, line: { color: sc.color, width: 0 },
  });
  // Title
  slide.addText(sc.title, {
    x: sc.x + 0.3, y: scrY + 0.25, w: scrW - 0.6, h: 0.7,
    fontSize: 22, bold: true, color: sc.color, fontFace: "Malgun Gothic",
  });

  // Phone mockup placeholder
  const phoneX = sc.x + scrW / 2 - 1.6;
  const phoneY = scrY + 1.1;
  const phoneW = 3.2;
  const phoneH = 4.2;

  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: phoneX, y: phoneY, w: phoneW, h: phoneH, rectRadius: 0.25,
    fill: { color: "1C2333" },
    line: { color: C.border, width: 2 },
  });
  // Phone notch
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: phoneX + phoneW / 2 - 0.5, y: phoneY + 0.08, w: 1.0, h: 0.2, rectRadius: 0.1,
    fill: { color: C.border }, line: { color: C.border, width: 0 },
  });
  // Screen area
  slide.addShape(pres.shapes.RECTANGLE, {
    x: phoneX + 0.15, y: phoneY + 0.38, w: phoneW - 0.3, h: phoneH - 0.55,
    fill: { color: "0D1117" }, line: { color: "0D1117", width: 0 },
  });
  slide.addText("[ 앱 화면 ]", {
    x: phoneX + 0.15, y: phoneY + 0.38, w: phoneW - 0.3, h: phoneH - 0.55,
    fontSize: 18, color: C.gray, align: "center", valign: "middle",
    fontFace: "Malgun Gothic",
  });

  // Tag + desc
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: sc.x + 0.3, y: scrY + 5.4, w: scrW - 0.6, h: 0.4, rectRadius: 0.12,
    fill: { color: sc.color, transparency: 75 },
    line: { color: sc.color, width: 1 },
  });
  slide.addText(sc.tag, {
    x: sc.x + 0.3, y: scrY + 5.4, w: scrW - 0.6, h: 0.4,
    fontSize: 15, bold: true, color: sc.color, align: "center", valign: "middle",
    fontFace: "Malgun Gothic", margin: 0,
  });
  slide.addText(sc.desc, {
    x: sc.x + 0.3, y: scrY + 5.85, w: scrW - 0.6, h: 0.8,
    fontSize: 15, color: C.gray2, align: "center", fontFace: "Malgun Gothic",
  });
});

// Tech stack
const tsY = scrY + scrH + 0.15;
const stackItems = [
  { name: "Flutter", color: C.teal },
  { name: "Firebase", color: C.orange },
  { name: "FastAPI", color: C.green },
  { name: "GPT-4o-mini", color: C.purple },
];
const tsW = (W - 0.6) / 4;

slide.addText("기술 스택", {
  x: M, y: tsY, w: 2.5, h: 0.4,
  fontSize: 15, bold: true, color: C.gray, fontFace: "Malgun Gothic",
});

stackItems.forEach((ts, i) => {
  const tsx = M + i * (tsW + 0.2);
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, {
    x: tsx, y: tsY + 0.45, w: tsW, h: 0.5, rectRadius: 0.12,
    fill: { color: ts.color, transparency: 80 },
    line: { color: ts.color, width: 1.5 },
  });
  slide.addText(ts.name, {
    x: tsx, y: tsY + 0.45, w: tsW, h: 0.5,
    fontSize: 16, bold: true, color: ts.color, align: "center", valign: "middle",
    fontFace: "Malgun Gothic", margin: 0,
  });
});

// ────────────────────────────────────────────────────────────────────────────
// SECTION 5: 결론 및 기대 효과
// ────────────────────────────────────────────────────────────────────────────

const s5y = tsY + 1.3;
pill(M, s5y, 3.0, 0.55, C.green, "결론 및 기대 효과", 17);

const concCards = [
  { icon: "🛡️", title: "즉각적 개입", desc: "결제 직전 GPS 감지로\n충동구매 억제 및 방어", color: C.orange },
  { icon: "💰", title: "소비 습관 교정", desc: "AI 성향별 맞춤 잔소리로\n올바른 소비 패턴 형성", color: C.yellow },
  { icon: "🤖", title: "주머니 속 금융 치료사", desc: "언제 어디서나 함께하는\n개인 재무 AI 파트너", color: C.teal },
];

const conW = (W - 0.4) / 3;
const conH = 3.2;
const conY = s5y + 0.75;

concCards.forEach((cc, i) => {
  const cx = M + i * (conW + 0.2);
  slide.addShape(pres.shapes.RECTANGLE, {
    x: cx, y: conY, w: conW, h: conH,
    fill: { color: C.card },
    line: { color: cc.color, width: 1.5 },
    shadow: { type: "outer", blur: 8, offset: 3, angle: 135, color: "000000", opacity: 0.4 },
  });
  slide.addShape(pres.shapes.RECTANGLE, {
    x: cx, y: conY, w: conW, h: 0.12,
    fill: { color: cc.color }, line: { color: cc.color, width: 0 },
  });
  slide.addText(cc.icon, {
    x: cx, y: conY + 0.2, w: conW, h: 0.9,
    fontSize: 40, align: "center",
  });
  slide.addText(cc.title, {
    x: cx + 0.2, y: conY + 1.15, w: conW - 0.4, h: 0.65,
    fontSize: 20, bold: true, color: cc.color, align: "center",
    fontFace: "Malgun Gothic",
  });
  slide.addText(cc.desc, {
    x: cx + 0.2, y: conY + 1.85, w: conW - 0.4, h: 1.2,
    fontSize: 17, color: C.gray2, align: "center", fontFace: "Malgun Gothic",
  });
});

// ────────────────────────────────────────────────────────────────────────────
// FOOTER
// ────────────────────────────────────────────────────────────────────────────

const footY = conY + conH + 0.4;
slide.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: footY, w: 23.39, h: 1.6,
  fill: { color: "0A0E14" },
  line: { color: "0A0E14", width: 0 },
});
slide.addShape(pres.shapes.RECTANGLE, {
  x: 0, y: footY, w: 23.39, h: 0.03,
  fill: { color: C.border }, line: { color: C.border, width: 0 },
});

// Left logo text
slide.addText([
  { text: "KGU  ", options: { bold: true, color: C.orange, fontSize: 22 } },
  { text: "경기대학교 | AI컴퓨터공학부", options: { color: C.gray2, fontSize: 16 } },
], {
  x: M, y: footY + 0.35, w: 8, h: 0.8,
  fontFace: "Malgun Gothic",
});

// Right logo text
slide.addText([
  { text: "KGU  ", options: { bold: true, color: C.teal, fontSize: 22 } },
  { text: "경기대학교 | 소프트웨어중심대학사업단", options: { color: C.gray2, fontSize: 16 } },
], {
  x: 23.39 - M - 9, y: footY + 0.35, w: 9, h: 0.8,
  fontFace: "Malgun Gothic", align: "right",
});

// Save
pres.writeFile({ fileName: "C:\\WalletSaver\\Sori_Capstone_Poster.pptx" })
  .then(() => console.log("✅ Poster saved: C:\\WalletSaver\\Sori_Capstone_Poster.pptx"))
  .catch(e => console.error("❌ Error:", e));
