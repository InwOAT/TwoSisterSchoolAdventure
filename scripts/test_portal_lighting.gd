extends Node2D

var frame = 0
var portal_locked: Node2D = null
var portal_unlocked: Node2D = null

func _ready():
	print("--- Testing Portal Light Circle & Badge (Locked vs Unlocked) ---")
	
	# Load portal scene
	var portal_scene = load("res://scenes/portal.tscn")
	
	# Instance 1: Locked portal (Before quests are completed)
	portal_locked = portal_scene.instantiate()
	portal_locked.position = Vector2(400, 520)
	portal_locked.portal_name = "ประตูหน้าบ้าน (ก่อนทำเควส)"
	portal_locked.is_locked = true
	add_child(portal_locked)
	
	# Instance 2: Unlocked portal (After quests are completed)
	portal_unlocked = portal_scene.instantiate()
	portal_unlocked.position = Vector2(880, 520)
	portal_unlocked.portal_name = "ประตูหน้าบ้าน (หลังทำเควสเสร็จ)"
	portal_unlocked.is_locked = false
	add_child(portal_unlocked)
	
	# Add descriptive labels
	var lbl_l = Label.new()
	lbl_l.text = "【 ก่อนทำเควสเสร็จ 】\nวงกลมแสงสีส้มอำพัน (Amber Orange)\nป้าย: '🔒 ต้องทำเควสให้ครบก่อน'"
	lbl_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_l.position = Vector2(240, 240)
	lbl_l.add_theme_font_size_override("font_size", 16)
	lbl_l.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	add_child(lbl_l)
	
	var lbl_r = Label.new()
	lbl_r.text = "【 เมื่อทำเควสครบแล้ว 】\nวงกลมแสงสีเขียว-ฟ้าสดใส (Emerald Cyan)\nป้าย: '✨ ทางเปิดแล้ว! กด [W / ↑ / E] เพื่อไปต่อ'"
	lbl_r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_r.position = Vector2(720, 240)
	lbl_r.add_theme_font_size_override("font_size", 16)
	lbl_r.add_theme_color_override("font_color", Color(0.2, 1.0, 0.85))
	add_child(lbl_r)

func _process(_delta):
	frame += 1
	if frame == 25:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/test_portal_light_comparison.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured test_portal_light_comparison.png (err %d)" % err)
		get_tree().quit(0)
