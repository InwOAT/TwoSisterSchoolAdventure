extends BaseLevel

@onready var portal_terminal: MaplePortal = $PortalTerminal
@onready var heavy_bag: PushableObject = $HeavyBag
@onready var coin_item: InteractableItem = $CoinItem
@onready var driver_area: Area2D = $DriverArea
@onready var prompt_driver: Label = $DriverArea/PromptLabel

@onready var scenery_1: Sprite2D = get_node_or_null("OutsideScenery/ScenerySprite1")
@onready var scenery_2: Sprite2D = get_node_or_null("OutsideScenery/ScenerySprite2")
@onready var hanging_straps: Node2D = get_node_or_null("HangingStraps")

var near_driver: bool = false
var scroll_speed: float = 75.0

func _ready() -> void:
	level_number = 9
	super._ready()

	# Style prompt label for clear readability
	if prompt_driver and GameManager:
		GameManager.style_prompt_label(prompt_driver)

	if driver_area:
		driver_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_driver = true
				if prompt_driver:
					prompt_driver.visible = true
		)
		driver_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_driver = false
				if prompt_driver:
					prompt_driver.visible = false
		)

	if portal_terminal:
		portal_terminal.target_scene_path = "res://scenes/levels/level_9_5_bus_stop.tscn"
		portal_terminal.target_level = 95
		portal_terminal.target_spawn_x = 120.0
		portal_terminal.portal_name = "ลงรถสู่ ศาลาต่อรถเมล์ [ฉาก 9.5]"
		_update_portal()

	if coin_item:
		coin_item.visible = not GameManager.has_item("เหรียญ 10 บาท") and not GameManager.coin_10_found
		if coin_item.has_node("PromptLabel"):
			GameManager.style_prompt_label(coin_item.get_node("PromptLabel"))

func _process(delta: float) -> void:
	super._process(delta)

	# Scenery parallax scrolling like Scene 10!
	if scenery_1 and scenery_2:
		scenery_1.position.x -= scroll_speed * delta
		scenery_2.position.x -= scroll_speed * delta
		if scenery_1.position.x <= -1280.0:
			scenery_1.position.x = scenery_2.position.x + 2560.0
		if scenery_2.position.x <= -1280.0:
			scenery_2.position.x = scenery_1.position.x + 2560.0

	# Swaying hanging straps
	if hanging_straps:
		var t_strap := Time.get_ticks_msec() * 0.003
		var i := 0
		for child in hanging_straps.get_children():
			if child is Sprite2D:
				child.rotation = sin(t_strap + i * 0.8) * 0.12
				i += 1

	# Engine vibration effect
	var t := Time.get_ticks_msec() * 0.01
	var vibe := sin(t) * 1.0
	if has_node("PassengerSeated1"): $PassengerSeated1.position.y = 535.0 + vibe
	if has_node("PassengerSeated2"): $PassengerSeated2.position.y = 535.0 + sin(t + 1.2) * 1.0
	if has_node("PassengerStanding"): $PassengerStanding.position.y = 560.0 + sin(t + 0.6) * 0.8

	# Detect pushing the bag
	if heavy_bag and abs(heavy_bag.position.x - 560.0) > 30.0:
		if not GameManager.bag_pushed:
			GameManager.bag_pushed = true

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	if near_driver and interact_pressed:
		var conductor_portrait := "res://assets/characters/npcs/portrait_conductor.png"
		if GameManager.has_item("เหรียญ 10 บาท"):
			if AudioManager:
				AudioManager.play_sfx("coin")
			GameManager.coin_10_found = true
			GameManager.remove_item("เหรียญ 10 บาท")
			GameManager.add_star()
			GameManager.dialog_triggered.emit(
				"คุณลุงคนขับรถ",
				"ขอบใจมากจ้ะหนูๆ! รับเหรียญ 10 บาทค่ารถเรียบร้อย สองพี่น้องเก่งมากที่ช่วยกันยกกระเป๋าหาจนเจอ! ตอนนี้ถึงท่ารถแล้ว เดินลงประตูรถไปรอต่อรถเมล์สายหลักกลับบ้านที่ศาลาได้เลยนะ!",
				conductor_portrait
			)
			_update_portal()
		elif GameManager.coin_10_found:
			GameManager.dialog_triggered.emit(
				"คุณลุงคนขับรถ",
				"ถึงท่ารถสถานีต่อรถแล้วจ้า เดินลงจากรถอย่างระมัดระวัง แล้วไปรอที่ศาลาต่อรถเมล์ได้เลยนะ!",
				conductor_portrait
			)
		else:
			GameManager.dialog_triggered.emit(
				"คุณลุงคนขับรถ",
				"ค่ารถ 10 บาทจ้ะหนูๆ... เอ๊ะ เหรียญตกไปอยู่หลังกระเป๋าใบใหญ่เหรอ? ช่วยกันดันกระเป๋าออกแล้วก้มดูสิ!",
				conductor_portrait
			)

func _update_portal() -> void:
	if not portal_terminal:
		return
	if GameManager.coin_10_found:
		portal_terminal.is_locked = false
	else:
		portal_terminal.is_locked = true
		portal_terminal.lock_message = "ต้องช่วยกันดันกระเป๋าใบใหญ่ เพื่อหาเหรียญ 10 บาทที่ตกอยู่ใต้เบาะมาจ่ายค่ารถก่อนนะจ๊ะ! 🪙"
