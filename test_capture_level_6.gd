extends Node2D

func _ready() -> void:
	var scn = load("res://scenes/levels/level_6.tscn")
	var lvl = scn.instantiate()
	add_child(lvl)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("res://godot_capture_level_6_quiz.png")
	print("Captured Level 6 Quiz screen!")
	get_tree().quit()
