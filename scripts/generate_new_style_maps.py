import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_pin(draw, x, y, number_text, label_text, color_rgb, font_badge, font_label):
    """Draw a professional game-map style pin marker with drop shadow, glowing badge, and text label"""
    radius = 18
    # 1. Drop shadow for badge
    draw.ellipse([x - radius + 2, y - radius + 3, x + radius + 2, y + radius + 3], fill=(0, 0, 0, 110))
    # 2. Outer glowing ring
    draw.ellipse([x - radius - 2, y - radius - 2, x + radius + 2, y + radius + 2], fill=(255, 255, 255, 220))
    # 3. Main colored circle
    draw.ellipse([x - radius, y - radius, x + radius, y + radius], fill=color_rgb)
    # 4. Inner subtle highlight ring
    draw.ellipse([x - radius + 3, y - radius + 3, x + radius - 3, y + radius - 3], outline=(255, 255, 255, 160), width=1)
    
    # 5. Badge number/text centered
    bbox = font_badge.getbbox(number_text)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text((x - tw // 2, y - th // 2 - 2), number_text, fill=(255, 255, 255), font=font_badge)
    
    # 6. Label tag pill below
    l_bbox = font_label.getbbox(label_text)
    lw = l_bbox[2] - l_bbox[0]
    lh = l_bbox[3] - l_bbox[1]
    
    pill_w = lw + 16
    pill_h = lh + 10
    pill_x1 = x - pill_w // 2
    pill_y1 = y + radius + 4
    pill_x2 = pill_x1 + pill_w
    pill_y2 = pill_y1 + pill_h
    
    # Pill shadow
    draw.rounded_rectangle([pill_x1 + 1, pill_y1 + 2, pill_x2 + 1, pill_y2 + 2], radius=6, fill=(0, 0, 0, 120))
    # Pill background
    draw.rounded_rectangle([pill_x1, pill_y1, pill_x2, pill_y2], radius=6, fill=(15, 24, 42, 235), outline=(255, 225, 90, 240), width=2)
    # Pill text
    draw.text((pill_x1 + 8, pill_y1 + 4), label_text, fill=(255, 250, 230), font=font_label)

def draw_header_banner(draw, w, title_text, font_title):
    bbox = font_title.getbbox(title_text)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    bw = tw + 40
    bh = th + 18
    bx1 = (w - bw) // 2
    by1 = 16
    bx2 = bx1 + bw
    by2 = by1 + bh
    
    # Drop shadow
    draw.rounded_rectangle([bx1 + 3, by1 + 4, bx2 + 3, by2 + 4], radius=10, fill=(0, 0, 0, 140))
    # Gradient/Border banner
    draw.rounded_rectangle([bx1, by1, bx2, by2], radius=10, fill=(14, 22, 38, 245), outline=(255, 215, 60, 255), width=3)
    # Title text
    draw.text((bx1 + 20, by1 + 8), title_text, fill=(255, 235, 140), font=font_title)

def draw_compass(draw, cx, cy):
    size = 24
    # Golden ring
    draw.ellipse([cx - size, cy - size, cx + size, cy + size], fill=(12, 18, 30, 220), outline=(255, 215, 70, 255), width=2)
    # Diamond pointer
    draw.polygon([(cx, cy - size + 4), (cx + 5, cy), (cx, cy - 2)], fill=(235, 60, 75)) # North red
    draw.polygon([(cx, cy - size + 4), (cx - 5, cy), (cx, cy - 2)], fill=(195, 30, 45))
    draw.polygon([(cx, cy + size - 4), (cx + 5, cy), (cx, cy + 2)], fill=(220, 220, 240)) # South white
    draw.polygon([(cx, cy + size - 4), (cx - 5, cy), (cx, cy + 2)], fill=(160, 160, 180))
    # Small N
    try:
        f_c = ImageFont.truetype("C:/Windows/Fonts/tahomabd.ttf", 10)
        draw.text((cx - 4, cy - size - 12), "N", fill=(255, 215, 70), font=f_c)
    except:
        pass

def generate_maps():
    # Fonts
    try:
        font_title = ImageFont.truetype("C:/Windows/Fonts/leelawad.ttf", 22)
        font_badge = ImageFont.truetype("C:/Windows/Fonts/tahomabd.ttf", 14)
        font_label = ImageFont.truetype("C:/Windows/Fonts/leelawad.ttf", 13)
    except:
        font_title = ImageFont.load_default()
        font_badge = ImageFont.load_default()
        font_label = ImageFont.load_default()

    # 1. GENERATE SCHOOL MAP
    school_base = Image.open("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/school_map_inpaint_v2.png").convert("RGBA")
    sw, sh = 1024, 682
    school_img = school_base.resize((sw, sh), Image.Resampling.LANCZOS)
    
    # Overlay draw
    draw_s = ImageDraw.Draw(school_img, "RGBA")
    
    draw_header_banner(draw_s, sw, "แผนผังโรงเรียนชุมชนหนองเรือ (School Adventure Map)", font_title)
    draw_compass(draw_s, sw - 46, 46)
    
    # Pins for school
    # [24] ประตูโรงเรียน (norm: 0.54, 0.70)
    create_pin(draw_s, int(sw * 0.54), int(sh * 0.70) + 10, "24", "[24] ประตูโรงเรียน", (230, 60, 60), font_badge, font_label)
    # [4] อาคารเรียน & ห้องสมุด (norm: 0.38, 0.40)
    create_pin(draw_s, int(sw * 0.38) - 10, int(sh * 0.40), "4", "[4] อาคารเรียน & ห้องสมุด", (40, 110, 220), font_badge, font_label)
    # [13] โรงอาหารกลาง (norm: 0.32, 0.28)
    create_pin(draw_s, int(sw * 0.32), int(sh * 0.28) - 10, "13", "[13] โรงอาหารกลาง", (35, 170, 95), font_badge, font_label)
    # [23] สวน & สนามเด็กเล่น (norm: 0.50, 0.45)
    create_pin(draw_s, int(sw * 0.50), int(sh * 0.45), "23", "[23] สนามเด็กเล่น & สวน", (150, 70, 200), font_badge, font_label)
    # [14/20] พยาบาล & พัสดุ
    create_pin(draw_s, int(sw * 0.62), int(sh * 0.36), "14", "[14] พยาบาล & [20] พัสดุ", (20, 160, 180), font_badge, font_label)
    # [18] สหกรณ์
    create_pin(draw_s, int(sw * 0.68), int(sh * 0.52), "18", "[18] ร้านค้าสหกรณ์", (235, 140, 25), font_badge, font_label)
    # [22] ศาลปู่ย่า
    create_pin(draw_s, int(sw * 0.46), int(sh * 0.16), "22", "[22] ศาลปู่ย่า", (220, 180, 20), font_badge, font_label)
    # ⚽ สนามฟุตบอล
    create_pin(draw_s, int(sw * 0.34), int(sh * 0.56), "⚽", "สนามกีฬา & ลานเสาธง", (45, 175, 75), font_badge, font_label)

    # Save school map
    school_out_path = "D:/HOME3/Mobile/Games/TwoSisterSchoolAdventure/assets/ui/school_map.png"
    school_img.save(school_out_path)
    school_img.save("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/school_map_new_style.png")
    print("Saved new school_map.png!")

    # 2. GENERATE VILLAGE MAP
    village_base = Image.open("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/village_seed202.png").convert("RGBA")
    vw, vh = 1024, 640
    village_img = village_base.resize((vw, vh), Image.Resampling.LANCZOS)
    
    draw_v = ImageDraw.Draw(village_img, "RGBA")
    
    draw_header_banner(draw_v, vw, "แผนที่หมู่บ้านตำบลดอนโมง (Don Mong Adventure Map)", font_title)
    draw_compass(draw_v, vw - 46, 46)
    
    # Pins for village matching mini_map.gd normalized coordinates
    # [1] ป้อมตำรวจ (norm: 0.18, 0.44)
    create_pin(draw_v, int(vw * 0.16), int(vh * 0.42), "1", "[1] ป้อมตำรวจ & เทศบาล", (30, 110, 230), font_badge, font_label)
    # [2] ตลาดนัดคลองถม (norm: 0.32, 0.36)
    create_pin(draw_v, int(vw * 0.30), int(vh * 0.34), "2", "[2] ตลาดนัดคลองถม", (230, 100, 30), font_badge, font_label)
    # [3] Lotus's & ร้านชำ (norm: 0.46, 0.54)
    create_pin(draw_v, int(vw * 0.46), int(vh * 0.54), "3", "[3] Lotus's & ร้านชำป้าสมศรี", (40, 165, 80), font_badge, font_label)
    # [4] คลินิกหมอ (norm: 0.60, 0.45)
    create_pin(draw_v, int(vw * 0.60), int(vh * 0.45), "4", "[4] คลินิกหมอดอนโมง", (225, 50, 70), font_badge, font_label)
    # [5] วัดมงคลนิมิต (norm: 0.78, 0.44)
    create_pin(draw_v, int(vw * 0.78), int(vh * 0.42), "5", "[5] วัดมงคลนิมิต", (230, 180, 25), font_badge, font_label)
    # [6] ไปรษณีย์ไทย (norm: 0.92, 0.52)
    create_pin(draw_v, int(vw * 0.90), int(vh * 0.50), "6", "[6] ไปรษณีย์ไทยดอนโมง", (190, 40, 45), font_badge, font_label)
    # [7] ป้ายรถเมล์
    create_pin(draw_v, int(vw * 0.82), int(vh * 0.64), "7", "[7] ศาลาป้ายรถเมล์", (20, 170, 210), font_badge, font_label)

    village_out_path = "D:/HOME3/Mobile/Games/TwoSisterSchoolAdventure/assets/ui/village_map.png"
    village_img.save(village_out_path)
    village_img.save("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/village_map_new_style.png")
    print("Saved new village_map.png!")

if __name__ == "__main__":
    generate_maps()
