extends Node2D

var frame_timer = 0
var active_scene: Node = null

func _ready():
	print("--- Running Final Level 7 Verification with Polished HUD & Mezzanine ---")
	GameManager.etiquette_stars = 55
	GameManager.money_baht = 45
	GameManager.good_deed_points = 50
	
	# Give inventory items
	GameManager.inventory.clear()
	GameManager.add_item("ร่ม")
	GameManager.add_item("กุญแจบ้าน")
	GameManager.add_item("บัตรนักเรียน")
	
	var scn = load("res://scenes/levels/level_7.tscn")
	active_scene = scn.instantiate()
	add_child(active_scene)
	
	# Position camera near Building 20 & mezzanine (x: 1480, y: 500)
	var cam: Camera2D = active_scene.get_node_or_null("Camera2D")
	if cam:
		cam.position = Vector2(1480, 500)
	
	# Position Khongkwan (P1) near ladder and Peemai (P2) on mezzanine platform
	var p1 = active_scene.get_node_or_null("Players/PlayerKhongkwan")
	var p2 = active_scene.get_node_or_null("Players/PlayerPeemai")
	if p1:
		p1.position = Vector2(1340, 640)
	if p2:
		p2.position = Vector2(1490, 435)

func _process(_delta):
	frame_timer += 1
	# Dismiss intro dialog to show full game scene clearly
	if frame_timer == 10:
		var dialog = active_scene.find_child("DialogModal", true, false)
		if dialog:
			dialog.visible = false
	
	if frame_timer == 35:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/verify_level_7_mezzanine_ladder_final.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured verify_level_7_mezzanine_ladder_final.png (err %d)" % err)
		get_tree().quit(0)
