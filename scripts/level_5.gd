extends BaseLevel

@onready var portal_classroom: MaplePortal = $PortalClassroom
@onready var guard_npc: NPCCharacter = $GuardNPC
@onready var teacher_npc: NPCCharacter = $TeacherNPC
@onready var little_student_npc: NPCCharacter = $LittleStudentNPC
@onready var pencil_box_item: Area2D = $ItemPencilBox

var guard_greeted: bool = false
var teacher_greeted: bool = false
var pencil_returned: bool = false

func _ready() -> void:
	level_number = 5
	super._ready()

	GameManager.start_good_deed("q_school_wai")
	GameManager.start_good_deed("q_school_pencil")

	if portal_classroom:
		portal_classroom.target_level = 6
		portal_classroom.target_spawn_x = 100.0
		_update_portal_state()

	if pencil_box_item:
		pencil_box_item.body_entered.connect(_on_pencil_box_touched)
		if GameManager.has_item("กล่องดินสอสี") or GameManager.good_deeds.get("q_school_pencil", {}).get("status", "") == "completed":
			pencil_box_item.visible = false
			pencil_returned = (GameManager.good_deeds.get("q_school_pencil", {}).get("status", "") == "completed")

func _get_level_width() -> float:
	return 1800.0

func _process(delta: float) -> void:
	super._process(delta)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	# Interaction with Guard Uncle Boonmee
	if guard_npc and (guard_npc.p1_near or guard_npc.p2_near) and interact_pressed:
		_interact_guard()

	# Interaction with Duty Teacher Sunee
	if teacher_npc and (teacher_npc.p1_near or teacher_npc.p2_near) and interact_pressed:
		_interact_teacher()

	# Interaction with Little 1st grader
	if little_student_npc and (little_student_npc.p1_near or little_student_npc.p2_near) and interact_pressed:
		_interact_little_student()

	# Auto-unlock classroom portal once key and attendance book are obtained
	if GameManager.has_item("กุญแจห้องและสมุดเช็คชื่อ") and not GameManager.classroom_unlocked:
		GameManager.classroom_unlocked = true
		_update_portal_state()

func _update_portal_state() -> void:
	if not portal_classroom:
		return
	if GameManager.classroom_unlocked or GameManager.has_item("กุญแจห้องและสมุดเช็คชื่อ"):
		GameManager.classroom_unlocked = true
		portal_classroom.is_locked = false
		portal_classroom.portal_name = "เข้าสู่อาคารเรียน ป.2/1 [เปิดแล้ว! ✨]"
	else:
		portal_classroom.is_locked = true
		portal_classroom.portal_name = "เข้าสู่อาคารเรียน ป.2/1 [ประตูล็อก]"
		portal_classroom.lock_message = "ประตูอาคารเรียน ป.2/1 ยังล็อกอยู่! ขอกุญแจและสมุดเช็คชื่อจากคุณลุง รปภ. ที่ป้อมยามหน้าประตูก่อนนะจ๊ะ! 🔑"

func _interact_guard() -> void:
	guard_greeted = true
	_check_wai_quest()
	if not GameManager.has_item("กุญแจห้องและสมุดเช็คชื่อ"):
		GameManager.add_item("กุญแจห้องและสมุดเช็คชื่อ")
		GameManager.guard_talked = true
		GameManager.classroom_unlocked = true
		GameManager.add_star()
		_update_portal_state()
		GameManager.dialog_triggered.emit("ลุงบุญมี รปภ.", "สวัสดีจ้ะเด็กๆ! ไหว้สวยน่ารักมาก นี่จ้ะ 'กุญแจห้องเรียนและสมุดเช็คชื่อ' ที่คุณครูลืมไว้ ประตูอาคารเรียน ป.2/1 ปลดล็อกพร้อมแล้ว เดินเข้าห้องเรียนทางขวาสุดได้เลยนะเด็กดี! 🔑✨", "res://assets/characters/npcs/npc_guard.png")
	else:
		GameManager.dialog_triggered.emit("ลุงบุญมี รปภ.", "นำกุญแจและสมุดเช็คชื่อเดินเข้าประตูอาคารเรียน ป.2/1 ด้านขวาสุดได้เลยนะจ๊ะ!", "res://assets/characters/npcs/npc_guard.png")

func _interact_teacher() -> void:
	teacher_greeted = true
	_check_wai_quest()
	GameManager.dialog_triggered.emit("ครูสุณี (ครูเวร)", "สวัสดีจ้ะน้องของขวัญ น้องปีใหม่! มาโรงเรียนแต่เช้า สดใสร่าเริงมากจ้ะ อย่าลืมนำสมุดเช็คชื่อจากป้อม รปภ. ขึ้นไปที่ห้องเรียนด้วยนะจ๊ะ!", "res://assets/characters/npcs/npc_teacher.png")

func _check_wai_quest() -> void:
	if guard_greeted and teacher_greeted and GameManager.good_deeds["q_school_wai"]["status"] != "completed":
		GameManager.complete_good_deed("q_school_wai")

func _on_pencil_box_touched(body: Node2D) -> void:
	if body.is_in_group("players") and not GameManager.has_item("กล่องดินสอสี"):
		GameManager.add_item("กล่องดินสอสี")
		if pencil_box_item:
			pencil_box_item.visible = false
			pencil_box_item.queue_free()
		GameManager.dialog_triggered.emit("พี่ของขวัญ & น้องปีใหม่", "เก็บ 'กล่องดินสอสี' ลายน่ารักที่ตกอยู่หน้าทางม้าลายได้แล้ว! มีน้อง ป.1 กำลังยืนมองหาอยู่ข้างหน้า รีบนำไปคืนน้องกันเถอะ!", "")

func _interact_little_student() -> void:
	if GameManager.has_item("กล่องดินสอสี") and not pencil_returned:
		pencil_returned = true
		GameManager.remove_item("กล่องดินสอสี")
		GameManager.complete_good_deed("q_school_pencil")
		GameManager.dialog_triggered.emit("น้อง ป.1", "เย้! กล่องดินสอของผมจริงๆ ด้วยครับ! ขอบคุณพี่ของขวัญกับพี่ปีใหม่มากครับ! พี่ๆ ใจดีที่สุดเลย! ✨", "res://assets/characters/npcs/npc_kindergarten.png")
	elif pencil_returned:
		GameManager.dialog_triggered.emit("น้อง ป.1", "สวัสดีครับพี่ๆ วันนี้ผมจะตั้งใจเรียนวาดเขียนครับ!", "res://assets/characters/npcs/npc_kindergarten.png")
	else:
		GameManager.dialog_triggered.emit("น้อง ป.1", "ฮือๆ กล่องดินสอสีลายการ์ตูนของผมหล่นหายไปไหนนะ อยู่แถวทางม้าลายหรือเปล่านะ...", "res://assets/characters/npcs/npc_kindergarten.png")
