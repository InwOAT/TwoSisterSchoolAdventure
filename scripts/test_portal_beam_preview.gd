extends Node2D

var frame_count := 0
var p_locked: MaplePortal = null
var p_unlocked: MaplePortal = null

func _ready() -> void:
	var portal_scn = load("res://scenes/portal.tscn")
	
	# Background tint
	var bg = ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.08, 0.09, 0.13, 1.0)
	add_child(bg)
	
	# Ground line
	var ground = ColorRect.new()
	ground.size = Vector2(1280, 150)
	ground.position = Vector2(0, 520)
	ground.color = Color(0.15, 0.16, 0.22, 1.0)
	add_child(ground)
	
	# Titles
	var title = Label.new()
	title.text = "เปรียบเทียบวงกลมแสงข้ามฉาก (ลดขนาด 50% + เสาแสงเรืองรองพุ่งขึ้นเมื่อปลดล็อค)"
	title.position = Vector2(300, 40)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(title)

	var sub_locked = Label.new()
	sub_locked.text = "【ก่อนทำเควสเสร็จ】\nสีส้มอำพัน (Amber Orange)\nวงกลมเล็กลง 50% | ยังไม่มีเสาแสง"
	sub_locked.position = Vector2(250, 100)
	sub_locked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_locked.add_theme_font_size_override("font_size", 14)
	sub_locked.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	add_child(sub_locked)

	var sub_unlocked = Label.new()
	sub_unlocked.text = "【ทำเควสเสร็จแล้ว】\nสีเขียว-ฟ้าสดใส (Emerald Cyan)\nวงกลม 50% + เสาแสงเรืองรองพุ่งขึ้น + ประกายวิ้งวับ"
	sub_unlocked.position = Vector2(750, 100)
	sub_unlocked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_unlocked.add_theme_font_size_override("font_size", 14)
	sub_unlocked.add_theme_color_override("font_color", Color(0.3, 1.0, 0.8))
	add_child(sub_unlocked)

	p_locked = portal_scn.instantiate()
	p_locked.position = Vector2(380, 480)
	p_locked.is_locked = true
	add_child(p_locked)

	p_unlocked = portal_scn.instantiate()
	p_unlocked.position = Vector2(900, 480)
	p_unlocked.is_locked = false
	add_child(p_unlocked)

func _process(_delta: float) -> void:
	frame_count += 1
	# Give 45 frames for the beam to fully emerge and rise up beautifully
	if frame_count == 45:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/test_portal_beam_locked_and_unlocked.png"
		img.save_png(out_path)
		print("SUCCESS: Saved test_portal_beam_locked_and_unlocked.png")
		get_tree().quit(0)
