extends Node2D

var state := 0
var current_node: Node = null
var timer := 0.0
var artifact_dir := "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/"

func _ready() -> void:
	print("[Showcase] Starting showcase sequence...")
	_load_step(0)

func _process(delta: float) -> void:
	timer += delta
	if timer >= 0.7:
		timer = 0.0
		_capture_and_advance()

func _load_step(s: int) -> void:
	if current_node:
		current_node.queue_free()
		current_node = null
	
	match s:
		0:
			# Capture HUD Quest List in Level 1
			GameManager.current_level = 1
			GameManager.chore_table_done = false
			GameManager.chore_trash_done = false
			var scn = load("res://scenes/levels/level_1.tscn")
			current_node = scn.instantiate()
			add_child(current_node)
		1:
			# Capture HUD Quest List in Level 1 after 1 quest completed
			GameManager.current_level = 1
			GameManager.chore_table_done = true
			GameManager.complete_good_deed("q_home_table")
			var scn = load("res://scenes/levels/level_1.tscn")
			current_node = scn.instantiate()
			add_child(current_node)
		2:
			# Capture Scene 9 (Songthaew return)
			GameManager.current_level = 9
			var scn = load("res://scenes/levels/level_9.tscn")
			current_node = scn.instantiate()
			add_child(current_node)
		3:
			# Capture Scene 10 (Return Bus)
			GameManager.current_level = 10
			var scn = load("res://scenes/levels/level_10.tscn")
			current_node = scn.instantiate()
			add_child(current_node)
		4:
			# Capture Scene 11 (Rainy Village Night)
			GameManager.current_level = 11
			var scn = load("res://scenes/levels/level_11.tscn")
			current_node = scn.instantiate()
			add_child(current_node)
		5:
			# Capture Scene 12 (Night House)
			GameManager.current_level = 12
			var scn = load("res://scenes/levels/level_12.tscn")
			current_node = scn.instantiate()
			add_child(current_node)
		6:
			# Capture Scene 13 (Bedroom Finale)
			GameManager.current_level = 13
			var scn = load("res://scenes/levels/level_13.tscn")
			current_node = scn.instantiate()
			add_child(current_node)

func _capture_and_advance() -> void:
	var img = get_viewport().get_texture().get_image()
	match state:
		0:
			img.save_png(artifact_dir + "showcase_hud_quest_list_initial.png")
			print("Saved showcase_hud_quest_list_initial.png")
		1:
			img.save_png(artifact_dir + "showcase_hud_quest_list_progress.png")
			print("Saved showcase_hud_quest_list_progress.png")
		2:
			img.save_png(artifact_dir + "showcase_scene_9_songthaew.png")
			print("Saved showcase_scene_9_songthaew.png")
		3:
			img.save_png(artifact_dir + "showcase_scene_10_bus.png")
			print("Saved showcase_scene_10_bus.png")
		4:
			img.save_png(artifact_dir + "showcase_scene_11_rainy_village.png")
			print("Saved showcase_scene_11_rainy_village.png")
		5:
			img.save_png(artifact_dir + "showcase_scene_12_home_night.png")
			print("Saved showcase_scene_12_home_night.png")
		6:
			img.save_png(artifact_dir + "showcase_scene_13_bedroom.png")
			print("Saved showcase_scene_13_bedroom.png")
			print("[Showcase] All 7 captures completed successfully!")
			get_tree().quit(0)
			return
	
	state += 1
	_load_step(state)
