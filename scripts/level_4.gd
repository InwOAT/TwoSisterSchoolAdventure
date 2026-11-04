extends BaseLevel

@onready var portal_school: MaplePortal = $PortalSchool

# Songthaew Door Marker & Glowing Light Circle
@onready var door_marker: Node2D = get_node_or_null("SongthaewDoorMarker")
@onready var light_circle: Sprite2D = get_node_or_null("SongthaewDoorMarker/LightCircle")
@onready var vertical_beam: Sprite2D = get_node_or_null("SongthaewDoorMarker/VerticalBeam")
@onready var boarding_sign: Label = get_node_or_null("SongthaewDoorMarker/BoardingSign")

# Quest Badges
@onready var badge_board: Label = get_node_or_null("InteractiveZones/BoardArea/QuestBadge")
@onready var badge_grandma: Label = get_node_or_null("InteractiveZones/GrandmaArea/QuestBadge")
@onready var badge_blue: Label = get_node_or_null("InteractiveZones/BlueArea/QuestBadge")
@onready var grandma_quiz_modal: CanvasLayer = get_node_or_null("GrandmaQuizModal")

var near_board: bool = false
var near_master: bool = false
var near_grandma: bool = false
var near_red: bool = false
var near_green: bool = false
var near_blue: bool = false
var on_blue_bus: bool = false
var board_inspected: bool = false

func _ready() -> void:
	level_number = 4
	add_maple_platforms = false
	super._ready()

	GameManager.start_good_deed("q_terminal_grandma")

	if grandma_quiz_modal:
		grandma_quiz_modal.quiz_completed.connect(func():
			_update_badges()
			_update_portal_state()
		)

	if portal_school:
		portal_school.target_level = 5
		portal_school.target_spawn_x = 100.0
		_update_portal_state()

	# Area connections
	$InteractiveZones/BoardArea.body_entered.connect(func(b): if b.is_in_group("players"): near_board = true; $InteractiveZones/BoardArea/PromptLabel.visible = true)
	$InteractiveZones/BoardArea.body_exited.connect(func(b): if b.is_in_group("players"): near_board = false; $InteractiveZones/BoardArea/PromptLabel.visible = false)

	$InteractiveZones/MasterArea.body_entered.connect(func(b): if b.is_in_group("players"): near_master = true; $InteractiveZones/MasterArea/PromptLabel.visible = true)
	$InteractiveZones/MasterArea.body_exited.connect(func(b): if b.is_in_group("players"): near_master = false; $InteractiveZones/MasterArea/PromptLabel.visible = false)

	$InteractiveZones/GrandmaArea.body_entered.connect(func(b): if b.is_in_group("players"): near_grandma = true; $InteractiveZones/GrandmaArea/PromptLabel.visible = true)
	$InteractiveZones/GrandmaArea.body_exited.connect(func(b): if b.is_in_group("players"): near_grandma = false; $InteractiveZones/GrandmaArea/PromptLabel.visible = false)

	$InteractiveZones/RedArea.body_entered.connect(func(b): if b.is_in_group("players"): near_red = true; $InteractiveZones/RedArea/PromptLabel.visible = true)
	$InteractiveZones/RedArea.body_exited.connect(func(b): if b.is_in_group("players"): near_red = false; $InteractiveZones/RedArea/PromptLabel.visible = false)

	$InteractiveZones/GreenArea.body_entered.connect(func(b): if b.is_in_group("players"): near_green = true; $InteractiveZones/GreenArea/PromptLabel.visible = true)
	$InteractiveZones/GreenArea.body_exited.connect(func(b): if b.is_in_group("players"): near_green = false; $InteractiveZones/GreenArea/PromptLabel.visible = false)

	$InteractiveZones/BlueArea.body_entered.connect(func(b): if b.is_in_group("players"): near_blue = true; $InteractiveZones/BlueArea/PromptLabel.visible = true)
	$InteractiveZones/BlueArea.body_exited.connect(func(b): if b.is_in_group("players"): near_blue = false; $InteractiveZones/BlueArea/PromptLabel.visible = false)

	_update_badges()
	_update_portal_state()

	# Guidance dialog on entering
	if not GameManager.songthaew_correct:
		get_tree().create_timer(0.4).timeout.connect(func():
			GameManager.dialog_triggered.emit(
				"พี่ของขวัญ & น้องปีใหม่",
				"ถึงสถานีขนส่งสองแถวแล้ว! มีรถสองแถวจอดอยู่ 3 คัน พวกเราไปดูตารางเดินรถ และเลือกขึ้นคันสีฟ้าที่ผ่านโรงเรียนกันเถอะ! 🚏",
				""
			)
		)

func _get_level_width() -> float:
	return 1800.0

func _process(delta: float) -> void:
	super._process(delta)

	# Camera smoothly tracks both players up to right wall (x: 1800)
	if camera and p1 and p2:
		var mid_x := (p1.global_position.x + p2.global_position.x) * 0.5
		camera.global_position.x = clampf(mid_x, 640.0, 1160.0)

	# Animate glowing light circle & vertical beam
	if light_circle:
		var pulse := 0.88 + sin(Time.get_ticks_msec() * 0.005) * 0.14
		light_circle.scale = Vector2(0.9 * pulse, 0.9 * pulse)
	if vertical_beam:
		vertical_beam.modulate.a = 0.65 + sin(Time.get_ticks_msec() * 0.004) * 0.28

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if not interact_pressed:
		return

	if near_board:
		_inspect_board()
	elif near_master:
		_talk_master()
	elif near_grandma:
		_help_grandma()
	elif near_red:
		_choose_red()
	elif near_green:
		_choose_green()
	elif near_blue:
		_choose_blue()

func _is_grandma_done() -> bool:
	var grandma_dict = GameManager.good_deeds.get("q_terminal_grandma", {})
	return (grandma_dict is Dictionary and grandma_dict.get("status", "") == "completed")

func _update_portal_state() -> void:
	if not portal_school:
		return
	var grandma_done := _is_grandma_done()
	if GameManager.songthaew_correct and grandma_done:
		portal_school.is_locked = false
		portal_school.portal_name = "ขึ้นสองแถวสีฟ้าไป ร.ร. [ขึ้นรถได้เลย! ✨]"
		if boarding_sign:
			boarding_sign.text = "🔵 จุดขึ้นสองแถวสีฟ้า [เปิดแล้ว! ✨]"
			boarding_sign.modulate = Color(0.4, 1.0, 0.7)
		if light_circle:
			light_circle.modulate = Color(0.18, 1.0, 0.85, 0.98) # เขียว-ฟ้าสดใส (Emerald Cyan)
		if vertical_beam:
			vertical_beam.modulate = Color(0.25, 1.0, 0.88, 0.92)
	else:
		portal_school.is_locked = true
		portal_school.portal_name = "ขึ้นสองแถวไป ร.ร. [ทำเควสก่อน]"
		var missing: Array[String] = []
		if not grandma_done:
			missing.append("• ช่วยบอกทางคุณยายไปขึ้นรถสองแถวสีเขียว (ไปโรงพยาบาล) 👵")
		if not GameManager.songthaew_correct:
			missing.append("• เดินไปเลือกขึ้นรถสองแถวสีฟ้าที่ชานชาลา 3 🔵")
		portal_school.lock_message = "ยังออกเดินทางไม่ได้จ้ะ! ทำภารกิจที่สถานีขนส่งให้ครบก่อนนะ:\n" + "\n".join(missing)
		if boarding_sign:
			boarding_sign.text = "🔵 จุดขึ้นสองแถวสีฟ้าไป ร.ร. [ประตูปิด]"
			boarding_sign.modulate = Color(1.0, 0.7, 0.25)
		if light_circle:
			light_circle.modulate = Color(1.0, 0.18, 0.22, 0.98) # สีแดงสด (Crimson Red)
		if vertical_beam:
			vertical_beam.modulate = Color(1.0, 0.25, 0.25, 0.85)

func _update_badges() -> void:
	if badge_board:
		if board_inspected:
			badge_board.text = "✅ อ่านตารางเดินรถแล้ว"
			badge_board.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_board.text = "💡 เควสตารางเดินรถสองแถว [!]"
			badge_board.modulate = Color(1.0, 0.9, 0.3)

	if badge_grandma:
		var grandma_dict = GameManager.good_deeds.get("q_terminal_grandma", {})
		var grandma_done: bool = (grandma_dict is Dictionary and grandma_dict.get("status", "") == "completed")
		if grandma_done:
			badge_grandma.text = "✅ ช่วยบอกทางคุณยายแล้ว"
			badge_grandma.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_grandma.text = "💡 เควสช่วยคุณยายบอกทาง [!]"
			badge_grandma.modulate = Color(1.0, 0.9, 0.3)

	if badge_blue:
		if GameManager.songthaew_correct:
			badge_blue.text = "✅ รถสองแถวสีฟ้าถูกต้อง! [ขึ้นรถได้เลย]"
			badge_blue.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_blue.text = "💡 รถสองแถวสีฟ้าไป ร.ร. [!]"
			badge_blue.modulate = Color(0.4, 0.85, 1.0)

func _inspect_board() -> void:
	board_inspected = true
	if AudioManager:
		AudioManager.play_sfx("star")
	GameManager.dialog_triggered.emit(
		"ป้ายตารางเดินรถประจำสถานีขนส่ง",
		"【ตารางเดินรถสองแถวประจำทาง】\n🔴 ชานชาลา 1 รถสีแดง: ไปตลาดสดเทศบาล\n🟢 ชานชาลา 2 รถสีเขียว: ไปโรงพยาบาลชุมชนหนองเรือ\n🔵 ชานชาลา 3 รถสีฟ้า: ผ่านโรงเรียนอนุบาล & ประถมชุมชนหนองเรือ!\n(นักเรียนต้องขึ้นคันสีฟ้าชานชาลา 3 จ้า!) 🚏 ⭐",
		"res://assets/environment/bus_timetable_stand.png"
	)
	_update_badges()

func _talk_master() -> void:
	GameManager.dialog_triggered.emit(
		"นายสถานีขนส่ง",
		"สวัสดีจ้ะสองพี่น้อง! สถานีขนส่งสองแถวดอนโมง-หนองเรือยินดีต้อนรับ รถออกทุก 10 นาที ตรวจสอบป้ายปลายทางและขึ้นให้ถูกคันนะจ๊ะ! 🎟️",
		"res://assets/characters/npcs/npc_station_master.png"
	)

func _help_grandma() -> void:
	var grandma_dict = GameManager.good_deeds.get("q_terminal_grandma", {})
	var grandma_done: bool = (grandma_dict is Dictionary and grandma_dict.get("status", "") == "completed")
	if not grandma_done:
		if grandma_quiz_modal:
			grandma_quiz_modal.open_quiz()
		else:
			GameManager.complete_good_deed("q_terminal_grandma")
			if AudioManager:
				AudioManager.play_sfx("sister_cheer")
			GameManager.dialog_triggered.emit(
				"คุณยายใจดี",
				"ขอบใจหนูๆ มากนะจ๊ะ! ยายสายตาไม่ค่อยดี กำลังหาคันไปหาหมอที่โรงพยาบาลพอดี สองพี่น้องชี้ทางให้ยายไปขึ้น 'คันสีเขียวชานชาลา 2' ได้ถูกต้อง น่ารักและมีน้ำใจต่อคนชรามากจ้ะ! 💖 ⭐",
				"res://assets/characters/npcs/npc_grandma.png"
			)
			_update_badges()
	else:
		GameManager.dialog_triggered.emit(
			"คุณยายใจดี",
			"ยายได้ขึ้นรถสองแถวสีเขียวไปโรงพยาบาลแล้วจ้ะ ขอให้เด็กดีเรียนเก่งๆ ปลอดภัยนะลูก! 🌸",
			"res://assets/characters/npcs/npc_grandma.png"
		)

func _choose_red() -> void:
	if AudioManager:
		AudioManager.play_sfx("wrong")
	GameManager.dialog_triggered.emit(
		"คนขับสองแถวคันสีแดง",
		"คันสีแดงไปตลาดสดเทศบาลจ้า! ไม่ได้ผ่านโรงเรียนนะหนูๆ เดินเลยไปชานชาลา 3 ทางขวาเพื่อขึ้นคันสีฟ้านะจ๊ะ! 🔴",
		"res://assets/environment/songthaew_red.png"
	)

func _choose_green() -> void:
	if AudioManager:
		AudioManager.play_sfx("wrong")
	GameManager.dialog_triggered.emit(
		"คนขับสองแถวคันสีเขียว",
		"คันสีเขียวไปโรงพยาบาลชุมชนจ้า! ไม่ได้ไปโรงเรียนนะเด็กๆ ให้เดินเลยไปชานชาลา 3 ทางขวาเพื่อขึ้นคันสีฟ้าลูก! 🟢",
		"res://assets/environment/songthaew_green.png"
	)

func _choose_blue() -> void:
	if not _is_grandma_done():
		if AudioManager:
			AudioManager.play_sfx("wrong")
		GameManager.dialog_triggered.emit(
			"คนขับสองแถวคันสีฟ้า",
			"เดี๋ยวก่อนจ้าเด็กๆ! คุณยายที่ยืนอยู่กลางสถานีเหมือนกำลังหลงทางหาคันไปโรงพยาบาลอยู่เลย แวะไปช่วยบอกทางคุณยายก่อนมาขึ้นรถนะจ๊ะ! 👵💖",
			"res://assets/environment/songthaew_blue.png"
		)
		return

	on_blue_bus = true
	GameManager.songthaew_correct = true
	GameManager.add_star()
	if AudioManager:
		AudioManager.play_sfx("sister_cheer")
	_update_portal_state()
	_update_badges()
	GameManager.dialog_triggered.emit(
		"คนขับสองแถวคันสีฟ้า",
		"ถูกต้องแล้วจ้า! รถสองแถวสีฟ้าสายผ่านโรงเรียนชุมชนหนองเรือพอดี! ก้าวขึ้นบันไดท้ายรถตรงวงกลมแสงได้เลยจ้ะ เมื่อถึงหน้าโรงเรียนให้กดกริ่งลงรถอย่างปลอดภัยนะ! 🔵 ✨ ⭐",
		"res://assets/environment/songthaew_blue.png"
	)
