extends Node2D

func _ready():
    await get_tree().process_frame
    await get_tree().process_frame
    
    # Load level 5
    var lvl = load('res://scenes/levels/level_5.tscn').instantiate()
    add_child(lvl)
    
    # Set camera / view near guard (x=370, y=575)
    var cam = Camera2D.new()
    cam.position = Vector2(400, 500)
    cam.zoom = Vector2(1.5, 1.5)
    add_child(cam)
    cam.make_current()
    
    await get_tree().create_timer(0.3).timeout
    await get_tree().process_frame
    
    var img = get_viewport().get_texture().get_image()
    img.save_png('C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/verify_guard_level5.png')
    print('VERIFY_GUARD_LEVEL5_OK')
    get_tree().quit()
