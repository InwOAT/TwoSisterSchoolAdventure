extends BaseLevel

@onready var portal_songthaew: MaplePortal = $PortalSongthaew
@onready var portal_bus: MaplePortal = $PortalBus

# Bus Door Marker & Glowing Light Circle
@onready var bus_door_marker: Node2D = get_node_or_null("BusDoorMarker")
@onready var light_circle: Sprite2D = get_node_or_null("BusDoorMarker/LightCircle")
@onready var vertical_beam: Sprite2D = get_node_or_null("BusDoorMarker/VerticalBeam")
@onready var boarding_sign: Label = get_node_or_null("BusDoorMarker/BoardingSign")

# Interactive areas
@onready var prompt_kiosk: Label = $InteractiveZones/DrinkKioskArea/PromptLabel
@onready var prompt_recycle: Label = $InteractiveZones/RecycleArea/PromptLabel
@onready var prompt_student: Label = $InteractiveZones/StudentWaitingArea/PromptLabel
@onready var prompt_timetable: Label = $InteractiveZones/TimetableArea/PromptLabel

# Quest Badges
@onready var badge_kiosk: Label = get_node_or_null("InteractiveZones/DrinkKioskArea/QuestBadge")
@onready var badge_timetable: Label = get_node_or_null("InteractiveZones/TimetableArea/QuestBadge")

var near_kiosk: bool = false
var near_recycle: bool = false
var near_student: bool = false
var near_timetable: bool = false

var return_timetable_checked: bool = false
var return_snack_bought: bool = false

func _ready() -> void:
	level_number = 95
	add_maple_platforms = false
	super._ready()

	if portal_songthaew:
		portal_songthaew.target_scene_path = "res://scenes/levels/level_9.tscn"
		portal_songthaew.target_level = 9
		portal_songthaew.target_spawn_x = 1100.0
		portal_songthaew.portal_name = "ย้อนกลับไปรถสองแถว"

	if portal_bus:
		portal_bus.target_scene_path = "res://scenes/levels/level_10.tscn"
		portal_bus.target_level = 10
		portal_bus.target_spawn_x = 100.0
		portal_bus.portal_name = "ขึ้นรถเมล์สาย 514 เพื่อกลับบ้าน"
		_check_bus_portal()

	# Connect interaction trigger areas
	$InteractiveZones/DrinkKioskArea.body_entered.connect(func(b): if b.is_in_group("players"): near_kiosk = true; if prompt_kiosk: prompt_kiosk.visible = true)
	$InteractiveZones/DrinkKioskArea.body_exited.connect(func(b): if b.is_in_group("players"): near_kiosk = false; if prompt_kiosk: prompt_kiosk.visible = false)

	$InteractiveZones/RecycleArea.body_entered.connect(func(b): if b.is_in_group("players"): near_recycle = true; if prompt_recycle: prompt_recycle.visible = true)
	$InteractiveZones/RecycleArea.body_exited.connect(func(b): if b.is_in_group("players"): near_recycle = false; if prompt_recycle: prompt_recycle.visible = false)

	$InteractiveZones/StudentWaitingArea.body_entered.connect(func(b): if b.is_in_group("players"): near_student = true; if prompt_student: prompt_student.visible = true)
	$InteractiveZones/StudentWaitingArea.body_exited.connect(func(b): if b.is_in_group("players"): near_student = false; if prompt_student: prompt_student.visible = false)

	$InteractiveZones/TimetableArea.body_entered.connect(func(b): if b.is_in_group("players"): near_timetable = true; if prompt_timetable: prompt_timetable.visible = true)
	$InteractiveZones/TimetableArea.body_exited.connect(func(b): if b.is_in_group("players"): near_timetable = false; if prompt_timetable: prompt_timetable.visible = false)

	_update_badges()

	# Welcome dialogue for Scene 9.5
	await get_tree().create_timer(0.4).timeout
	GameManager.dialog_triggered.emit(
		"พี่ของขวัญ & น้องปีใหม่",
		"🚏 ถึงท่ารถสถานีขนส่งแล้ว! พวกเราลงจากรถสองแถวเพื่อมาเปลี่ยนขึ้นรถเมล์สายหลัก (สาย 514) กลับบ้านกัน! อย่าลืมตรวจดูตารางเดินรถขากลับที่ป้ายนะจ๊ะ! 🚌✨",
		""
	)

func _get_level_width() -> float:
	return 2560.0

func _process(delta: float) -> void:
	super._process(delta)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	if interact_pressed:
		if near_timetable:
			_interact_timetable()
		elif near_kiosk:
			_interact_kiosk()
		elif near_recycle:
			_interact_recycle()
		elif near_student:
			_interact_student()

func _interact_timetable() -> void:
	return_timetable_checked = true
	GameManager.add_star()
	if AudioManager:
		AudioManager.play_sfx("correct")
	GameManager.dialog_triggered.emit(
		"ป้ายตารางเดินรถเมล์ขากลับ (สาย 514)",
		"🚏 ตารางเดินรถเมล์สาย 514 (ขากลับ): ออกทุก 15 นาที ผ่านถนนใหญ่ ตรงสู่ [ปากซอยหมู่บ้านดอนโมง] ค่าโดยสาร 8 บาท รถกำลังจอดรออยู่ที่ชานชาลาด้านขวาพร้อมออกเดินทางแล้วจ้ะ! 🚌 ⭐",
		""
	)
	_check_bus_portal()
	_update_badges()

func _interact_kiosk() -> void:
	if not return_snack_bought:
		return_snack_bought = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"ป้ามาลี (ร้านของว่างยามเย็น)",
			"สวัสดีจ้ะหลานๆ เลิกเรียนแล้วแวะดื่มน้ำเต้าหู้อุ่นๆ ซาลาเปาหอมๆ รองท้องก่อนขึ้นรถเมล์กลับบ้านนะจ๊ะ! เด็กดีตั้งใจเรียน ป้าแถมขนมให้ด้วยนะ! 🥛🥟 ⭐",
			"res://assets/characters/npcs/npc_auntie.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ป้ามาลี (ร้านของว่างยามเย็น)",
			"รีบไปขึ้นรถเมล์สาย 514 ขากลับบ้านนะจ๊ะลูก ระวังกระเป๋าสตางค์และคนแปลกหน้าบนรถด้วยนะ! 🚌✨",
			"res://assets/characters/npcs/npc_auntie.png"
		)
	_update_badges()

func _interact_recycle() -> void:
	if AudioManager:
		AudioManager.play_sfx("correct")
	GameManager.dialog_triggered.emit(
		"จุดคัดแยกขยะศาลาที่พักผู้โดยสาร",
		"♻️ ท่ารถสะอาดสดใส สองพี่น้องช่วยกันดูแลความสะอาด ทิ้งขยะลงถังคัดแยก 3 สีอย่างถูกต้อง น่ารักมากจ้ะ! 🌿",
		""
	)

func _interact_student() -> void:
	GameManager.dialog_triggered.emit(
		"พี่นักเรียน (รอรถเมล์กลับบ้าน)",
		"สวัสดีจ๊ะน้องๆ! กำลังจะขึ้นรถเมล์สาย 514 กลับบ้านเหมือนกันเลย วันนี้รถว่าง เดินขึ้นไปเลือกที่นั่งได้สบายเลยนะจ๊ะ แต่ต้องระวังข้าวของมีค่าหล่นหายด้วยนะ! 🎒 🚌",
		"res://assets/characters/npcs/npc_student.png"
	)

func _check_bus_portal() -> void:
	if not portal_bus:
		return

	if return_timetable_checked:
		portal_bus.is_locked = false
		portal_bus.lock_message = ""
		portal_bus.portal_name = "ขึ้นรถเมล์สาย 514 [ประตูเปิดแล้ว! ✨]"
		if boarding_sign:
			boarding_sign.text = "🚌 ประตูขึ้นรถเมล์สาย 514 [เปิดแล้ว! ✨]"
			boarding_sign.modulate = Color(0.4, 1.0, 0.7)
		if light_circle:
			light_circle.modulate = Color(0.18, 1.0, 0.85, 0.98) # Emerald Cyan
		if vertical_beam:
			vertical_beam.modulate = Color(0.25, 1.0, 0.88, 0.92)
	else:
		portal_bus.is_locked = true
		portal_bus.portal_name = "ขึ้นรถเมล์สาย 514 [ประตูปิดอยู่]"
		portal_bus.lock_message = "แวะตรวจดูตารางเดินรถเมล์สาย 514 ขากลับที่ป้าย [ตารางเดินรถ] ก่อนขึ้นรถนะจ๊ะ! 🚏"
		if boarding_sign:
			boarding_sign.text = "🚌 ประตูขึ้นรถเมล์สาย 514 [รอตรวจตาราง]"
			boarding_sign.modulate = Color(1.0, 0.7, 0.25)
		if light_circle:
			light_circle.modulate = Color(1.0, 0.18, 0.22, 0.98) # Red
		if vertical_beam:
			vertical_beam.modulate = Color(1.0, 0.25, 0.25, 0.85)

func _update_badges() -> void:
	if badge_timetable:
		if return_timetable_checked:
			badge_timetable.text = "✅ ตรวจตารางรถเมล์ขากลับเรียบร้อย"
			badge_timetable.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_timetable.text = "💡 ตรวจตารางรถเมล์สาย 514 ขากลับ [!]"
			badge_timetable.modulate = Color(1.0, 0.9, 0.3)

	if badge_kiosk:
		if return_snack_bought:
			badge_kiosk.text = "✅ แวะดื่มน้ำเต้าหู้รองท้องแล้ว"
			badge_kiosk.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_kiosk.text = "💡 ร้านของว่างยามเย็นป้ามาลี [!]"
			badge_kiosk.modulate = Color(1.0, 0.9, 0.3)
