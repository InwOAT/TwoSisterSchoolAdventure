extends Node2D

var frame_timer = 0
var active_scene: Node = null

func _ready():
	print("--- Running Level 2 Verification: Auntie Somsri in Rest Pavilion & Uncle Somkiat Villager ---")
	GameManager.etiquette_stars = 55
	GameManager.money_baht = 45
	GameManager.good_deed_points = 50
	
	var scn = load("res://scenes/levels/level_2.tscn")
	active_scene = scn.instantiate()
	add_child(active_scene)
	
	# Position camera centered on Rest Pavilion and Uncle Somkiat (x: 2950, y: 530)
	var cam: Camera2D = active_scene.get_node_or_null("Camera2D")
	if cam:
		cam.position = Vector2(2950, 530)
	
	# Position players walking towards Auntie in the pavilion
	var p1 = active_scene.get_node_or_null("Players/PlayerKhongkwan")
	var p2 = active_scene.get_node_or_null("Players/PlayerPeemai")
	if p1:
		p1.position = Vector2(2900, 635)
	if p2:
		p2.position = Vector2(2940, 635)

func _process(_delta):
	frame_timer += 1
	# Dismiss intro dialog to show full game scene clearly
	if frame_timer == 10:
		var dialog = active_scene.find_child("DialogModal", true, false)
		if dialog:
			dialog.visible = false
	
	if frame_timer == 35:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/verify_level_2_pavilion_auntie.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured verify_level_2_pavilion_auntie.png (err %d)" % err)
		get_tree().quit(0)
