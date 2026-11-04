from PIL import Image, ImageDraw
import os

ITEMS_DIR = r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\assets\items"

# 1. Plant Botany Book (ตำราพฤกษศาสตร์)
im_book = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_book)
d.rounded_rectangle([20, 20, 108, 108], radius=10, fill=(34, 139, 34), outline=(15, 80, 20), width=4)
d.rectangle([25, 20, 40, 108], fill=(220, 200, 150))
# Flower icon on book cover
d.ellipse([55, 45, 85, 75], fill=(255, 215, 0), outline=(200, 150, 0), width=2)
d.line([70, 75, 70, 95], fill=(50, 200, 50), width=4)
d.ellipse([50, 80, 65, 90], fill=(50, 200, 50))
im_book.save(os.path.join(ITEMS_DIR, "item_plant_book.png"))

# 2. First Aid Kit (กล่องปฐมพยาบาล)
im_aid = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_aid)
d.rounded_rectangle([18, 30, 110, 105], radius=12, fill=(250, 250, 250), outline=(220, 20, 60), width=4)
# Red cross
d.rectangle([55, 45, 73, 90], fill=(220, 20, 60))
d.rectangle([40, 60, 88, 75], fill=(220, 20, 60))
# Handle
d.arc([44, 15, 84, 45], 180, 360, fill=(180, 180, 180), width=5)
im_aid.save(os.path.join(ITEMS_DIR, "item_first_aid.png"))

# 3. Organic Fertilizer Bag (ถุงปุ๋ยอินทรีย์ชีวภาพ)
im_fert = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_fert)
d.polygon([(30, 35), (98, 35), (108, 105), (20, 105)], fill=(139, 90, 43), outline=(90, 50, 20))
d.rounded_rectangle([35, 55, 93, 90], radius=6, fill=(245, 222, 179), outline=(160, 110, 50), width=2)
# Sprout icon on bag
d.line([64, 65, 64, 82], fill=(34, 139, 34), width=3)
d.arc([52, 60, 64, 75], 0, 180, fill=(34, 139, 34), width=3)
d.arc([64, 60, 76, 75], 0, 180, fill=(34, 139, 34), width=3)
im_fert.save(os.path.join(ITEMS_DIR, "item_fertilizer.png"))

# 4. Co-op Store Coupon 10 Baht (คูปองสหกรณ์)
im_coup = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
d = ImageDraw.Draw(im_coup)
d.rounded_rectangle([15, 35, 113, 95], radius=8, fill=(255, 239, 213), outline=(255, 140, 0), width=3)
d.rectangle([25, 45, 103, 85], outline=(255, 140, 0), width=1)
d.text((64, 65), "10 ฿", fill=(200, 80, 0), anchor="mm")
im_coup.save(os.path.join(ITEMS_DIR, "item_coupon.png"))

print("Created 4 new quest item icons!")
