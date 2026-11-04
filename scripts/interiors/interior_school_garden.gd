extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var flowerbed_area: Area2D = $FlowerbedArea
@onready var prompt_flowerbed: Label = $FlowerbedArea/PromptLabel
@onready var badge_flowerbed: Label = $FlowerbedArea/QuestBadge
@onready var flowerbed_prop: Sprite2D = $FlowerbedProp

@onready var water_station_area: Area2D = $WaterStationArea
@onready var prompt_water: Label = $WaterStationArea/PromptLabel

@onready var teacher_area: Area2D = $TeacherArea
@onready var prompt_teacher: Label = $TeacherArea/PromptLabel

var near_flowerbed: bool = false
var near_water: bool = false
var near_teacher: bool = false

func _ready() -> void:
	level_number = 805
	super._ready()

	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_8.tscn"
		exit_portal.target_spawn_x = 1960.0
		exit_portal.target_level = 8
		exit_portal.portal_name = "ออกไปหน้าแปลงดอกไม้โรงเรียน"
		exit_portal.is_locked = false
		exit_portal.is_building_door = true

	if flowerbed_area:
		flowerbed_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_flowerbed = true
				if prompt_flowerbed: prompt_flowerbed.visible = true
		)
		flowerbed_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_flowerbed = false
				if prompt_flowerbed: prompt_flowerbed.visible = false
		)

	if water_station_area:
		water_station_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_water = true
				if prompt_water: prompt_water.visible = true
		)
		water_station_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_water = false
				if prompt_water: prompt_water.visible = false
		)

	if teacher_area:
		teacher_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_teacher = true
				if prompt_teacher: prompt_teacher.visible = true
		)
		teacher_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_teacher = false
				if prompt_teacher: prompt_teacher.visible = false
		)

	if flowerbed_prop and GameManager.flowers_bloomed:
		flowerbed_prop.modulate = Color(1.3, 1.3, 1.2)

	_update_badges()

	await get_tree().create_timer(0.4).timeout
	if not GameManager.flowers_bloomed:
		GameManager.dialog_triggered.emit(
			"ครูเกษตร (ครูสมศรี)",
			"ยินดีต้อนรับสู่เรือนเพาะชำและแปลงดอกไม้จ้ะ! วันนี้ต้องช่วยกันรดน้ำแปลงดอกไม้ให้ชุ่มฉ่ำ เพื่อให้ดอกไม้บานสะพรั่งรอบโรงเรียนนะจ๊ะ! สามารถตักน้ำที่จุดเติมน้ำมารดได้เลย! 🌸💧",
			"res://assets/characters/npcs/npc_teacher.png"
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_flowerbed:
			_interact_flowerbed()
		elif near_water:
			_interact_water()
		elif near_teacher:
			_interact_teacher()

func _interact_water() -> void:
	if not GameManager.has_item("บัวรดน้ำ"):
		GameManager.add_item("บัวรดน้ำ")
		if AudioManager:
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"จุดเติมน้ำและบัวรดน้ำ",
			"💧 สองพี่น้องหยิบบัวรดน้ำประจำเรือนเพาะชำและเปิดก๊อกเติมน้ำจนเต็ม! พร้อมนำไปรดแปลงดอกไม้แล้ว!",
			""
		)
	else:
		if AudioManager:
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"จุดเติมน้ำและบัวรดน้ำ",
			"💧 เติมน้ำใส่บัวรดน้ำจนเต็มเปี่ยม สดชื่นและพร้อมรดแปลงดอกไม้!",
			""
		)

func _interact_flowerbed() -> void:
	if GameManager.flowers_bloomed:
		GameManager.dialog_triggered.emit(
			"แปลงเกษตรพฤกษศาสตร์ [ริมสระน้ำ 17]",
			"🌸 ดอกไม้ในแปลงบานสะพรั่งสีสันสดใส ทั้งดอกทานตะวัน กุหลาบ และดาวเรือง ส่งกลิ่นหอมชื่นใจไปทั่วโรงเรียน!",
			""
		)
		return

	var has_can = GameManager.has_item("บัวรดน้ำ")
	var has_book = GameManager.has_item("ตำราพฤกษศาสตร์")
	var has_fert = GameManager.has_item("ปุ๋ยอินทรีย์")

	if not has_can:
		GameManager.dialog_triggered.emit(
			"แปลงเกษตรพฤกษศาสตร์",
			"⚠️ ยังไม่มีบัวรดน้ำ! เดินไปที่ [จุดเติมน้ำ] ทางซ้ายเพื่อหยิบบัวรดน้ำและเติมน้ำให้เต็มก่อนนะจ๊ะ! 💧",
			""
		)
		return

	# Player has watering can! Water the flowers!
	GameManager.flowers_bloomed = true
	GameManager.flowers_fertilized = true
	GameManager.complete_good_deed("q_flower_garden")
	GameManager.add_star()
	GameManager.add_star()

	if AudioManager:
		AudioManager.play_sfx("correct")
		AudioManager.play_sfx("coin")

	if flowerbed_prop:
		var tween = create_tween()
		tween.tween_property(flowerbed_prop, "modulate", Color(1.4, 1.4, 1.3), 0.5)

	var extra_praise = ""
	if has_book and has_fert:
		extra_praise = " ตามตำราพฤกษศาสตร์และใส่ปุ๋ยอินทรีย์อย่างถูกวิธี!"

	GameManager.dialog_triggered.emit(
		"แปลงเกษตรพฤกษศาสตร์ [ริมสระน้ำ 17]",
		"🎉 สำเร็จแล้ว! สองพี่น้องช่วยกันรดน้ำแปลงดอกไม้จนชุ่มฉ่ำ" + extra_praise + " ดอกไม้บานสะพรั่งงดงามตระการตา! ⭐⭐ ประตูโรงเรียน [จุด 24] เปิดแล้ว ได้เวลากลับบ้าน! 🌸🌼",
		""
	)
	_update_badges()

func _interact_teacher() -> void:
	if GameManager.flowers_bloomed:
		GameManager.dialog_triggered.emit(
			"ครูเกษตร (ครูสมศรี)",
			"ขอบใจของขวัญและปีใหม่มากนะจ๊ะ! ดอกไม้บานสะพรั่งงดงามมาก โรงเรียนเราสดชื่นขึ้นทันตาเห็นเลย! เดินทางกลับบ้านปลอดภัยนะจ๊ะเด็กๆ 🌸",
			"res://assets/characters/npcs/npc_teacher.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ครูเกษตร (ครูสมศรี)",
			"สวัสดีจ้ะเด็กๆ! ถ้าอยากให้ดอกไม้บานสะพรั่ง อย่าลืมหยิบบัวรดน้ำทางซ้าย เติมน้ำให้เต็ม แล้วมารดที่แปลงดอกไม้ตรงนี้นะจ๊ะ! 🌻💧",
			"res://assets/characters/npcs/npc_teacher.png"
		)

func _update_badges() -> void:
	if badge_flowerbed:
		if GameManager.flowers_bloomed:
			badge_flowerbed.text = "✅ รดน้ำแปลงดอกไม้บานสะพรั่งเรียบร้อยแล้ว"
			badge_flowerbed.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_flowerbed.text = "💡 นำบัวรดน้ำมารดน้ำแปลงดอกไม้ให้บานสะพรั่ง [!]"
			badge_flowerbed.modulate = Color(1.0, 0.9, 0.3)
