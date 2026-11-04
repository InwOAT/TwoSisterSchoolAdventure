extends Node2D

var frame = 0
var scn_level1: Node = null

func _ready():
	print("--- Testing Level 7 Garden Portal with Emerald Cyan Light Circle ---")
	GameManager.current_level = 7
	GameManager.canteen_nutrition_ok = true
	GameManager.waste_sorted_ok = true
	GameManager.storage_unlocked = true
	GameManager.inventory.clear()
	GameManager.add_item("บัวรดน้ำ")
	
	var lvl7 = load("res://scenes/levels/level_7.tscn")
	scn_level1 = lvl7.instantiate()
	add_child(scn_level1)
	
	# Move players near exit garden portal (x: 1650)
	var p1 = scn_level1.get_node_or_null("Players/PlayerKhongkwan")
	var p2 = scn_level1.get_node_or_null("Players/PlayerPeemai")
	if p1: p1.position = Vector2(1620, 640)
	if p2: p2.position = Vector2(1650, 640)
	
	# Position camera near exit garden portal (x: 1720, y: 540)
	var cam: Camera2D = scn_level1.get_node_or_null("Camera2D")
	if cam:
		cam.position = Vector2(1720, 540)

func _process(_delta):
	frame += 1
	if frame == 10:
		var dlg = scn_level1.find_child("DialogModal", true, false)
		if dlg:
			dlg.visible = false
	elif frame == 30:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/verify_level_7_unlocked_portal.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured verify_level_7_unlocked_portal.png (err %d)" % err)
		get_tree().quit(0)
