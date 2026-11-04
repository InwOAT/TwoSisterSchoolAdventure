extends Node2D

var frame_count = 0
var active_scene: Node = null

func _ready():
	print("--- Running Verification: Peemai Head/Body Alignment & Parents Walking in Level 1 ---")
	var scn = load("res://scenes/levels/level_1.tscn")
	active_scene = scn.instantiate()
	add_child(active_scene)
	
	# Position camera centered on Mom and Dad and the players (x: 550, y: 500)
	var cam: Camera2D = active_scene.get_node_or_null("Camera2D")
	if cam:
		cam.position = Vector2(580, 520)
	
	# Position Khongkwan and Peemai near the center
	var p1 = active_scene.get_node_or_null("Players/PlayerKhongkwan")
	var p2 = active_scene.get_node_or_null("Players/PlayerPeemai")
	if p1:
		p1.position = Vector2(540, 635)
	if p2:
		p2.position = Vector2(590, 635)

func _process(_delta):
	frame_count += 1
	
	# Dismiss intro dialog to show scene clearly
	if frame_count == 10:
		var dialog = active_scene.find_child("DialogModal", true, false)
		if dialog:
			dialog.visible = false
	
	if frame_count == 35:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/verify_peemai_parents_t1.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured verify_peemai_parents_t1.png (err %d)" % err)
	
	if frame_count == 90:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/verify_peemai_parents_t2.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured verify_peemai_parents_t2.png (err %d)" % err)
		get_tree().quit(0)
