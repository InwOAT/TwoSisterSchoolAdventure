extends Node2D

var frame = 0

func _ready():
	print("--- Testing HUD Layout with Items and Stats ---")
	GameManager.etiquette_stars = 55
	GameManager.money_baht = 45
	GameManager.good_deed_points = 50
	
	# Give test items: umbrella, house key, student card, orange cat, cold drink
	GameManager.inventory.clear()
	GameManager.add_item("ร่ม")
	GameManager.add_item("กุญแจบ้าน")
	GameManager.add_item("บัตรนักเรียน")
	GameManager.add_item("ลูกแมวเจ้าส้ม")
	GameManager.add_item("น้ำเก๊กฮวยเย็นชื่นใจ")
	
	var hud_scene = load("res://scenes/ui/hud.tscn")
	var hud = hud_scene.instantiate()
	add_child(hud)

func _process(_delta):
	frame += 1
	if frame == 5:
		GameManager.map_toggled.emit()
	elif frame == 8:
		# Switch to school tab
		var btn = get_tree().root.find_child("BtnTabSchool", true, false)
		if btn:
			btn.emit_signal("pressed")
	elif frame == 16:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/test_map_modal_school_capture.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured test_map_modal_school_capture.png (err %d)" % err)
		get_tree().quit(0)
