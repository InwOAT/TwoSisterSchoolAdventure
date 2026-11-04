extends BaseLevel

@onready var portal_exit: MaplePortal = $PortalExit
@onready var conductor_npc: Area2D = $ConductorArea
@onready var grandma_npc: Area2D = $GrandmaArea
@onready var prompt_conductor: Label = $ConductorArea/PromptLabel
@onready var prompt_grandma: Label = $GrandmaArea/PromptLabel
@onready var conductor_sprite: Sprite2D = $ConductorArea/Sprite2D
@onready var grandma_sprite: Sprite2D = $GrandmaArea/Sprite2D
@onready var conductor_badge: Label = $ConductorArea/QuestBadge
@onready var grandma_badge: Label = $GrandmaArea/QuestBadge

# Additional Bus Passengers
@onready var student_seat_npc: Area2D = get_node_or_null("PassengerStudent")
@onready var auntie_seat_npc: Area2D = get_node_or_null("PassengerAuntie")
@onready var girl_stand_npc: Area2D = get_node_or_null("PassengerGirlStanding")
@onready var worker_stand_npc: Area2D = get_node_or_null("PassengerWorkerStanding")

@onready var student_seat_sprite: Sprite2D = get_node_or_null("PassengerStudent/Sprite2D")
@onready var auntie_seat_sprite: Sprite2D = get_node_or_null("PassengerAuntie/Sprite2D")
@onready var girl_stand_sprite: Sprite2D = get_node_or_null("PassengerGirlStanding/Sprite2D")
@onready var worker_stand_sprite: Sprite2D = get_node_or_null("PassengerWorkerStanding/Sprite2D")

@onready var prompt_student_seat: Label = get_node_or_null("PassengerStudent/PromptLabel")
@onready var prompt_auntie_seat: Label = get_node_or_null("PassengerAuntie/PromptLabel")
@onready var prompt_girl_stand: Label = get_node_or_null("PassengerGirlStanding/PromptLabel")
@onready var prompt_worker_stand: Label = get_node_or_null("PassengerWorkerStanding/PromptLabel")

@onready var scenery_1: Sprite2D = $OutsideScenery/ScenerySprite1
@onready var scenery_2: Sprite2D = $OutsideScenery/ScenerySprite2
@onready var hanging_straps: Node2D = $HangingStraps
@onready var bus_shell: Sprite2D = $BusShell
@onready var bus_seats: Node2D = $BusSeats
@onready var bus_stop_bell: Area2D = $BusStopBell
@onready var prompt_bell: Label = $BusStopBell/PromptLabel
@onready var bell_sprite: Sprite2D = $BusStopBell/Sprite2D
@onready var bell_label: Label = $BusStopBell/Label

var near_conductor: bool = false
var near_grandma: bool = false
var near_bell: bool = false
var near_student_seat: bool = false
var near_auntie_seat: bool = false
var near_girl_stand: bool = false
var near_worker_stand: bool = false
var bell_pressed: bool = false
var scroll_speed: float = 80.0
var seated_grandma_texture: Texture2D = null

func _ready() -> void:
	level_number = 3
	add_maple_platforms = false
	super._ready()

	GameManager.start_good_deed("q_bus_seat")
	seated_grandma_texture = load("res://assets/characters/npcs/npc_grandma_seated.png")

	conductor_npc.body_entered.connect(func(b): if b.is_in_group("players"): near_conductor = true; prompt_conductor.visible = true)
	conductor_npc.body_exited.connect(func(b): if b.is_in_group("players"): near_conductor = false; prompt_conductor.visible = false)

	grandma_npc.body_entered.connect(func(b): if b.is_in_group("players"): near_grandma = true; prompt_grandma.visible = not GameManager.grandma_seated)
	grandma_npc.body_exited.connect(func(b): if b.is_in_group("players"): near_grandma = false; prompt_grandma.visible = false)

	if bus_stop_bell:
		bus_stop_bell.body_entered.connect(func(b): if b.is_in_group("players"): near_bell = true; if prompt_bell: prompt_bell.visible = true)
		bus_stop_bell.body_exited.connect(func(b): if b.is_in_group("players"): near_bell = false; if prompt_bell: prompt_bell.visible = false)

	if student_seat_npc:
		student_seat_npc.body_entered.connect(func(b): if b.is_in_group("players"): near_student_seat = true; if prompt_student_seat: prompt_student_seat.visible = true)
		student_seat_npc.body_exited.connect(func(b): if b.is_in_group("players"): near_student_seat = false; if prompt_student_seat: prompt_student_seat.visible = false)

	if auntie_seat_npc:
		auntie_seat_npc.body_entered.connect(func(b): if b.is_in_group("players"): near_auntie_seat = true; if prompt_auntie_seat: prompt_auntie_seat.visible = true)
		auntie_seat_npc.body_exited.connect(func(b): if b.is_in_group("players"): near_auntie_seat = false; if prompt_auntie_seat: prompt_auntie_seat.visible = false)

	if girl_stand_npc:
		girl_stand_npc.body_entered.connect(func(b): if b.is_in_group("players"): near_girl_stand = true; if prompt_girl_stand: prompt_girl_stand.visible = true)
		girl_stand_npc.body_exited.connect(func(b): if b.is_in_group("players"): near_girl_stand = false; if prompt_girl_stand: prompt_girl_stand.visible = false)

	if worker_stand_npc:
		worker_stand_npc.body_entered.connect(func(b): if b.is_in_group("players"): near_worker_stand = true; if prompt_worker_stand: prompt_worker_stand.visible = true)
		worker_stand_npc.body_exited.connect(func(b): if b.is_in_group("players"): near_worker_stand = false; if prompt_worker_stand: prompt_worker_stand.visible = false)

	if portal_exit:
		portal_exit.target_level = 4
		portal_exit.target_spawn_x = 100.0
		portal_exit.is_locked = true
		portal_exit.lock_message = "ต้องจ่ายค่ารถเมล์และดูแลคุณยายให้เรียบร้อยก่อนถึงสถานีนะจ๊ะ!"

	# Restore state if already paid/seated (e.g. reload)
	if GameManager.bus_fare_paid and conductor_badge:
		conductor_badge.text = "✅ ชำระเรียบร้อย ขอบคุณครับ! 🎟️"
		conductor_badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	if GameManager.grandma_seated:
		_apply_grandma_seated_visuals()

	if OS.get_environment("CAPTURE_BUS_INTERIOR") != "":
		_run_auto_capture_bus()

func _run_auto_capture_bus() -> void:
	# Close startup quest dialog for clean capture
	await get_tree().create_timer(0.25).timeout
	GameManager.dialog_closed.emit()

	await get_tree().create_timer(0.4).timeout
	var img = get_viewport().get_texture().get_image()
	if img:
		img.save_png("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/bus_interior_with_passengers.png")
		print("[AutoCapture] Saved bus_interior_with_passengers.png")

	# Interact with seated passenger to showcase dialogue
	GameManager.dialog_triggered.emit(
		"น้องอาร์ต (นักเรียน ป.2)",
		"สวัสดีของขวัญกับปีใหม่! พี่กำลังทบทวนคำศัพท์ภาษาอังกฤษก่อนถึงโรงเรียนจ้ะ วันนี้สองพี่น้องมาเช้ามากเลยนะ! 📚 ✨",
		"res://assets/characters/npcs/npc_student_seated.png"
	)
	await get_tree().create_timer(0.4).timeout
	var img2 = get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("C:/Users/ABHISIT MARATCHA/.gemini/antigravity/brain/1f9a33c3-d63c-4664-85d2-bb6dc9f3f6c6/bus_interior_dialog_preview.png")
		print("[AutoCapture] Saved bus_interior_dialog_preview.png")

	get_tree().quit()

func _process(delta: float) -> void:
	super._process(delta)

	var t := Time.get_ticks_msec() * 0.001

	# 1. Parallax street scenery continuous scroll outside windows
	if scenery_1 and scenery_2:
		scenery_1.position.x -= scroll_speed * delta
		scenery_2.position.x -= scroll_speed * delta
		if scenery_1.position.x <= -1280.0:
			scenery_1.position.x = scenery_2.position.x + 2560.0
		if scenery_2.position.x <= -1280.0:
			scenery_2.position.x = scenery_1.position.x + 2560.0

	# 2. Subtle road vibration / suspension bounce
	var bus_bounce := sin(t * 16.0) * 0.35
	if bus_shell:
		bus_shell.position.y = 360.0 + bus_bounce
	if bus_seats:
		bus_seats.position.y = bus_bounce

	# 3. Hanging straps swinging pendulums
	if hanging_straps:
		for i in range(hanging_straps.get_child_count()):
			var strap := hanging_straps.get_child(i) as Sprite2D
			if strap:
				strap.rotation = sin(t * 2.4 + i * 0.85) * 0.08

	# 4. NPC gentle idle breathing & bus suspension bounce
	if conductor_sprite:
		conductor_sprite.position.y = -10.0 + sin(t * 3.0) * 1.6
	if grandma_sprite and not GameManager.grandma_seated:
		grandma_sprite.position.y = -10.0 + sin(t * 2.5) * 1.4

	# Passenger gentle bobs
	if student_seat_sprite:
		student_seat_sprite.position.y = -18.0 + sin(t * 16.0) * 0.4
	if auntie_seat_sprite:
		auntie_seat_sprite.position.y = -18.0 + sin(t * 16.0 + 1.0) * 0.4
	if girl_stand_sprite:
		girl_stand_sprite.position.y = -15.0 + sin(t * 2.8) * 1.2
	if worker_stand_sprite:
		worker_stand_sprite.position.y = -15.0 + sin(t * 2.6 + 0.8) * 1.2

	# 5. Floating badges
	if conductor_badge:
		conductor_badge.position.y = -88.0 + sin(t * 1.8) * 3.0
	if grandma_badge:
		grandma_badge.position.y = -88.0 + sin(t * 1.8 + 1.2) * 3.0

	# 6. Interaction handling
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	if near_conductor and interact_pressed and not GameManager.bus_fare_paid:
		GameManager.purse_opened.emit(16, "ค่าโดยสารนักเรียน 2 คน (คนละ 8 บาท)", _on_fare_paid)
	elif near_grandma and interact_pressed and not GameManager.grandma_seated:
		_on_grandma_assisted()
	elif near_bell and interact_pressed:
		_on_bell_pressed()
	elif near_student_seat and interact_pressed:
		GameManager.dialog_triggered.emit(
			"น้องอาร์ต (นักเรียน ป.2)",
			"สวัสดีของขวัญกับปีใหม่! พี่กำลังทบทวนคำศัพท์ภาษาอังกฤษก่อนถึงโรงเรียนจ้ะ วันนี้สองพี่น้องมาเช้ามากเลยนะ! 📚 ✨",
			"res://assets/characters/npcs/npc_student_seated.png"
		)
	elif near_auntie_seat and interact_pressed:
		GameManager.dialog_triggered.emit(
			"ป้าสมร (แม่ค้าตลาด)",
			"วันนี้นักเรียนขึ้นรถเยอะคึกคักดีจังเลยนะจ๊ะ ดีใจที่เห็นหนูๆ มีน้ำใจสละที่นั่งให้คนแก่ ขอให้เดินทางปลอดภัยจ้า! 🌸",
			"res://assets/characters/npcs/npc_auntie_seated.png"
		)
	elif near_girl_stand and interact_pressed:
		GameManager.dialog_triggered.emit(
			"พี่แป้ง (นักเรียน ม.ต้น)",
			"จับห่วงยึดเหนี่ยวให้แน่นๆ นะน้องปีใหม่! รถเมล์วิ่งเร็วตอนเข้าโค้ง ต้องระวังไม่ให้ลื่นล้มจ้ะ 🚌",
			"res://assets/characters/npcs/npc_student_standing_strap.png"
		)
	elif near_worker_stand and interact_pressed:
		GameManager.dialog_triggered.emit(
			"พี่เบิร์ด (คนทำงาน)",
			"เตรียมเหรียญค่ารถเมล์ไว้ล่วงหน้าช่วยให้คุณกระเป๋ารถเมล์ทำงานสะดวกขึ้นเยอะเลย เก่งมากครับเด็กๆ! 🎟️",
			"res://assets/characters/npcs/npc_worker_standing_strap.png"
		)

func _on_bell_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("bus_bell")
	bell_pressed = true
	if bell_sprite:
		var tw := create_tween()
		tw.tween_property(bell_sprite, "scale", Vector2(0.95, 0.95), 0.08)
		tw.tween_property(bell_sprite, "scale", Vector2(0.75, 0.75), 0.12)
	if bell_label:
		bell_label.text = "🔔 กริ่งดังแล้ว! STOP"
		bell_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.3))
	GameManager.dialog_triggered.emit(
		"กริ่งสัญญาณรถเมล์",
		"กริ๊งงงงง! 🔔 ผู้โดยสารกดกริ่งส่งสัญญาณเรียบร้อย คนขับกำลังเตรียมเทียบชานชาลาสถานีข้างหน้าอย่างปลอดภัยจ้า!",
		"res://assets/environment/bus_3d/bus_stop_bell.png"
	)

func _on_fare_paid() -> void:
	if AudioManager:
		AudioManager.play_sfx("coin")
	GameManager.bus_fare_paid = true
	GameManager.add_star()
	if conductor_badge:
		conductor_badge.text = "✅ ชำระเรียบร้อย ขอบคุณครับ! 🎟️"
		conductor_badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	GameManager.dialog_triggered.emit("กระเป๋ารถเมล์", "รับเงิน 16 บาทเรียบร้อยจ้ะ! (จ่ายธนบัตร 20 บาท ทอน 4 บาทถูกต้อง เก่งมาก!) 🎟️", "res://assets/characters/npcs/portrait_conductor.png")
	_check_level_done()

func _on_grandma_assisted() -> void:
	GameManager.grandma_seated = true
	GameManager.complete_good_deed("q_bus_seat")
	_apply_grandma_seated_visuals()
	GameManager.dialog_triggered.emit("คุณยาย", "ขอบใจหนูๆ มากนะจ๊ะที่สละที่นั่งให้คนแก่! สองพี่น้องมีน้ำใจมาก ได้รับทั้งแต้มความดีและดาวมารยาทดีจ้ะ! ⭐", "res://assets/characters/npcs/portrait_grandma.png")
	_check_level_done()

func _apply_grandma_seated_visuals() -> void:
	if grandma_sprite and seated_grandma_texture:
		grandma_sprite.texture = seated_grandma_texture
		grandma_sprite.position = Vector2(0, 0)
		var tw := create_tween()
		tw.tween_property(grandma_sprite, "scale", Vector2(0.9, 0.9), 0.15)
		tw.tween_property(grandma_sprite, "scale", Vector2(0.78, 0.78), 0.2)
	if grandma_npc:
		grandma_npc.position = Vector2(820, 485)
	var grandma_lbl := get_node_or_null("GrandmaArea/Label") as Label
	if grandma_lbl:
		grandma_lbl.text = "คุณยายนั่งสบายใจ"
	if prompt_grandma:
		prompt_grandma.visible = false
	if grandma_badge:
		grandma_badge.text = "✅ คุณยายนั่งพักแล้ว ขอบใจจ้ะ! ❤️"
		grandma_badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))

func _check_level_done() -> void:
	if GameManager.bus_fare_paid and GameManager.grandma_seated and portal_exit:
		portal_exit.is_locked = false
		GameManager.dialog_triggered.emit("คนขับรถเมล์", "ถึงสถานีขนส่งแล้วจ้า! ผู้โดยสารโปรดลงอย่างระมัดระวัง 🚌", "res://assets/characters/npcs/portrait_conductor.png")
