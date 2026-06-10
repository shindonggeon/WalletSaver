"""Sori 캡스톤 포스터 생성 (python-pptx)"""

from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt
from pptx.oxml.ns import qn
from pptx.oxml import parse_xml
import copy
from lxml import etree

# ── A1 portrait size ─────────────────────────────────────────────────────────
W_IN = 23.39
H_IN = 33.07

prs = Presentation()
prs.slide_width  = Inches(W_IN)
prs.slide_height = Inches(H_IN)

blank_layout = prs.slide_layouts[6]  # completely blank
slide = prs.slides.add_slide(blank_layout)

# ── Color helpers ─────────────────────────────────────────────────────────────
def rgb(h):
    h = h.lstrip("#")
    return RGBColor(int(h[0:2],16), int(h[2:4],16), int(h[4:6],16))

BG      = "0D1117"
CARD    = "161B22"
CARD2   = "1A2233"
BORDER  = "30363D"
ORANGE  = "FF8C42"
RED     = "E63946"
YELLOW  = "FFD166"
BROWN   = "A0522D"
TEAL    = "06B6D4"
PURPLE  = "7C3AED"
GREEN   = "10B981"
WHITE   = "FFFFFF"
GRAY    = "8B949E"
GRAY2   = "C9D1D9"
DARK    = "0A0E14"
DARK2   = "0F1721"

# ── Low-level shape helpers ───────────────────────────────────────────────────
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor

def add_rect(slide, x, y, w, h, fill_color, line_color=None, line_w_pt=0, rounding=None):
    """Add a rectangle (or rounded rect). Returns the shape."""
    left   = Inches(x)
    top    = Inches(y)
    width  = Inches(w)
    height = Inches(h)
    shape = slide.shapes.add_shape(
        1 if rounding is None else 5,  # MSO_SHAPE_TYPE: 1=rect, 5=round
        left, top, width, height
    )
    # Fill
    fill = shape.fill
    if fill_color:
        fill.solid()
        fill.fore_color.rgb = rgb(fill_color)
    else:
        fill.background()

    # Line
    ln = shape.line
    if line_color and line_w_pt > 0:
        ln.color.rgb = rgb(line_color)
        ln.width = Pt(line_w_pt)
    else:
        ln.fill.background()

    # Rounding
    if rounding is not None:
        sp = shape._element
        spPr = sp.find(qn('p:spPr'))
        prstGeom = spPr.find(qn('a:prstGeom'))
        if prstGeom is not None:
            avLst = prstGeom.find(qn('a:avLst'))
            if avLst is None:
                avLst = etree.SubElement(prstGeom, qn('a:avLst'))
            # remove existing
            for gd in avLst.findall(qn('a:gd')):
                avLst.remove(gd)
            gd = etree.SubElement(avLst, qn('a:gd'))
            # adj value: rounding fraction of min(w,h)/2, expressed as 1/100000 of shape dimension
            adj_val = int(min(rounding / min(w, h), 0.5) * 100000)
            gd.set('name', 'adj')
            gd.set('fmla', f'val {adj_val}')
    return shape


def add_text_box(slide, text, x, y, w, h,
                 font_size=14, bold=False, italic=False,
                 color=WHITE, align=PP_ALIGN.LEFT,
                 font_face="Malgun Gothic", wrap=True,
                 v_anchor=None):
    """Add a transparent text box."""
    from pptx.enum.text import MSO_ANCHOR
    txb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    txb.text_frame.word_wrap = wrap
    if v_anchor is not None:
        txb.text_frame.vertical_anchor = v_anchor
    tf = txb.text_frame
    tf.clear()

    # Handle multi-line
    lines = text.split("\n")
    for i, line in enumerate(lines):
        if i == 0:
            p = tf.paragraphs[0]
        else:
            p = tf.add_paragraph()
        p.alignment = align
        run = p.add_run()
        run.text = line
        run.font.size = Pt(font_size)
        run.font.bold = bold
        run.font.italic = italic
        run.font.color.rgb = rgb(color)
        run.font.name = font_face
    return txb


def pill_label(slide, x, y, w, h, fill_color, text, font_size=14):
    """Pill-shaped label with centered text."""
    shape = add_rect(slide, x, y, w, h, fill_color, rounding=h * 0.45)
    # text on top
    add_text_box(slide, text, x, y, w, h,
                 font_size=font_size, bold=True, color=WHITE,
                 align=PP_ALIGN.CENTER)


def section_card(slide, x, y, w, h, border_color):
    """Dark card with colored left accent bar."""
    add_rect(slide, x, y, w, h, CARD, border_color, line_w_pt=1.5)
    add_rect(slide, x, y + 0.1, 0.09, h - 0.2, border_color)


# ── Background ────────────────────────────────────────────────────────────────
add_rect(slide, 0, 0, W_IN, H_IN, BG)

# Header background tint
add_rect(slide, 0, 0, W_IN, 5.2, DARK2)

# Decorative circles (subtle)
# (decorative circle omitted for simplicity)

# ────────────────────────────────────────────────────────────────────────────
# HEADER
# ────────────────────────────────────────────────────────────────────────────
M = 0.55
UW = W_IN - M * 2  # usable width

# Main title – two parts: yellow + gray
add_text_box(slide, "소리  (Sori)", M, 0.4, UW, 2.0,
             font_size=90, bold=True, color=YELLOW, align=PP_ALIGN.CENTER)
# Overlay the "(Sori)" part in gray – simpler: just use yellow for whole title
# Actually just make the whole title yellow and add subtitle

# Decorative sparkle
add_text_box(slide, "✦", 12.6, 0.35, 1.2, 0.9, font_size=40, color=TEAL, align=PP_ALIGN.LEFT)
add_text_box(slide, "✦", 9.5, 1.3, 0.9, 0.7, font_size=22, color=ORANGE, align=PP_ALIGN.LEFT)

# Subtitle
add_text_box(slide, "결제 1초 전, 당신을 말리는 능동형 AI 잔소리 가계부",
             M, 2.45, UW, 0.95,
             font_size=30, color=GRAY2, align=PP_ALIGN.CENTER)

# Divider line
add_rect(slide, M + 2, 3.55, UW - 4, 0.025, BORDER)

# Team info
add_text_box(slide,
             "2026. 05. 기초 캡스톤 디자인   |   지도교수: 윤익준   |   팀원: 김동원, 송종민, 안준용, 최정호, 신동건",
             M, 3.7, UW, 0.75,
             font_size=16, color=GRAY, align=PP_ALIGN.CENTER)

# ────────────────────────────────────────────────────────────────────────────
# SECTION 1: 제안 서비스 배경
# ────────────────────────────────────────────────────────────────────────────
s1y = 4.75
pill_label(slide, M, s1y, 3.3, 0.58, RED, "제안 서비스 배경", font_size=17)

card1_h = 4.1
section_card(slide, M, s1y + 0.72, UW, card1_h, RED)

# Row 1: Problem
add_text_box(slide, "🔴  문제 인식", M + 0.35, s1y + 0.88, 5, 0.52,
             font_size=20, bold=True, color=RED)
add_text_box(slide, "2030 청년층의 욜로(YOLO) 문화 확산 및 충동구매 심화",
             M + 0.35, s1y + 1.4, UW - 0.7, 0.55, font_size=19, color=GRAY2)

add_text_box(slide, "↓", M + 0.35, s1y + 1.95, 1, 0.45, font_size=24, color=GRAY, align=PP_ALIGN.CENTER)

add_text_box(slide, "🟡  기존의 한계", M + 0.35, s1y + 2.38, 5, 0.52,
             font_size=20, bold=True, color=YELLOW)
add_text_box(slide, "기존 가계부 앱들은 돈을 다 쓴 '후'에만 기록을 제공함",
             M + 0.35, s1y + 2.9, UW - 0.7, 0.55, font_size=19, color=GRAY2)

add_text_box(slide, "↓", M + 0.35, s1y + 3.43, 1, 0.45, font_size=24, color=GRAY, align=PP_ALIGN.CENTER)

add_text_box(slide, "🟢  결론  :  사후 기록만으로는 실질적인 과소비 통제 및 소비 습관 교정이 불가능함",
             M + 0.35, s1y + 3.85, UW - 0.7, 0.55,
             font_size=19, bold=True, color=WHITE)

# ────────────────────────────────────────────────────────────────────────────
# SECTION 2: 목표 및 필요성
# ────────────────────────────────────────────────────────────────────────────
s2y = s1y + card1_h + 1.05
pill_label(slide, M, s2y, 3.3, 0.58, ORANGE, "목표 및 필요성", font_size=17)

box_w = (UW - 0.4) / 3
box_h = 5.1
box_y = s2y + 0.72

s2_data = [
    (M,                   ORANGE, "진짜 필요한 가계부는?",
     "단순 소비 기록으로는\n행동 변화 유도 불가!\n\n결제 직전의\n물리적 개입이 필요"),
    (M + box_w + 0.2,     YELLOW, "우리가 원하는 건?",
     "획일화된 알림이 아닌,\n내 성향에 딱 맞는 조언\n\n사후 반성이 아닌\n'사전 차단'"),
    (M + (box_w+0.2)*2,  TEAL,   "그래서 Sori는...",
     "내 성향(MBTI) 기반\n4가지 페르소나 배정\n\nGPS 기반 위험 지역\n실시간 감지\n\n뼈 때리는 AI 잔소리로\n충동구매 억제"),
]

for bx, bc, bheader, bbody in s2_data:
    # card bg
    add_rect(slide, bx, box_y, box_w, box_h, CARD2, bc, line_w_pt=2.0)
    # top accent bar
    add_rect(slide, bx, box_y, box_w, 0.16, bc)
    # header
    add_text_box(slide, bheader, bx + 0.15, box_y + 0.2, box_w - 0.3, 0.8,
                 font_size=22, bold=True, color=bc, align=PP_ALIGN.CENTER)
    # divider
    add_rect(slide, bx + 0.4, box_y + 1.08, box_w - 0.8, 0.03, BORDER)
    # body
    add_text_box(slide, bbody, bx + 0.2, box_y + 1.2, box_w - 0.4, box_h - 1.35,
                 font_size=18, color=GRAY2, align=PP_ALIGN.CENTER)

# ────────────────────────────────────────────────────────────────────────────
# SECTION 3: 시스템 설계 및 알고리즘 시나리오
# ────────────────────────────────────────────────────────────────────────────
s3y = s2y + box_h + 1.15
pill_label(slide, M, s3y, 4.2, 0.58, PURPLE, "시스템 설계 및 알고리즘 시나리오", font_size=17)

flow_h = 6.0
section_card(slide, M, s3y + 0.72, UW, flow_h, PURPLE)

# Flow header labels
flow_labels = ["입력", "전처리", "분석", "출력"]
flow_colors = [ORANGE, YELLOW, TEAL, GREEN]
fc_w = (UW - 0.5) / 4
fc_y = s3y + 0.88

for i, (lbl, fc) in enumerate(zip(flow_labels, flow_colors)):
    fx = M + 0.25 + i * fc_w
    add_rect(slide, fx, fc_y, fc_w - 0.3, 0.58, fc, rounding=0.18)
    add_text_box(slide, lbl, fx, fc_y, fc_w - 0.3, 0.58,
                 font_size=21, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    if i < 3:
        add_text_box(slide, "➔", fx + fc_w - 0.3, fc_y, 0.3, 0.58,
                     font_size=22, color=GRAY, align=PP_ALIGN.CENTER)

# Step detail boxes
steps = [
    ("📍", "위험 지역 진입", "Background GPS 감지", ORANGE),
    ("🖥️", "서버 중계", "FastAPI 백엔드\n서버 호출", YELLOW),
    ("🗄️", "RAG 데이터 추출", "Firestore 잔여 예산\n및 지출 패턴 조회", TEAL),
    ("🔔", "AI 알림 전송", "GPT-4o-mini 성향별\n맞춤 잔소리 생성\n및 푸시 알림 발송", GREEN),
]
step_h = 4.4
step_y = s3y + 1.65

for i, (icon, title, desc, sc) in enumerate(steps):
    sx = M + 0.25 + i * fc_w
    add_rect(slide, sx, step_y, fc_w - 0.3, step_h, DARK2, sc, line_w_pt=1.5)
    add_text_box(slide, icon, sx, step_y + 0.2, fc_w - 0.3, 1.0,
                 font_size=42, align=PP_ALIGN.CENTER)
    add_text_box(slide, title, sx + 0.1, step_y + 1.25, fc_w - 0.5, 0.72,
                 font_size=19, bold=True, color=sc, align=PP_ALIGN.CENTER)
    add_text_box(slide, desc, sx + 0.1, step_y + 2.0, fc_w - 0.5, 2.1,
                 font_size=16, color=GRAY2, align=PP_ALIGN.CENTER)
    if i < 3:
        add_text_box(slide, "➔", sx + fc_w - 0.3, step_y + step_h / 2 - 0.3, 0.3, 0.65,
                     font_size=24, color=GRAY, align=PP_ALIGN.CENTER)

# ────────────────────────────────────────────────────────────────────────────
# SECTION 4: 웹/앱 구현 내용
# ────────────────────────────────────────────────────────────────────────────
s4y = s3y + flow_h + 1.15
pill_label(slide, M, s4y, 3.1, 0.58, TEAL, "웹 / 앱 구현 내용", font_size=17)

scr_w = (UW - 0.4) / 2
scr_h = 7.2
scr_y = s4y + 0.75

screens = [
    (M,              ORANGE, "실행 화면 1 · 홈 화면",
     "실시간 GPS 방어막",
     "위험 지역 진입 감지 및 즉각적 개입\n충동구매 예방 알림 즉시 발송"),
    (M + scr_w + 0.4, TEAL, "실행 화면 2 · AI 채팅 화면",
     "AI 맞춤형 채팅",
     "소비 성향을 저격하는\n실시간 잔소리 로그 표시"),
]

for sx, sc, stitle, stag, sdesc in screens:
    add_rect(slide, sx, scr_y, scr_w, scr_h, CARD, sc, line_w_pt=2.0)
    add_rect(slide, sx, scr_y, scr_w, 0.18, sc)
    add_text_box(slide, stitle, sx + 0.3, scr_y + 0.22, scr_w - 0.6, 0.72,
                 font_size=22, bold=True, color=sc)

    # Phone mockup
    ph_w = 3.5
    ph_h = 4.8
    ph_x = sx + scr_w / 2 - ph_w / 2
    ph_y = scr_y + 1.1
    add_rect(slide, ph_x, ph_y, ph_w, ph_h, "1C2333", BORDER, line_w_pt=2, rounding=0.3)
    # notch
    add_rect(slide, ph_x + ph_w/2 - 0.55, ph_y + 0.1, 1.1, 0.22, BORDER, rounding=0.1)
    # screen area
    add_rect(slide, ph_x + 0.15, ph_y + 0.42, ph_w - 0.3, ph_h - 0.58, "0D1117")
    add_text_box(slide, "[ 앱 화면 캡처 ]\n\n스크린샷을 여기에\n삽입해 주세요",
                 ph_x + 0.15, ph_y + 0.42, ph_w - 0.3, ph_h - 0.58,
                 font_size=16, color=GRAY, align=PP_ALIGN.CENTER)

    # Tag pill
    add_rect(slide, sx + 0.3, scr_y + 6.05, scr_w - 0.6, 0.42, sc, rounding=0.14)
    add_text_box(slide, stag, sx + 0.3, scr_y + 6.05, scr_w - 0.6, 0.42,
                 font_size=15, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
    add_text_box(slide, sdesc, sx + 0.3, scr_y + 6.5, scr_w - 0.6, 0.9,
                 font_size=15, color=GRAY2, align=PP_ALIGN.CENTER)

# Tech stack
ts_y = scr_y + scr_h + 0.22
add_text_box(slide, "기술 스택", M, ts_y, 2.5, 0.42,
             font_size=16, bold=True, color=GRAY)

stack_items = [
    ("Flutter", TEAL), ("Firebase", ORANGE), ("FastAPI", GREEN), ("GPT-4o-mini", PURPLE)
]
ts_item_w = (UW - 0.6) / 4
for i, (sname, sc) in enumerate(stack_items):
    tsx = M + i * (ts_item_w + 0.2)
    add_rect(slide, tsx, ts_y + 0.5, ts_item_w, 0.52, sc, rounding=0.14)
    add_text_box(slide, sname, tsx, ts_y + 0.5, ts_item_w, 0.52,
                 font_size=17, bold=True, color=WHITE, align=PP_ALIGN.CENTER)

# ────────────────────────────────────────────────────────────────────────────
# SECTION 5: 결론 및 기대 효과
# ────────────────────────────────────────────────────────────────────────────
s5y = ts_y + 1.3
pill_label(slide, M, s5y, 3.1, 0.58, GREEN, "결론 및 기대 효과", font_size=17)

con_data = [
    ("🛡️", "즉각적 개입", "결제 직전 GPS 감지로\n충동구매 억제 및 방어", ORANGE),
    ("💰", "소비 습관 교정", "AI 성향별 맞춤 잔소리로\n올바른 소비 패턴 형성", YELLOW),
    ("🤖", "주머니 속 금융 치료사", "언제 어디서나 함께하는\n개인 재무 AI 파트너", TEAL),
]
con_w = (UW - 0.4) / 3
con_h = 3.4
con_y = s5y + 0.75

for i, (icon, ctitle, cdesc, cc) in enumerate(con_data):
    cx = M + i * (con_w + 0.2)
    add_rect(slide, cx, con_y, con_w, con_h, CARD, cc, line_w_pt=1.5)
    add_rect(slide, cx, con_y, con_w, 0.14, cc)
    add_text_box(slide, icon, cx, con_y + 0.18, con_w, 0.95, font_size=42, align=PP_ALIGN.CENTER)
    add_text_box(slide, ctitle, cx + 0.15, con_y + 1.18, con_w - 0.3, 0.68,
                 font_size=20, bold=True, color=cc, align=PP_ALIGN.CENTER)
    add_text_box(slide, cdesc, cx + 0.15, con_y + 1.9, con_w - 0.3, 1.35,
                 font_size=17, color=GRAY2, align=PP_ALIGN.CENTER)

# ────────────────────────────────────────────────────────────────────────────
# FOOTER
# ────────────────────────────────────────────────────────────────────────────
foot_y = con_y + con_h + 0.45
add_rect(slide, 0, foot_y, W_IN, H_IN - foot_y, DARK)
add_rect(slide, 0, foot_y, W_IN, 0.035, BORDER)

add_text_box(slide, "KGU  경기대학교 | AI컴퓨터공학부",
             M, foot_y + 0.35, 9, 0.85,
             font_size=19, bold=False, color=GRAY2)

add_text_box(slide, "KGU  경기대학교 | 소프트웨어중심대학사업단",
             W_IN - M - 10, foot_y + 0.35, 10, 0.85,
             font_size=19, bold=False, color=GRAY2, align=PP_ALIGN.RIGHT)

# ── Save ─────────────────────────────────────────────────────────────────────
out_path = r"C:\WalletSaver\Sori_Capstone_Poster.pptx"
prs.save(out_path)
print(f"OK Saved: {out_path}")
print(f"   Slide size: {W_IN} x {H_IN} inches (A1 portrait)")
