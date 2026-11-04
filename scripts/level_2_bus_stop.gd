extends BaseLevel

@onready var portal_village: MaplePortal = $PortalVillage
@onready var portal_bus: MaplePortal = $PortalBus

# Bus Door Marker & Glowing Light Circle
@onready var bus_door_marker: Node2D = get_node_or_null("BusDoorMarker")
@onready var light_circle: Sprite2D = get_node_or_null("BusDoorMarker/LightCircle")
@onready var vertical_beam: Sprite2D = get_node_or_null("BusDoorMarker/VerticalBeam")
@onready var boarding_sign: Label = get_node_or_null("BusDoorMarker/BoardingSign")

# Zone Interactive nodes
@onready var litter_item: Node2D = $InteractiveZones/LitterBottleArea
@onready var prompt_kiosk: Label = $InteractiveZones/DrinkKioskArea/PromptLabel
@onready var prompt_recycle: Label = $InteractiveZones/RecycleArea/PromptLabel
@onready var prompt_litter: Label = $InteractiveZones/LitterBottleArea/PromptLabel
@onready var prompt_grandpa: Label = $InteractiveZones/GrandpaArea/PromptLabel
@onready var prompt_student: Label = $InteractiveZones/StudentWaitingArea/PromptLabel
@onready var prompt_timetable: Label = $InteractiveZones/TimetableArea/PromptLabel

# Quest Badges
@onready var badge_kiosk: Label = get_node_or_null("InteractiveZones/DrinkKioskArea/QuestBadge")
@onready var badge_recycle: Label = get_node_or_null("InteractiveZones/RecycleArea/QuestBadge")
@onready var badge_litter: Label = get_node_or_null("InteractiveZones/LitterBottleArea/QuestBadge")
@onready var badge_grandpa: Label = get_node_or_null("InteractiveZones/GrandpaArea/QuestBadge")
@onready var badge_timetable: Label = get_node_or_null("InteractiveZones/TimetableArea/QuestBadge")

var near_kiosk: bool = false
var near_recycle: bool = false
var near_litter: bool = false
var near_grandpa: bool = false
var near_student: bool = false
var near_timetable: bool = false

func _ready() -> void:
	level_number = 25
	add_maple_platforms = false # Flat sidewalk for clean view
	super._ready()

	# Start Bus Stop Quests in Good Deeds Diary
	GameManager.start_good_deed("q_busstop_trash")
	GameManager.start_good_deed("q_busstop_water")
	GameManager.start_good_deed("q_busstop_schedule")

	if portal_village:
		portal_village.target_scene_path = "res://scenes/levels/level_2.tscn"
		portal_village.target_level = 2
		portal_village.target_spawn_x = 4050.0
		portal_village.portal_name = "ย้อนกลับซอยหมู่บ้านดอนโมง"

	if portal_bus:
		portal_bus.target_scene_path = "res://scenes/levels/level_3.tscn"
		portal_bus.target_level = 3
		portal_bus.target_spawn_x = 100.0
		portal_bus.portal_name = "ขึ้นรถเมล์สาย 514"
		_check_bus_portal()

	# Hide litter bottle if already picked up
	if GameManager.busstop_trash_done or GameManager.has_item("ขวดน้ำพลาสติก"):
		if litter_item:
			litter_item.visible = false

	# Connect interaction trigger areas
	$InteractiveZones/DrinkKioskArea.body_entered.connect(func(b): if b.is_in_group("players"): near_kiosk = true; if prompt_kiosk: prompt_kiosk.visible = true)
	$InteractiveZones/DrinkKioskArea.body_exited.connect(func(b): if b.is_in_group("players"): near_kiosk = false; if prompt_kiosk: prompt_kiosk.visible = false)

	$InteractiveZones/RecycleArea.body_entered.connect(func(b): if b.is_in_group("players"): near_recycle = true; if prompt_recycle: prompt_recycle.visible = true)
	$InteractiveZones/RecycleArea.body_exited.connect(func(b): if b.is_in_group("players"): near_recycle = false; if prompt_recycle: prompt_recycle.visible = false)

	$InteractiveZones/LitterBottleArea.body_entered.connect(func(b): if b.is_in_group("players"): near_litter = true; if prompt_litter: prompt_litter.visible = not GameManager.busstop_trash_done and not GameManager.has_item("ขวดน้ำพลาสติก"))
	$InteractiveZones/LitterBottleArea.body_exited.connect(func(b): if b.is_in_group("players"): near_litter = false; if prompt_litter: prompt_litter.visible = false)

	$InteractiveZones/GrandpaArea.body_entered.connect(func(b): if b.is_in_group("players"): near_grandpa = true; if prompt_grandpa: prompt_grandpa.visible = true)
	$InteractiveZones/GrandpaArea.body_exited.connect(func(b): if b.is_in_group("players"): near_grandpa = false; if prompt_grandpa: prompt_grandpa.visible = false)

	$InteractiveZones/StudentWaitingArea.body_entered.connect(func(b): if b.is_in_group("players"): near_student = true; if prompt_student: prompt_student.visible = true)
	$InteractiveZones/StudentWaitingArea.body_exited.connect(func(b): if b.is_in_group("players"): near_student = false; if prompt_student: prompt_student.visible = false)

	$InteractiveZones/TimetableArea.body_entered.connect(func(b): if b.is_in_group("players"): near_timetable = true; if prompt_timetable: prompt_timetable.visible = true)
	$InteractiveZones/TimetableArea.body_exited.connect(func(b): if b.is_in_group("players"): near_timetable = false; if prompt_timetable: prompt_timetable.visible = false)

	_update_badges()

	# Opening dialogue guidance
	var all_done: bool = GameManager.busstop_trash_done and GameManager.busstop_water_given and GameManager.busstop_schedule_checked
	if not all_done:
		get_tree().create_timer(0.4).timeout.connect(func():
			GameManager.dialog_triggered.emit(
				"พี่ของขวัญ & น้องปีใหม่",
				"ถึงศาลาป้ายรถเมล์แล้ว! มีเวลาเหลืออีกนิดหน่อยก่อนรถเมล์จะออก พวกเรามาทำเควสความดีและตรวจตารางเดินรถกันเถอะ! 🚏\n1. ช่วยเก็บขวดน้ำทิ้งถังรีไซเคิล ♻️\n2. ซื้อน้ำเก๊กฮวยเย็น 5 บาทให้คุณตา 🥤\n3. เช็คตารางเดินรถเมล์สาย 514 📋",
				""
			)
		)


func _process(delta: float) -> void:
	super._process(delta)
	_check_bus_portal()
	_update_badges()

	# Dynamic pulsing animation for bus door light circle and beam
	if light_circle:
		var pulse := 0.88 + sin(Time.get_ticks_msec() * 0.005) * 0.14
		light_circle.scale = Vector2(0.9 * pulse, 0.9 * pulse)
	if vertical_beam:
		vertical_beam.modulate.a = 0.65 + sin(Time.get_ticks_msec() * 0.004) * 0.28

	# Clamp camera inside level boundaries (0 to 2560)
	if camera and p1 and p2 and OS.get_environment("CAPTURE_BUS_STOP") == "":
		var mid_x := (p1.global_position.x + p2.global_position.x) * 0.5
		camera.global_position.x = clamp(mid_x, 640.0, 1920.0)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if not interact_pressed:
		return

	if near_litter and not GameManager.busstop_trash_done and not GameManager.has_item("ขวดน้ำพลาสติก"):
		_interact_litter()
	elif near_recycle:
		_interact_recycle()
	elif near_kiosk:
		_interact_kiosk()
	elif near_grandpa:
		_interact_grandpa()
	elif near_timetable:
		_interact_timetable()
	elif near_student:
		_interact_student()

func _interact_litter() -> void:
	GameManager.add_item("ขวดน้ำพลาสติก")
	if AudioManager:
		AudioManager.play_sfx("pickup")
	if litter_item:
		litter_item.visible = false
	if badge_litter:
		badge_litter.visible = false
	GameManager.dialog_triggered.emit(
		"เก็บขยะสะสมความดี",
		"น้องปีใหม่และพี่ของขวัญช่วยกันเก็บ 'ขวดน้ำพลาสติก' ที่ตกหล่นหน้าศาลาขึ้นมา! รีบนำไปทิ้งลงถังขยะรีไซเคิลสีเหลืองข้างๆ กันเถอะ! ♻️",
		"res://assets/environment/litter_bottle.png"
	)
	_update_badges()

func _interact_recycle() -> void:
	if GameManager.has_item("ขวดน้ำพลาสติก") and not GameManager.busstop_trash_done:
		GameManager.remove_item("ขวดน้ำพลาสติก")
		if AudioManager:
			AudioManager.play_sfx("recycle")
		GameManager.busstop_trash_done = true
		GameManager.complete_good_deed("q_busstop_trash")
		GameManager.dialog_triggered.emit(
			"จุดคัดแยกขยะ 3 สี",
			"ยอดเยี่ยมมาก! ทิ้งขวดน้ำพลาสติกลงใน 'ถังสีเหลือง (ขยะรีไซเคิล)' อย่างถูกต้อง บริเวณศาลาสะอาดสวยงาม ได้รับ +20 แต้มความดีและดาวมารยาทดี! ♻️ ⭐",
			"res://assets/environment/recycle_bins.png"
		)
		_check_bus_portal()
		_update_badges()
	elif GameManager.busstop_trash_done:
		GameManager.dialog_triggered.emit(
			"จุดคัดแยกขยะ 3 สี",
			"บริเวณป้ายรถเมล์สะอาดเป็นระเบียบ ถังเขียว=เศษอาหาร, ถังเหลือง=รีไซเคิล, ถังน้ำเงิน=ทั่วไป ร่วมมือกันคัดแยกขยะเพื่อสิ่งแวดล้อมจ้า! 🌿",
			"res://assets/environment/recycle_bins.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"จุดคัดแยกขยะ 3 สี",
			"มีจุดคัดแยกขยะ 3 สีตั้งอยู่หน้าศาลา ช่วยกันมองหาขยะที่ตกหล่นบนพื้นแล้วนำมาคัดแยกให้ถูกต้องนะจ๊ะ! ♻️",
			"res://assets/environment/recycle_bins.png"
		)

func _interact_kiosk() -> void:
	if not GameManager.busstop_water_bought and not GameManager.busstop_water_given:
		var price := 5
		if GameManager.money_baht >= price:
			GameManager.money_baht -= price
		# Kindly provide drink even if player was short
		GameManager.busstop_water_bought = true
		GameManager.add_item("น้ำเก๊กฮวยเย็นชื่นใจ")
		if AudioManager:
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"ป้ามาลี (ซุ้มน้ำชงโบราณ & ขนม)",
			"สวัสดีจ้าหลานๆ! ป้าตัก 'น้ำเก๊กฮวยเย็นชื่นใจ' หวานหอมชื่นคอให้แก้วใหญ่ 5 บาทจ้า! รีบนำไปให้คุณตาที่นั่งรอรถในศาลาดื่มดับกระหายนะลูก มีน้ำใจน่ารักมากจ้ะ! 🥤",
			"res://assets/environment/drink_kiosk.png"
		)
		_update_badges()
	elif GameManager.has_item("น้ำเก๊กฮวยเย็นชื่นใจ"):
		GameManager.dialog_triggered.emit(
			"ป้ามาลี (ซุ้มน้ำชงโบราณ & ขนม)",
			"รีบนำน้ำเก๊กฮวยเย็นชื่นใจไปส่งให้คุณตาในศาลานะลูก ตากำลังคอแห้งพอดีจ้ะ! 🥤",
			"res://assets/environment/drink_kiosk.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ป้ามาลี (ซุ้มน้ำชงโบราณ & ขนม)",
			"ซุ้มน้ำชงโบราณป้ามาลียินดีต้อนรับ ขอให้เดินทางไปโรงเรียนอย่างปลอดภัยและมีความสุขนะเด็กดี! 💖",
			"res://assets/environment/drink_kiosk.png"
		)

func _interact_grandpa() -> void:
	if GameManager.has_item("น้ำเก๊กฮวยเย็นชื่นใจ") and not GameManager.busstop_water_given:
		GameManager.remove_item("น้ำเก๊กฮวยเย็นชื่นใจ")
		GameManager.busstop_water_given = true
		GameManager.complete_good_deed("q_busstop_water")
		if AudioManager:
			AudioManager.play_sfx("sister_cheer")
		GameManager.dialog_triggered.emit(
			"คุณตาใจดี (ศาลารอรถ)",
			"โอ้โห! ขอบใจหนูของขวัญและน้องปีใหม่มากเลยลูก น้ำเก๊กฮวยเย็นชื่นใจ ดับกระหายคลายร้อนได้วิเศษจริงๆ กตัญญูและมีน้ำใจต่อผู้สูงอายุแบบนี้ ขอให้เรียนหนังสือเก่งๆ สุขภาพแข็งแรงนะจ๊ะ! 💖 ⭐",
			"res://assets/characters/npcs/npc_grandpa.png"
		)
		_check_bus_portal()
		_update_badges()
	elif not GameManager.busstop_water_given:
		GameManager.dialog_triggered.emit(
			"คุณตาใจดี (ศาลารอรถ)",
			"สวัสดีจ้ะเด็กๆ อากาศช่วงสายเริ่มร้อน ตาเดินมาไกลคอแห้งจัง ถ้าได้น้ำเย็นๆ สักแก้วจากซุ้มป้ามาลี [ทางซ้าย] คงชื่นใจ...",
			"res://assets/characters/npcs/npc_grandpa.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"คุณตาใจดี (ศาลารอรถ)",
			"รถเมล์สาย 514 จอดเทียบป้ายแล้วจ้ะ ขึ้นรถตรงวงกลมแสงด้านหน้าอย่างเป็นระเบียบ ระวังบันได และอย่าลืมมีน้ำใจให้เพื่อนร่วมทางนะลูก! 🚌",
			"res://assets/characters/npcs/npc_grandpa.png"
		)

func _interact_timetable() -> void:
	if not GameManager.busstop_schedule_checked:
		GameManager.busstop_schedule_checked = true
		GameManager.complete_good_deed("q_busstop_schedule")
		if AudioManager:
			AudioManager.play_sfx("star")
		GameManager.dialog_triggered.emit(
			"ป้ายตารางเดินรถสาย 514",
			"【ตารางเวลารถประจำทาง สาย 514】\n🚏 เส้นทาง: หมู่บ้านดอนโมง ➔ สถานีขนส่งสองแถว ➔ ร.ร. ชุมชนหนองเรือ\n⏰ ความถี่: รถออกทุกๆ 15 นาที (ตรงเวลา)\n🎟️ อัตราค่าโดยสาร: นักเรียน 8 บาท / บุคคลทั่วไป 10 บาท\n✅ ได้รับ +15 แต้มความดีและดาวมารยาทวินัยจราจร! 🚦 ⭐",
			"res://assets/environment/bus_timetable_stand.png"
		)
		_check_bus_portal()
		_update_badges()
	else:
		GameManager.dialog_triggered.emit(
			"ป้ายตารางเดินรถสาย 514",
			"รถเมล์สาย 514 ให้บริการตรงเวลา ผู้โดยสารโปรดเตรียมค่าโดยสารพอดี 8 บาท เพื่อความสะดวกรวดเร็ว 🎟️",
			"res://assets/environment/bus_timetable_stand.png"
		)

func _interact_student() -> void:
	GameManager.dialog_triggered.emit(
		"น้องมิ้นท์ (เพื่อนนักเรียน ป.2)",
		"สวัสดีของขวัญและปีใหม่! วันนี้ที่โรงเรียนมีวิชาทดลองวิทยาศาสตร์และกิจกรรมดูแลแปลงเกษตรด้วยนะ เตรียมตัวมาพร้อมหรือยังจ๊ะ! 🎒 🌸",
		"res://assets/characters/npcs/npc_student.png"
	)

func _check_bus_portal() -> void:
	if not portal_bus:
		return
	
	var trash_ok: bool = GameManager.busstop_trash_done
	var water_ok: bool = GameManager.busstop_water_given
	var schedule_ok: bool = GameManager.busstop_schedule_checked
	var all_done: bool = trash_ok and water_ok and schedule_ok

	if all_done:
		if portal_bus.is_locked:
			portal_bus.is_locked = false
			portal_bus.lock_message = ""
			portal_bus.portal_name = "ขึ้นรถเมล์สาย 514 [ประตูเปิดแล้ว! ✨]"
			if AudioManager:
				AudioManager.play_sfx("sister_cheer")
			GameManager.dialog_triggered.emit(
				"พี่ของขวัญ & น้องปีใหม่",
				"🎉 เย้! ทำเควสความดีที่ศาลาป้ายรถเมล์ครบถ้วนแล้ว! ประตูรถเมล์สาย 514 เปิดต้อนรับแล้ว ก้าวขึ้นรถตรงวงกลมแสงด้านหน้าได้เลย! 🚌✨",
				""
			)
		if boarding_sign:
			boarding_sign.text = "🚌 ประตูขึ้นรถเมล์สาย 514 [เปิดแล้ว! ✨]"
			boarding_sign.modulate = Color(0.4, 1.0, 0.7)
		if light_circle:
			light_circle.modulate = Color(0.18, 1.0, 0.85, 0.98) # เขียว-ฟ้าสดใส (Emerald Cyan)
		if vertical_beam:
			vertical_beam.modulate = Color(0.25, 1.0, 0.88, 0.92)
	else:
		portal_bus.is_locked = true
		portal_bus.portal_name = "ขึ้นรถเมล์สาย 514 [ประตูปิดอยู่]"
		if boarding_sign:
			boarding_sign.text = "🚌 ประตูขึ้นรถเมล์สาย 514 [ประตูปิดอยู่]"
			boarding_sign.modulate = Color(1.0, 0.7, 0.25)
		if light_circle:
			light_circle.modulate = Color(1.0, 0.18, 0.22, 0.98) # สีแดงสด (Crimson Red) เตือนยังผ่านไม่ได้
		if vertical_beam:
			vertical_beam.modulate = Color(1.0, 0.25, 0.25, 0.85)
		
		var missing: Array[String] = []
		if not trash_ok:
			missing.append("• เก็บขวดน้ำพลาสติกไปทิ้งลงถังรีไซเคิลสีเหลือง ♻️")
		if not water_ok:
			missing.append("• ซื้อน้ำเก๊กฮวยเย็น 5 บาทที่ซุ้มป้ามาลีมาให้คุณตา 🥤")
		if not schedule_ok:
			missing.append("• ตรวจเช็คตารางเดินรถเมล์สาย 514 ที่ป้าย 🚏")
		portal_bus.lock_message = "ยังขึ้นรถไม่ได้จ้ะ! รถเมล์กำลังรออยู่ ทำภารกิจที่ป้ายรถเมล์ให้ครบก่อนนะ:\n" + "\n".join(missing)

func _update_badges() -> void:
	if badge_kiosk:
		if GameManager.busstop_water_bought or GameManager.busstop_water_given:
			badge_kiosk.text = "✅ ซื้อน้ำเก๊กฮวยแล้ว"
			badge_kiosk.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_kiosk.text = "💡 เควสน้ำเก๊กฮวยให้คุณตา [!]"
			badge_kiosk.modulate = Color(1.0, 0.9, 0.3)

	if badge_litter:
		if GameManager.busstop_trash_done or GameManager.has_item("ขวดน้ำพลาสติก"):
			badge_litter.visible = false
		else:
			badge_litter.visible = true

	if badge_recycle:
		if GameManager.busstop_trash_done:
			badge_recycle.text = "✅ คัดแยกขยะเรียบร้อย"
			badge_recycle.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_recycle.text = "💡 เควสคัดแยกขยะ 3 สี [!]"
			badge_recycle.modulate = Color(1.0, 0.9, 0.3)

	if badge_grandpa:
		if GameManager.busstop_water_given:
			badge_grandpa.text = "✅ มอบน้ำให้คุณตาชื่นใจแล้ว"
			badge_grandpa.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_grandpa.text = "💡 เควสน้ำใจให้คุณตา [!]"
			badge_grandpa.modulate = Color(1.0, 0.9, 0.3)

	if badge_timetable:
		if GameManager.busstop_schedule_checked:
			badge_timetable.text = "✅ ตรวจตารางและค่าโดยสาร 8 ฿ แล้ว"
			badge_timetable.modulate = Color(0.3, 1.0, 0.4)
		else:
			badge_timetable.text = "💡 เควสตรวจตารางเดินรถ [!]"
			badge_timetable.modulate = Color(1.0, 0.9, 0.3)

