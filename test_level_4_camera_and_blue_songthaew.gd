extends Node2D

func _ready() -> void:
	print("--- BEGIN TEST LEVEL 4 CAMERA SCROLL & BLUE SONGTHAEW ---")
	
	GameManager.songthaew_correct = false
	
	var scene = load("res://scenes/levels/level_4.tscn")
	assert(scene != null, "Failed to load level_4.tscn")
	var lvl = scene.instantiate()
	add_child(lvl)
	print("Test 1 PASS: Level 4 instantiated successfully")
	
	var portal_school = lvl.get_node_or_null("PortalSchool")
	var blue_prop = lvl.get_node_or_null("EnvironmentProps/SongthaewBlue")
	var blue_zone = lvl.get_node_or_null("InteractiveZones/BlueArea")
	var door_marker = lvl.get_node_or_null("SongthaewDoorMarker")
	var light_circle = lvl.get_node_or_null("SongthaewDoorMarker/LightCircle")
	
	assert(portal_school != null, "PortalSchool missing")
	assert(blue_prop != null, "SongthaewBlue missing")
	assert(blue_zone != null, "BlueArea missing")
	assert(door_marker != null, "SongthaewDoorMarker missing")
	assert(light_circle != null, "LightCircle missing")
	print("Test 2 PASS: All Blue Songthaew nodes and door marker found")
	
	# Verify level width and camera limits
	var w = lvl._get_level_width()
	print("Level 4 reported width: ", w)
	assert(w == 1800.0, "Level 4 width must be 1800.0")
	assert(lvl.max_level_width == 1800.0, "max_level_width must be 1800.0")
	assert(lvl.camera.limit_right == 1800, "camera.limit_right must be 1800")
	print("Test 3 PASS: Camera limit_right is 1800 as required!")
	
	# Simulate players walking from starting point (x=100) to Blue Songthaew (x=1440)
	lvl.p1.global_position.x = 1440.0
	lvl.p2.global_position.x = 1400.0
	
	# Update process
	lvl._process(0.016)
	
	print("Camera position when player is at x=1440: ", lvl.camera.global_position.x)
	assert(lvl.camera.global_position.x >= 1150.0, "Camera should have scrolled to the right (>=1150)!")
	print("Test 4 PASS: Camera scrolled with player to: ", lvl.camera.global_position.x)
	
	# Test choosing blue songthaew
	lvl._choose_blue()
	assert(GameManager.songthaew_correct == true, "songthaew_correct must be true")
	assert(portal_school.is_locked == false, "PortalSchool must be unlocked!")
	print("Test 5 PASS: Blue songthaew chosen and portal unlocked!")
	
	var dlg = lvl.get_node_or_null("DialogModal")
	if dlg:
		dlg._on_close_pressed()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var img = get_viewport().get_texture().get_image()
	if img:
		img.save_png("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/level_4_blue_songthaew_preview.png")
		print("Screenshot saved to level_4_blue_songthaew_preview.png")
	
	print("--- ALL LEVEL 4 TESTS COMPLETED SUCCESSFULLY ---")
	get_tree().quit(0)
