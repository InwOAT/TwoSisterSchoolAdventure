extends BaseLevel

@onready var portal_village: MaplePortal = $PortalVillage
@onready var passenger_woman: Area2D = $PassengerWoman
@onready var stranger_man: Area2D = $StrangerMan
@onready var wallet_item: InteractableItem = $ItemWallet
@onready var btn_refuse: Button = $StrangerMan/ChoiceContainer/BtnRefuse
@onready var btn_accept: Button = $StrangerMan/ChoiceContainer/BtnAccept

@onready var scenery_1: Sprite2D = get_node_or_null("OutsideScenery/ScenerySprite1")
@onready var scenery_2: Sprite2D = get_node_or_null("OutsideScenery/ScenerySprite2")
@onready var hanging_straps: Node2D = get_node_or_null("HangingStraps")
@onready var bus_shell: Sprite2D = get_node_or_null("BusShell")
@onready var bus_seats: Node2D = get_node_or_null("BusSeats")

var near_woman: bool = false
var near_stranger: bool = false
var near_grandma: bool = false
var near_standing: bool = false
var near_conductor: bool = false
var near_bell: bool = false
var bell_pressed: bool = false
var scroll_speed: float = 75.0

var bell_sprite: Sprite2D = null
var bell_label: Label = null
var badge_woman: Label = null
var badge_stranger: Label = null

func _ready() -> void:
	level_number = 10
	super._ready()

	GameManager.start_good_deed("q_return_wallet")

	if passenger_woman:
		passenger_woman.body_entered.connect(func(b): if b.is_in_group("players"): near_woman = true; $PassengerWoman/PromptLabel.visible = true)
		passenger_woman.body_exited.connect(func(b): if b.is_in_group("players"): near_woman = false; $PassengerWoman/PromptLabel.visible = false)

	if stranger_man:
		stranger_man.body_entered.connect(func(b): if b.is_in_group("players"): near_stranger = true; $StrangerMan/PromptLabel.visible = true)
		stranger_man.body_exited.connect(func(b): if b.is_in_group("players"): near_stranger = false; $StrangerMan/PromptLabel.visible = false)

	if btn_refuse: btn_refuse.pressed.connect(refuse_stranger)
	if btn_accept: btn_accept.pressed.connect(accept_stranger_wrong)

	_setup_extra_bus_interactions()

	if portal_village:
		portal_village.target_level = 11
		portal_village.target_spawn_x = 100.0
		_update_portal()

	if wallet_item:
		wallet_item.visible = not GameManager.has_item("กระเป๋าสตางค์") and not GameManager.wallet_returned

	_update_badges()

func _setup_extra_bus_interactions() -> void:
	var shape := CircleShape2D.new()
	shape.radius = 46.0

	# 1. Quest Badges on Woman & Stranger
	if passenger_woman:
		badge_woman = _create_quest_badge(passenger_woman, Vector2(0, -106))
	if stranger_man:
		badge_stranger = _create_quest_badge(stranger_man, Vector2(0, -112))

	# 2. Grandma seated interaction
	var gma_node := get_node_or_null("PassengerGrandma") as Node2D
	if gma_node:
		var gma_area := Area2D.new()
		gma_area.collision_layer = 0
		gma_area.collision_mask = 2
		var col := CollisionShape2D.new()
		col.shape = shape
		gma_area.add_child(col)
		var pr := _create_prompt_label("[E/Shift] ทักทายคุณยาย", Vector2(0, -104))
		gma_area.add_child(pr)
		gma_node.add_child(gma_area)
		gma_area.body_entered.connect(func(b): if b.is_in_group("players"): near_grandma = true; pr.visible = true)
		gma_area.body_exited.connect(func(b): if b.is_in_group("players"): near_grandma = false; pr.visible = false)

	# 3. Standing Student (Nong Peach) interaction
	var stand_node := get_node_or_null("PassengerStanding") as Node2D
	if stand_node:
		var st_area := Area2D.new()
		st_area.collision_layer = 0
		st_area.collision_mask = 2
		var col := CollisionShape2D.new()
		col.shape = shape
		st_area.add_child(col)
		var pr := _create_prompt_label("[E/Shift] คุยกับน้องพีช", Vector2(0, -110))
		st_area.add_child(pr)
		stand_node.add_child(st_area)
		st_area.body_entered.connect(func(b): if b.is_in_group("players"): near_standing = true; pr.visible = true)
		st_area.body_exited.connect(func(b): if b.is_in_group("players"): near_standing = false; pr.visible = false)

	# 4. Conductor interaction
	var cond_node := get_node_or_null("ConductorSprite") as Node2D
	if cond_node:
		cond_node.position.x = 1005.0
		var cond_area := Area2D.new()
		cond_area.collision_layer = 0
		cond_area.collision_mask = 2
		var col := CollisionShape2D.new()
		col.shape = shape
		cond_area.add_child(col)
		var pr := _create_prompt_label("[E/Shift] คุยกับพี่กระเป๋ารถเมล์", Vector2(0, -110))
		cond_area.add_child(pr)
		cond_node.add_child(cond_area)
		cond_area.body_entered.connect(func(b): if b.is_in_group("players"): near_conductor = true; pr.visible = true)
		cond_area.body_exited.connect(func(b): if b.is_in_group("players"): near_conductor = false; pr.visible = false)

	# 5. Bus Stop Bell before PortalVillage
	var bell_area := Area2D.new()
	bell_area.name = "BusStopBell"
	bell_area.position = Vector2(1110, 520)
	bell_area.collision_layer = 0
	bell_area.collision_mask = 2
	var b_col := CollisionShape2D.new()
	b_col.shape = shape
	bell_area.add_child(b_col)

	if ResourceLoader.exists("res://assets/environment/bus_3d/bus_stop_bell.png"):
		bell_sprite = Sprite2D.new()
		bell_sprite.texture = load("res://assets/environment/bus_3d/bus_stop_bell.png")
		bell_sprite.position = Vector2(0, -60)
		bell_sprite.scale = Vector2(0.75, 0.75)
		bell_area.add_child(bell_sprite)

	bell_label = Label.new()
	bell_label.text = "🔴 กริ่งลงรถ STOP"
	bell_label.offset_left = -58.0
	bell_label.offset_top = -15.0
	bell_label.offset_right = 58.0
	bell_label.offset_bottom = 6.0
	bell_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bell_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bell_label.add_theme_font_size_override("font_size", 10)
	bell_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.85))
	var tag_sb := StyleBoxFlat.new()
	tag_sb.bg_color = Color(0.06, 0.1, 0.18, 0.88)
	tag_sb.border_color = Color(0.4, 0.75, 1.0, 0.85)
	tag_sb.set_border_width_all(1)
	tag_sb.set_corner_radius_all(6)
	bell_label.add_theme_stylebox_override("normal", tag_sb)
	bell_area.add_child(bell_label)

	var bell_prompt := _create_prompt_label("[E/Shift] กดกริ่งลงรถ 🔔", Vector2(0, -120))
	bell_area.add_child(bell_prompt)
	add_child(bell_area)
	bell_area.body_entered.connect(func(b): if b.is_in_group("players"): near_bell = true; bell_prompt.visible = true)
	bell_area.body_exited.connect(func(b): if b.is_in_group("players"): near_bell = false; bell_prompt.visible = false)

func _create_prompt_label(txt: String, pos: Vector2) -> Label:
	var lbl := Label.new()
	lbl.text = txt
	lbl.visible = false
	lbl.offset_left = pos.x - 85.0
	lbl.offset_right = pos.x + 85.0
	lbl.offset_top = pos.y - 14.0
	lbl.offset_bottom = pos.y + 14.0
	if GameManager:
		GameManager.style_prompt_label(lbl)
	return lbl

func _create_quest_badge(parent_node: Node, pos: Vector2) -> Label:
	var lbl := Label.new()
	lbl.offset_left = pos.x - 80.0
	lbl.offset_right = pos.x + 80.0
	lbl.offset_top = pos.y - 11.0
	lbl.offset_bottom = pos.y + 11.0
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 11)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.1, 0.04, 0.92)
	sb.border_color = Color(1.0, 0.85, 0.2, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	lbl.add_theme_stylebox_override("normal", sb)
	parent_node.add_child(lbl)
	return lbl

func _update_badges() -> void:
	if badge_woman:
		if GameManager.wallet_returned:
			badge_woman.text = "✅ คืนกระเป๋าสตางค์แล้ว"
			badge_woman.modulate = Color(0.4, 1.0, 0.55)
		elif GameManager.has_item("กระเป๋าสตางค์"):
			badge_woman.text = "💡 ส่งคืนกระเป๋าสตางค์ [!]"
			badge_woman.modulate = Color(0.4, 1.0, 0.55)
		else:
			badge_woman.text = "💡 ทำกระเป๋าสตางค์หล่น [!]"
			badge_woman.modulate = Color(1.0, 0.9, 0.3)
	if badge_stranger:
		if GameManager.stranger_refused:
			badge_stranger.text = "✅ ปฏิเสธคนแปลกหน้าแล้ว"
			badge_stranger.modulate = Color(0.4, 1.0, 0.55)
		else:
			badge_stranger.text = "⚠️ ระวังคนแปลกหน้า [!]"
			badge_stranger.modulate = Color(1.0, 0.7, 0.3)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if $StrangerMan/ChoiceContainer.visible:
			if event.physical_keycode == KEY_1 or event.physical_keycode == KEY_A:
				refuse_stranger()
				get_viewport().set_input_as_handled()
			elif event.physical_keycode == KEY_2 or event.physical_keycode == KEY_B:
				accept_stranger_wrong()
				get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	super._process(delta)

	# Scenery parallax scrolling
	if scenery_1 and scenery_2:
		scenery_1.position.x -= scroll_speed * delta
		scenery_2.position.x -= scroll_speed * delta
		if scenery_1.position.x <= -1280.0:
			scenery_1.position.x = scenery_2.position.x + 2560.0
		if scenery_2.position.x <= -1280.0:
			scenery_2.position.x = scenery_1.position.x + 2560.0

	# Swaying hanging straps
	if hanging_straps:
		var t := Time.get_ticks_msec() * 0.003
		var i := 0
		for child in hanging_straps.get_children():
			if child is Sprite2D:
				child.rotation = sin(t + i * 0.8) * 0.12
				i += 1

	# Subtle road vibration
	var t_sec := Time.get_ticks_msec() * 0.001
	var bus_bounce := sin(t_sec * 16.0) * 0.35
	if bus_shell:
		bus_shell.position.y = 360.0 + bus_bounce
	if bus_seats:
		bus_seats.position.y = bus_bounce

	_update_badges()

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	if near_woman and interact_pressed:
		if GameManager.has_item("กระเป๋าสตางค์"):
			GameManager.remove_item("กระเป๋าสตางค์")
			GameManager.wallet_returned = true
			GameManager.complete_good_deed("q_return_wallet")
			GameManager.dialog_triggered.emit("พี่ผู้โดยสาร", "โอ้โห! ขอบคุณน้องๆ มากนะจ๊ะ พี่ทำหล่นตอนรถเลี้ยวพอดี สองพี่น้องซื่อสัตย์น่ารักมากเลย! ⭐ ได้รับแต้มความดีและดาวมารยาทดี!", "res://assets/characters/npcs/npc_girl_student.png")
			_update_portal()
			_update_badges()
		elif not GameManager.wallet_returned:
			GameManager.dialog_triggered.emit("พี่ผู้โดยสาร", "เอ๊ะ กระเป๋าสตางค์พี่หล่นไปอยู่ตรงไหนนะ? น้องๆ ช่วยดูที่พื้นรถหน่อยได้ไหมจ๊ะ", "res://assets/characters/npcs/npc_girl_student.png")
		else:
			GameManager.dialog_triggered.emit("พี่ผู้โดยสาร", "ขอบคุณสำหรับความซื่อสัตย์ของน้องๆ อีกครั้งนะจ๊ะ!", "res://assets/characters/npcs/npc_girl_student.png")
	elif near_stranger and interact_pressed:
		if not GameManager.stranger_refused:
			_stranger_encounter()
		else:
			GameManager.dialog_triggered.emit("พี่ของขวัญ & น้องปีใหม่", "พวกเราปฏิเสธคนแปลกหน้าอย่างสุภาพแล้ว อยู่ห่างๆ ไว้ปลอดภัยที่สุดจ้ะ! 🛡️", "")
	elif near_bell and interact_pressed:
		_on_bell_pressed()
	elif near_conductor and interact_pressed:
		GameManager.dialog_triggered.emit(
			"พี่กระเป๋ารถเมล์",
			"หากมีคนแปลกหน้ามารบกวน น้องๆ เดินมายืนใกล้พี่กระเป๋ารถเมล์ได้เลยนะจ๊ะ! ใกล้ถึงป้ายปากซอยหมู่บ้านดอนโมงแล้ว อย่าลืมกดกริ่งส่งสัญญาณด้วยนะ 🔔🚌",
			"res://assets/characters/npcs/portrait_conductor.png"
		)
	elif near_grandma and interact_pressed:
		GameManager.dialog_triggered.emit(
			"คุณยาย",
			"ขอบใจหนูของขวัญกับปีใหม่ที่สละที่นั่งให้ยายเมื่อเช้านะลูก ขากลับรถเมล์แอร์เย็นสบาย ยายนั่งพักสายตาเพลินเลยจ้ะ 🌸👵",
			"res://assets/characters/npcs/portrait_grandma.png"
		)
	elif near_standing and interact_pressed:
		GameManager.dialog_triggered.emit(
			"น้องพีช (นักเรียน)",
			"เมื่อกี้รถเลี้ยวโค้ง เหมือนเห็นกระเป๋าสตางค์ของพี่ผู้หญิงหล่นอยู่ที่พื้นใกล้ๆ นี้เลย! พวกเราช่วยกันเก็บคืนเจ้าของกันเถอะ 👛✨",
			"res://assets/characters/npcs/npc_student_standing_strap.png"
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
		"กริ๊งงงงง! 🔔 ส่งสัญญาณเตรียมลงป้ายหน้าปากซอยหมู่บ้านดอนโมงเรียบร้อยแล้วจ้า!",
		"res://assets/environment/bus_3d/bus_stop_bell.png"
	)

func _stranger_encounter() -> void:
	GameManager.dialog_triggered.emit("คนแปลกหน้า", "หนูๆ จ๊ะ ลุงมีลูกอมและขนมแสนอร่อยเต็มเลย ลงป้ายหน้าไปกินขนมกับลุงไหม?", "res://assets/characters/npcs/npc_stranger.png")
	$StrangerMan/ChoiceContainer.visible = true

func refuse_stranger() -> void:
	GameManager.stranger_refused = true
	GameManager.add_star()
	$StrangerMan/ChoiceContainer.visible = false
	GameManager.dialog_triggered.emit("พี่ของขวัญ & น้องปีใหม่", "ไม่ค่ะ! พวกเราไม่รับของจากคนแปลกหน้า และต้องรีบกลับบ้านไปหาคุณพ่อคุณแม่ค่ะ! (เดินไปยืนใกล้กระเป๋ารถเมล์อย่างปลอดภัย) ⭐ ได้รับดาวมารยาทดี!", "")
	_update_portal()
	_update_badges()

func accept_stranger_wrong() -> void:
	GameManager.dialog_triggered.emit("ระบบเตือนความปลอดภัย", "⚠️ อันตรายมาก! ห้ามรับขนมหรือตามคนแปลกหน้าไปเด็ดขาด! ต้องปฏิเสธอย่างสุภาพแล้วแจ้งผู้ใหญ่ทันทีนะจ๊ะ!", "")

func _update_portal() -> void:
	if not portal_village:
		return
	if GameManager.wallet_returned and GameManager.stranger_refused:
		portal_village.is_locked = false
	else:
		portal_village.is_locked = true
		portal_village.lock_message = "ต้องเก็บกระเป๋าสตางค์คืนพี่ผู้โดยสาร และระมัดระวังความปลอดภัยจากคนแปลกหน้าก่อนนะจ๊ะ! 👛🛡️"
