extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var doctor_area: Area2D = $DoctorArea
@onready var prompt_doctor: Label = $DoctorArea/PromptLabel
@onready var badge_doctor: Label = $DoctorArea/QuestBadge
@onready var chart_area: Area2D = $ChartArea
@onready var prompt_chart: Label = $ChartArea/PromptLabel
@onready var cabinet_prop: Sprite2D = $CabinetProp

var near_doctor: bool = false
var near_chart: bool = false

func _ready() -> void:
	level_number = 203
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 2650.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false
	
	if doctor_area:
		doctor_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_doctor = true
				if prompt_doctor: prompt_doctor.visible = true
		)
		doctor_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_doctor = false
				if prompt_doctor: prompt_doctor.visible = false
		)
	
	if chart_area:
		chart_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_chart = true
				if prompt_chart: prompt_chart.visible = true
		)
		chart_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_chart = false
				if prompt_chart: prompt_chart.visible = false
		)
	
	_update_badges()
	
	await get_tree().create_timer(0.4).timeout
	if not GameManager.doctor_eyedrops_received:
		GameManager.dialog_triggered.emit(
			"คุณหมอประวิทย์ (คลินิกดอนโมง)",
			"สวัสดีจ้ะของขวัญและปีใหม่! เข้ามาในคลินิกหมอชุมชนแล้วนั่งพักให้หายเหนื่อยก่อนนะ วันนี้มารับยาวิตามินบำรุงสายตาให้คุณยายใช่ไหมจ๊ะ? หมอเตรียมไว้ให้ที่โต๊ะตรวจแล้วจ้ะ! 🩺 💊",
			"res://assets/characters/npcs/npc_doctor.png"
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_doctor:
			_interact_doctor()
		elif near_chart:
			_interact_chart()

func _interact_doctor() -> void:
	if not GameManager.doctor_eyedrops_received:
		GameManager.doctor_eyedrops_received = true
		GameManager.village_doctor_visited = true
		GameManager.add_item("ยาวิตามินและยาหยอดตา")
		GameManager.complete_good_deed("q_village_doctor")
		GameManager.add_star()
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"คุณหมอประวิทย์ (คลินิกดอนโมง)",
			"นี่จ้ะ 'ยาวิตามินและยาหยอดตา' สำหรับคุณยายใจดี!\nหมอฝากเคล็ดลับดูแลสายตา 20-20-20:\n- ทุกๆ 20 นาทีที่อ่านหนังสือหรือใช้สายตา ให้พักสายตามองไกล 20 ฟุต นาน 20 วินาที\n- ทานผักบุ้งและแครอทที่มีวิตามินเอสูงนะจ๊ะเด็กดี! 🥕 👀 ⭐⭐",
			"res://assets/characters/npcs/npc_doctor.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"คุณหมอประวิทย์ (คลินิกดอนโมง)",
			"รับยาวิตามินและยาหยอดตาครบถ้วนแล้ว! รีบนำไปให้คุณยายนะจ๊ะ และอย่าลืมดื่มน้ำสะอาดมากๆ ในแต่ละวันด้วยนะเด็กดี! 🩺 ✨",
			"res://assets/characters/npcs/npc_doctor.png"
		)
	_update_badges()

func _interact_chart() -> void:
	GameManager.dialog_triggered.emit(
		"แผ่นตรวจวัดสายตา (Snellen Chart)",
		"🔍 [ตรวจวัดสายตาประจำปี]:\nพี่ของขวัญและน้องปีใหม่มองเห็นตัวอักษร E W M ชัดเจนทุกแถว! สายตาคมชัดระดับ 20/20 สุขภาพตาแข็งแรงเยี่ยมยอด! 👁️ ✨",
		""
	)

func _update_badges() -> void:
	if badge_doctor:
		if GameManager.doctor_eyedrops_received:
			badge_doctor.text = "✅ ตรวจสุขภาพตาและรับยาเรียบร้อย"
			badge_doctor.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_doctor.text = "💡 รับยาวิตามินและยาหยอดตา [!]"
			badge_doctor.modulate = Color(1.0, 0.9, 0.3)
