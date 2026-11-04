extends Node2D

var frame := 0
var modal: CanvasLayer = null
var canteen_scene: Node2D = null
var artifact_dir := "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/"

func _ready() -> void:
	print("[TestWasteModal] Setting up scene...")
	GameManager.current_level = 7
	GameManager.canteen_nutrition_ok = true
	GameManager.waste_sorted_ok = false
	var scn7 = load("res://scenes/levels/level_7.tscn")
	canteen_scene = scn7.instantiate()
	add_child(canteen_scene)
	
	var p1 = canteen_scene.get_node_or_null("Players/PlayerKhongkwan")
	if p1:
		p1.position = Vector2(1150, 640)
	var cam = canteen_scene.get_node_or_null("Camera2D")
	if cam:
		cam.position = Vector2(1150, 520)

func _process(_delta: float) -> void:
	frame += 1
	if frame == 10:
		modal = canteen_scene.get_node_or_null("WasteSortingModal")
		if modal:
			modal.open_modal()
	
	elif frame == 20:
		# Choose wrong answer for Q1 (Yellow instead of Green)
		modal._on_choose_bin(1)
		
	elif frame == 30:
		# Capture Question 1 with wrong answer + explanation / เฉลย
		var img1 = get_viewport().get_texture().get_image()
		img1.save_png(artifact_dir + "test_waste_sorting_q1_wrong_explanation.png")
		print("Saved test_waste_sorting_q1_wrong_explanation.png")
		
		# Next question
		modal._on_next_pressed()
		
	elif frame == 40:
		# Choose correct answer for Q2 (Yellow)
		modal._on_choose_bin(1)
		
	elif frame == 50:
		# Capture Question 2 with correct answer
		var img2 = get_viewport().get_texture().get_image()
		img2.save_png(artifact_dir + "test_waste_sorting_q2_correct.png")
		print("Saved test_waste_sorting_q2_correct.png")
		
		# Next question
		modal._on_next_pressed()
		
	elif frame == 60:
		# Choose correct answer for Q3 (Blue)
		modal._on_choose_bin(2)
		
	elif frame == 70:
		# Capture Question 3 with correct blue bin answer
		var img3 = get_viewport().get_texture().get_image()
		img3.save_png(artifact_dir + "test_waste_sorting_q3_blue.png")
		print("Saved test_waste_sorting_q3_blue.png")
		
		print("[TestWasteModal] In-game canteen captures completed successfully!")
		get_tree().quit(0)
