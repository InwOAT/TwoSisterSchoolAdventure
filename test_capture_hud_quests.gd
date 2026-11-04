extends Node2D

func _ready() -> void:
	print("[TestHUDQuests] Starting verification...")
	# 1. Load Level 1
	GameManager.current_level = 1
	var scn1 = load("res://scenes/levels/level_1.tscn")
	var lvl1 = scn1.instantiate()
	add_child(lvl1)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/test_hud_level_1_initial.png")
	print("Saved test_hud_level_1_initial.png")
	
	# 2. Simulate completing chore_table in Level 1
	GameManager.chore_table_done = true
	GameManager.complete_good_deed("q_home_table")
	await get_tree().create_timer(0.5).timeout
	
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/test_hud_level_1_table_done.png")
	print("Saved test_hud_level_1_table_done.png")
	
	# 3. Switch to Level 2
	lvl1.queue_free()
	await get_tree().process_frame
	GameManager.current_level = 2
	var scn2 = load("res://scenes/levels/level_2.tscn")
	var lvl2 = scn2.instantiate()
	add_child(lvl2)
	
	await get_tree().create_timer(0.6).timeout
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/test_hud_level_2.png")
	print("Saved test_hud_level_2.png")
	
	# 4. Switch to Level 2.5 (Bus Stop)
	lvl2.queue_free()
	await get_tree().process_frame
	GameManager.current_level = 25
	var scn25 = load("res://scenes/levels/level_2_bus_stop.tscn")
	var lvl25 = scn25.instantiate()
	add_child(lvl25)
	
	await get_tree().create_timer(0.6).timeout
	var img4 = get_viewport().get_texture().get_image()
	img4.save_png("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/test_hud_level_25.png")
	print("Saved test_hud_level_25.png")
	
	print("[TestHUDQuests] All captures completed successfully!")
	get_tree().quit()
