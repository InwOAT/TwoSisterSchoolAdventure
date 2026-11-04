extends Node2D

var frame = 0

func _ready():
	print("--- Capturing Verification Screenshots for Bus Levels & Nametags ---")

func _process(_delta):
	frame += 1
	if frame == 20:
		var img = get_viewport().get_texture().get_image()
		var out_path = "C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/showcase_level_5_new_npcs.png"
		var err = img.save_png(out_path)
		print("SUCCESS: Captured bus nametags (err %d)" % err)
		get_tree().quit(0)
