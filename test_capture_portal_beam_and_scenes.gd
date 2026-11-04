extends Node2D

func _ready() -> void:
	var artifact_dir := "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/"
	
	# Test 1: Portal comparison in standalone scene
	var portal_scn = load("res://scenes/portal.tscn")
	var p_locked: MaplePortal = portal_scn.instantiate()
	p_locked.position = Vector2(400, 450)
	p_locked.is_locked = true
	add_child(p_locked)

	var p_unlocked: MaplePortal = portal_scn.instantiate()
	p_unlocked.position = Vector2(880, 450)
	p_unlocked.is_locked = false
	add_child(p_unlocked)

	# Wait for beam to rise up
	await get_tree().create_timer(0.9).timeout
	var img_portal = get_viewport().get_texture().get_image()
	img_portal.save_png(artifact_dir + "test_portal_beam_locked_and_unlocked.png")
	print("Saved test_portal_beam_locked_and_unlocked.png")

	p_locked.queue_free()
	p_unlocked.queue_free()
	await get_tree().process_frame

	# Test 2: Capture Scene 9
	GameManager.current_level = 9
	var scn9 = load("res://scenes/levels/level_9.tscn").instantiate()
	add_child(scn9)
	await get_tree().create_timer(0.5).timeout
	var img9 = get_viewport().get_texture().get_image()
	img9.save_png(artifact_dir + "showcase_scene_9_songthaew.png")
	print("Saved showcase_scene_9_songthaew.png")
	scn9.queue_free()
	await get_tree().process_frame

	# Test 3: Capture Scene 10
	GameManager.current_level = 10
	var scn10 = load("res://scenes/levels/level_10.tscn").instantiate()
	add_child(scn10)
	await get_tree().create_timer(0.5).timeout
	var img10 = get_viewport().get_texture().get_image()
	img10.save_png(artifact_dir + "showcase_scene_10_bus.png")
	print("Saved showcase_scene_10_bus.png")
	scn10.queue_free()
	await get_tree().process_frame

	# Test 4: Capture Scene 11
	GameManager.current_level = 11
	var scn11 = load("res://scenes/levels/level_11.tscn").instantiate()
	add_child(scn11)
	await get_tree().create_timer(0.5).timeout
	var img11 = get_viewport().get_texture().get_image()
	img11.save_png(artifact_dir + "showcase_scene_11_rainy_village.png")
	print("Saved showcase_scene_11_rainy_village.png")
	scn11.queue_free()
	await get_tree().process_frame

	# Test 5: Capture Scene 12
	GameManager.current_level = 12
	var scn12 = load("res://scenes/levels/level_12.tscn").instantiate()
	add_child(scn12)
	await get_tree().create_timer(0.5).timeout
	var img12 = get_viewport().get_texture().get_image()
	img12.save_png(artifact_dir + "showcase_scene_12_home_night.png")
	print("Saved showcase_scene_12_home_night.png")
	scn12.queue_free()
	await get_tree().process_frame

	# Test 6: Capture Scene 13
	GameManager.current_level = 13
	var scn13 = load("res://scenes/levels/level_13.tscn").instantiate()
	add_child(scn13)
	await get_tree().create_timer(0.5).timeout
	var img13 = get_viewport().get_texture().get_image()
	img13.save_png(artifact_dir + "showcase_scene_13_bedroom.png")
	print("Saved showcase_scene_13_bedroom.png")

	print("[CapturePortalAndScenes] Completed successfully!")
	get_tree().quit()
