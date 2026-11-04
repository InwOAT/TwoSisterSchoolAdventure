extends Node2D

func _ready() -> void:
	print("[CaptureScenes] Starting capture of all 5 scenes...")
	var artifact_dir := "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/"
	
	# Scene 9
	GameManager.current_level = 9
	var scn9 = load("res://scenes/levels/level_9.tscn").instantiate()
	add_child(scn9)
	await get_tree().create_timer(0.6).timeout
	var img9 = get_viewport().get_texture().get_image()
	img9.save_png(artifact_dir + "showcase_scene_9_songthaew.png")
	print("Saved showcase_scene_9_songthaew.png")
	scn9.queue_free()
	await get_tree().process_frame
	
	# Scene 10
	GameManager.current_level = 10
	var scn10 = load("res://scenes/levels/level_10.tscn").instantiate()
	add_child(scn10)
	await get_tree().create_timer(0.6).timeout
	var img10 = get_viewport().get_texture().get_image()
	img10.save_png(artifact_dir + "showcase_scene_10_bus.png")
	print("Saved showcase_scene_10_bus.png")
	scn10.queue_free()
	await get_tree().process_frame

	# Scene 11
	GameManager.current_level = 11
	var scn11 = load("res://scenes/levels/level_11.tscn").instantiate()
	add_child(scn11)
	await get_tree().create_timer(0.6).timeout
	var img11 = get_viewport().get_texture().get_image()
	img11.save_png(artifact_dir + "showcase_scene_11_rainy_village.png")
	print("Saved showcase_scene_11_rainy_village.png")
	scn11.queue_free()
	await get_tree().process_frame

	# Scene 12
	GameManager.current_level = 12
	var scn12 = load("res://scenes/levels/level_12.tscn").instantiate()
	add_child(scn12)
	await get_tree().create_timer(0.6).timeout
	var img12 = get_viewport().get_texture().get_image()
	img12.save_png(artifact_dir + "showcase_scene_12_home_night.png")
	print("Saved showcase_scene_12_home_night.png")
	scn12.queue_free()
	await get_tree().process_frame

	# Scene 13 (Bedroom)
	GameManager.current_level = 13
	var scn13 = load("res://scenes/levels/level_13.tscn").instantiate()
	add_child(scn13)
	await get_tree().create_timer(0.6).timeout
	var img13 = get_viewport().get_texture().get_image()
	img13.save_png(artifact_dir + "showcase_scene_13_bedroom.png")
	print("Saved showcase_scene_13_bedroom.png")

	# Scene 13 (Homework complete & Parents walked in)
	if scn13.has_method("_complete_homework"):
		scn13._complete_homework()
		await get_tree().create_timer(0.8).timeout
		var img13_end = get_viewport().get_texture().get_image()
		img13_end.save_png(artifact_dir + "showcase_scene_13_ending.png")
		print("Saved showcase_scene_13_ending.png")

	print("[CaptureScenes] All captures finished successfully!")
	get_tree().quit()
