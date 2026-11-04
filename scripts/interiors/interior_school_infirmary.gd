extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var nurse_area: Area2D = $NurseArea
@onready var prompt_nurse: Label = $NurseArea/PromptLabel
@onready var badge_nurse: Label = $NurseArea/QuestBadge
@onready var scale_area: Area2D = $ScaleArea
@onready var prompt_scale: Label = $ScaleArea/PromptLabel
@onready var bed_prop: Sprite2D = $BedProp

var near_nurse: bool = false
var near_scale: bool = false

func _ready() -> void:
	level_number = 802
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_8.tscn"
		exit_portal.target_spawn_x = 1320.0
		exit_portal.target_level = 8
		exit_portal.portal_name = "ออกไปลานเกษตรโรงเรียน"
		exit_portal.is_locked = false
	
	if nurse_area:
		nurse_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_nurse = true
				if prompt_nurse: prompt_nurse.visible = true
		)
		nurse_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_nurse = false
				if prompt_nurse: prompt_nurse.visible = false
		)
	
	if scale_area:
		scale_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_scale = true
				if prompt_scale: prompt_scale.visible = true
		)
		scale_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_scale = false
				if prompt_scale: prompt_scale.visible = false
		)
	
	_update_badges()
	
	await get_tree().create_timer(0.4).timeout
	if not GameManager.infirmary_firstaid_done:
		GameManager.dialog_triggered.emit(
			"ครูพยาบาลมาลี (ห้องพยาบาล)",
			"สวัสดีจ้ะของขวัญและปีใหม่! ห้องพยาบาลสะอาด อบอุ่น และพร้อมดูแลนักเรียนทุกคนจ้ะ ได้ยินว่ามีน้องอนุบาลหกล้มที่สนามเด็กเล่นใช่ไหมจ๊ะ? มารับกล่องยาปฐมพยาบาลได้เลยจ้ะ! 🩹 🏥",
			"res://assets/characters/npcs/npc_nurse.png"
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_nurse:
			_interact_nurse()
		elif near_scale:
			_interact_scale()

func _interact_nurse() -> void:
	if not GameManager.infirmary_firstaid_done:
		GameManager.infirmary_firstaid_done = true
		if not GameManager.has_item("กล่องปฐมพยาบาล") and not GameManager.injured_student_helped:
			GameManager.add_item("กล่องปฐมพยาบาล")
		GameManager.complete_good_deed("q_nurse_help")
		GameManager.add_star()
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("cheer")
		GameManager.dialog_triggered.emit(
			"ครูพยาบาลมาลี (ห้องพยาบาล)",
			"นี่จ้ะ 'กล่องปฐมพยาบาลและพลาสเตอร์ยา'!\nครูสอน 3 ขั้นตอนล้างแผลที่ถูกต้อง:\n1. ล้างแผลด้วยน้ำเกลือปราศจากเชื้อ (Normal Saline)\n2. ทายาฆ่าเชื้อเบทาดีนรอบๆ แผล\n3. ปิดด้วยพลาสเตอร์ยาเพื่อกันฝุ่นละออง\nรีบนำไปช่วยน้องอนุบาลที่สนามเด็กเล่นนะเด็กดี! 🩹 ⭐⭐",
			"res://assets/characters/npcs/npc_nurse.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ครูพยาบาลมาลี (ห้องพยาบาล)",
			"สุขภาพดีเริ่มต้นที่การดูแลตนเอง พักผ่อนให้พอ และทานอาหารที่มีประโยชน์นะจ๊ะเด็กๆ! 🩺 ✨",
			"res://assets/characters/npcs/npc_nurse.png"
		)
	_update_badges()

func _interact_scale() -> void:
	GameManager.add_star()
	if AudioManager:
		AudioManager.play_sfx("correct")
	GameManager.dialog_triggered.emit(
		"เครื่องชั่งน้ำหนักและวัดส่วนสูงโรงเรียน",
		"⚖️ [บันทึกสมุดสุขภาพนักเรียน]:\n- พี่ของขวัญ: ส่วนสูง 135 ซม. น้ำหนัก 30 กก. (ตามเกณฑ์มาตรฐาน)\n- น้องปีใหม่: ส่วนสูง 118 ซม. น้ำหนัก 21 กก. (เจริญเติบโตสมวัย)\nแข็งแรงสดใสทั้งสองพี่น้องเลยจ้า! 📏 ⭐",
		""
	)

func _update_badges() -> void:
	if badge_nurse:
		if GameManager.infirmary_firstaid_done:
			badge_nurse.text = "✅ อบรมปฐมพยาบาลและรับกล่องยาเรียบร้อย"
			badge_nurse.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_nurse.text = "💡 อบรมปฐมพยาบาลและรับกล่องยา [!]"
			badge_nurse.modulate = Color(1.0, 0.9, 0.3)
