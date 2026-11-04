from PIL import Image, ImageDraw, ImageFont
import os
import math

ITEMS_DIR = r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\assets\items"
UI_DIR = r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\assets\ui"

os.makedirs(ITEMS_DIR, exist_ok=True)
os.makedirs(UI_DIR, exist_ok=True)

def draw_circle_badge(draw, bbox, fill_color, outline_color, width=4):
    draw.ellipse(bbox, fill=fill_color, outline=outline_color, width=width)

# 1. House Key
im_key = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_key)
d.ellipse([20, 20, 60, 60], fill=(255, 215, 0), outline=(200, 150, 0), width=4)
d.ellipse([32, 32, 48, 48], fill=(0, 0, 0, 0), outline=(200, 150, 0), width=3)
d.rectangle([56, 36, 105, 44], fill=(255, 215, 0), outline=(200, 150, 0), width=3)
d.rectangle([85, 44, 93, 58], fill=(255, 215, 0), outline=(200, 150, 0), width=2)
d.rectangle([97, 44, 105, 54], fill=(255, 215, 0), outline=(200, 150, 0), width=2)
im_key.save(os.path.join(ITEMS_DIR, "item_house_key.png"))

# 2. Student Card
im_card = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_card)
d.rounded_rectangle([15, 25, 113, 103], radius=10, fill=(240, 248, 255), outline=(65, 105, 225), width=4)
d.rectangle([25, 35, 103, 50], fill=(65, 105, 225))
d.rounded_rectangle([25, 58, 55, 92], radius=4, fill=(255, 182, 193), outline=(200, 100, 120), width=2)
d.line([65, 65, 103, 65], fill=(100, 100, 100), width=3)
d.line([65, 75, 95, 75], fill=(100, 100, 100), width=3)
d.line([65, 85, 90, 85], fill=(100, 100, 100), width=3)
im_card.save(os.path.join(ITEMS_DIR, "item_student_card.png"))

# 3. Umbrella
im_umb = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_umb)
d.pieslice([15, 15, 113, 113], 180, 360, fill=(255, 105, 180), outline=(200, 50, 120), width=4)
d.line([64, 15, 64, 105], fill=(160, 82, 45), width=5)
d.arc([45, 95, 65, 115], 0, 180, fill=(160, 82, 45), width=5)
im_umb.save(os.path.join(ITEMS_DIR, "item_umbrella.png"))

# 4. Classroom Key & Attendance Book
im_book = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_book)
d.rounded_rectangle([20, 20, 108, 108], radius=8, fill=(70, 130, 180), outline=(30, 70, 120), width=4)
d.rectangle([35, 20, 45, 108], fill=(220, 220, 220))
d.ellipse([65, 45, 95, 75], fill=(255, 215, 0), outline=(200, 150, 0), width=3)
d.rectangle([80, 56, 110, 64], fill=(255, 215, 0), outline=(200, 150, 0), width=2)
im_book.save(os.path.join(ITEMS_DIR, "item_classroom_key.png"))

# 5. Watering Can
im_can = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_can)
d.rounded_rectangle([30, 45, 85, 105], radius=12, fill=(60, 179, 113), outline=(34, 139, 34), width=4)
d.line([85, 65, 118, 45], fill=(60, 179, 113), width=7)
d.ellipse([110, 38, 124, 52], fill=(255, 215, 0), outline=(200, 150, 0), width=2)
d.arc([15, 35, 55, 95], 90, 270, fill=(34, 139, 34), width=5)
im_can.save(os.path.join(ITEMS_DIR, "item_watering_can.png"))

# 6. Coin 10
im_c10 = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_c10)
d.ellipse([10, 10, 118, 118], fill=(218, 165, 32), outline=(184, 134, 11), width=5)
d.ellipse([26, 26, 102, 102], fill=(230, 230, 235), outline=(180, 180, 190), width=4)
d.text((64, 64), "10", fill=(100, 100, 120), anchor="mm")
im_c10.save(os.path.join(ITEMS_DIR, "item_coin_10.png"))
im_c10.save(os.path.join(UI_DIR, "ui_coin_10.png"))

# 7. Wallet
im_wal = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_wal)
d.rounded_rectangle([20, 35, 108, 95], radius=12, fill=(139, 69, 19), outline=(100, 40, 10), width=4)
d.rounded_rectangle([75, 55, 105, 75], radius=6, fill=(218, 165, 32), outline=(184, 134, 11), width=2)
d.ellipse([92, 62, 98, 68], fill=(255, 255, 255))
im_wal.save(os.path.join(ITEMS_DIR, "item_wallet.png"))

# UI Coins & Banknote
for val, col_fill, col_out in [(1, (220, 220, 225), (160, 160, 170)),
                               (2, (240, 230, 140), (190, 170, 50)),
                               (5, (200, 205, 210), (140, 145, 150))]:
    im = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    r = 45 if val == 1 else (48 if val == 2 else 52)
    d.ellipse([64 - r, 64 - r, 64 + r, 64 + r], fill=col_fill, outline=col_out, width=4)
    d.text((64, 64), str(val), fill=(80, 80, 90), anchor="mm")
    im.save(os.path.join(UI_DIR, f"ui_coin_{val}.png"))

# Banknote 20
im_b20 = Image.new("RGBA", (160, 90), (0, 0, 0, 0))
d = ImageDraw.Draw(im_b20)
d.rounded_rectangle([5, 5, 155, 85], radius=8, fill=(152, 251, 152), outline=(46, 139, 87), width=4)
d.rectangle([15, 15, 145, 75], outline=(46, 139, 87), width=2)
d.text((80, 45), "20 ฿", fill=(34, 100, 60), anchor="mm")
im_b20.save(os.path.join(UI_DIR, "ui_banknote_20.png"))

# Portal Sprite
im_portal = Image.new("RGBA", (96, 160), (0, 0, 0, 0))
d = ImageDraw.Draw(im_portal)
for y in range(160):
    alpha = int(180 * math.sin(y / 160.0 * math.pi))
    d.line([16, y, 80, y], fill=(100, 200, 255, alpha), width=1)
d.ellipse([16, 135, 80, 155], fill=(50, 150, 255, 200), outline=(150, 230, 255, 255), width=3)
d.ellipse([26, 140, 70, 150], fill=(200, 240, 255, 240))
im_portal.save(os.path.join(r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\assets\portals", "portal_beam.png"))

print("Item and UI icons generated successfully!")
