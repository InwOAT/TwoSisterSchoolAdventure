extends BaseLevel

@onready var portal_canteen: MaplePortal = $PortalCanteen
@onready var question_label: Label = $Blackboard/QuestionLabel
@onready var explanation_box: PanelContainer = $Blackboard/ExplanationBox
@onready var explanation_label: Label = $Blackboard/ExplanationBox/ExplanationLabel
@onready var badge_step: Label = $Blackboard/HeaderHBox/BadgeStep
@onready var badge_score: Label = $Blackboard/HeaderHBox/BadgeScore

@onready var btn_a: Button = $DeskA/BtnChooseA
@onready var btn_b: Button = $DeskB/BtnChooseB
@onready var btn_c: Button = $DeskC/BtnChooseC

@onready var indicator_a: Label = $DeskA/IndicatorBadge
@onready var indicator_b: Label = $DeskB/IndicatorBadge
@onready var indicator_c: Label = $DeskC/IndicatorBadge

@onready var desk_a_area: Area2D = $DeskA
@onready var desk_b_area: Area2D = $DeskB
@onready var desk_c_area: Area2D = $DeskC

var current_q: int = 0
var near_desk_a: bool = false
var near_desk_b: bool = false
var near_desk_c: bool = false

# Comprehensive Question Bank for Classroom (15 diverse questions across Thai curriculum)
const CLASSROOM_QUESTION_BANK: Array[Dictionary] = [
	{
		"q": "สัญญาณไฟจราจรสำหรับคนข้ามถนน 'สีอะไร' ที่สามารถเดินข้ามได้อย่างปลอดภัย?",
		"choices": ["ก. สีแดง", "ข. สีเขียว", "ค. สีเหลือง"],
		"correct": 1,
		"explain": "ถูกต้องแล้วจ้ะ! สัญญาณไฟรูปคนสีเขียวหมายถึงให้เดินข้ามทางม้าลายได้อย่างปลอดภัย! 🚦"
	},
	{
		"q": "มีเงิน 50 บาท ซื้ออาหารกลางวันไป 25 บาท จะได้รับเงินทอนกี่บาท?",
		"choices": ["ก. 15 บาท", "ข. 25 บาท", "ค. 30 บาท"],
		"correct": 1,
		"explain": "คำนวณเลขเก่งมาก! 50 - 25 = 25 บาทจ้ะ! 🪙"
	},
	{
		"q": "เมื่อเดินพบคุณครูหรือผู้ใหญ่ ควรปฏิบัติตนอย่างไรตามมารยาทไทย?",
		"choices": ["ก. แกล้งก้มหน้าเดินผ่าน", "ข. ยกมือไหว้อย่างนอบน้อม", "ค. รีบวิ่งหนี"],
		"correct": 1,
		"explain": "น่ารักมากจ้ะ! การยกมือไหว้พร้อมกล่าวทักทายอย่างสุภาพเป็นมารยาทไทยที่น่าชื่นชม! ⭐"
	},
	{
		"q": "กล่องนมและขวดพลาสติกที่ดื่มหมดแล้ว ควรทิ้งลงในถังขยะสีใด?",
		"choices": ["ก. ถังสีเหลือง (รีไซเคิล)", "ข. ถังสีเขียว (ขยะเปียก)", "ค. ถังสีแดง (ขยะอันตราย)"],
		"correct": 0,
		"explain": "ยอดเยี่ยมมาก! พลาสติกและกล่องเครื่องดื่มเป็นขยะรีไซเคิล ใส่ถังสีเหลืองจ้ะ! ♻️"
	},
	{
		"q": "การล้างมือให้สะอาดถูกสุขอนามัยเพื่อป้องกันเชื้อโรค ควรถูมือนานอย่างน้อยกี่วินาที?",
		"choices": ["ก. 5 วินาที", "ข. 20 วินาที", "ค. 60 วินาที"],
		"correct": 1,
		"explain": "ถูกต้องจ้ะ! ควรถูสบู่ให้ทั่วมือนานประมาณ 20 วินาที หรือร้องเพลงช้างจบ 2 รอบ! 🧼"
	},
	{
		"q": "เมื่อได้รับของขวัญหรือความช่วยเหลือจากผู้อื่น ควรกล่าวคำว่าอะไร?",
		"choices": ["ก. ขอบคุณค่ะ / ขอบคุณครับ", "ข. ไม่เป็นไร", "ค. ขอโทษ"],
		"correct": 0,
		"explain": "เก่งมากจ้ะ! คำว่า 'ขอบคุณ' เป็นคำพูดที่ไพเราะและสร้างรอยยิ้มให้ผู้ให้เสมอ! 🌸"
	},
	{
		"q": "ป้ายจราจรเตือน 'ทางม้าลาย' มีลักษณะความหมายเพื่อสิ่งใด?",
		"choices": ["ก. ให้รถชะลอและระวังคนข้าม", "ข. ให้เร่งความเร็ว", "ค. ห้ามจอด"],
		"correct": 0,
		"explain": "ถูกต้องจ้ะ! ป้ายเตือนทางม้าลายช่วยให้ผู้ขับขี่ชะลอความเร็วและระวังคนเดินข้ามถนน! 🚸"
	},
	{
		"q": "การนั่งรถสองแถวหรือรถประจำทาง ข้อใดเป็นพฤติกรรมที่ปลอดภัยที่สุด?",
		"choices": ["ก. โหนบันไดท้ายรถ", "ข. นั่งหรือจับราวยึดให้แน่น", "ค. วิ่งเล่นไปมาบนรถ"],
		"correct": 1,
		"explain": "ถูกต้องจ้ะ! ต้องจับราวยึดให้มั่นคงและห้ามยื่นมือยื่นแขนออกนอกหน้าต่างเด็ดขาด! 🚌"
	},
	{
		"q": "พืชต้องการสิ่งใดในการเจริญเติบโตและสร้างอาหาร?",
		"choices": ["ก. แสงแดด น้ำ และอากาศ", "ข. ขนมขบเคี้ยว", "ค. น้ำอัดลม"],
		"correct": 0,
		"explain": "เก่งมาก! พืชใช้แสงแดด น้ำ และก๊าซคาร์บอนไดออกไซด์ในกระบวนการสังเคราะห์ด้วยแสง! 🌿"
	},
	{
		"q": "พี่ของขวัญเก็บขวดได้ 12 ใบ น้องปีใหม่เก็บได้ 15 ใบ รวมกันมีขวดกี่ใบ?",
		"choices": ["ก. 25 ใบ", "ข. 27 ใบ", "ค. 30 ใบ"],
		"correct": 1,
		"explain": "ยอดเยี่ยม! 12 + 15 = 27 ใบ สองพี่น้องช่วยกันได้ดีมาก! 🌟"
	},
	{
		"q": "อาหารหมู่ใดที่ช่วยเสริมสร้างกล้ามเนื้อและการเจริญเติบโตของร่างกาย?",
		"choices": ["ก. โปรตีน (เนื้อสัตว์ ไข่ นม)", "ข. ไขมันสัตว์", "ค. คาร์โบไฮเดรต"],
		"correct": 0,
		"explain": "ถูกต้องแล้วจ้ะ! โปรตีนในเนื้อสัตว์ ไข่ นม ถั่ว ช่วยซ่อมแซมและเสริมสร้างร่างกายให้เติบโตแข็งแรง! 🥛"
	},
	{
		"q": "หากพบของมีค่าหรือเงินตกอยู่ในโรงเรียน ควรปฏิบัติตนอย่างไร?",
		"choices": ["ก. แอบเก็บไว้เอง", "ข. นำส่งคุณครูเพื่อหาเจ้าของ", "ค. ไม่สนใจ"],
		"correct": 1,
		"explain": "น่าชื่นชมมากจ้ะ! ความซื่อสัตย์สุจริตคือคุณธรรมสำคัญของคนดี! 💎"
	},
	{
		"q": "คำว่า 'โรงเรียน' มีพยัญชนะต้นตัวแรกคือพยัญชนะใด?",
		"choices": ["ก. ร.เรือ", "ข. ล.ลิง", "ค. อ.อ่าง"],
		"correct": 0,
		"explain": "ถูกต้องจ้ะ! 'โรงเรียน' ขึ้นต้นด้วย ร.เรือ ออกเสียง รัวลิ้นเบาๆ ให้ชัดเจนนะจ๊ะ! 📚"
	},
	{
		"q": "ขณะอ่านหนังสือหรือใช้คอมพิวเตอร์ ควรพักสายตาอย่างไรเพื่อถนอมสายตา?",
		"choices": ["ก. มองไกลๆ ไปที่ต้นไม้สีเขียว", "ข. จ้องหน้าจอใกล้ขึ้น", "ค. ขยี้ตาแรงๆ"],
		"correct": 0,
		"explain": "ถูกต้องจ้ะ! กฎ 20-20-20 คือพักมองไกลทุก 20 นาที เพื่อให้กล้ามเนื้อตาได้ผ่อนคลาย! 👁️"
	},
	{
		"q": "หากมีคนแปลกหน้ามาชวนไปกินขนมนอกโรงเรียน ควรทำอย่างไร?",
		"choices": ["ก. ปฏิเสธสุภาพและรีบแจ้งคุณครู", "ข. เดินตามไปทันที", "ค. ชวนเพื่อนไปด้วย"],
		"correct": 0,
		"explain": "ปลอดภัยที่สุดจ้ะ! ต้องปฏิเสธและรีบแจ้งคุณครูหรือผู้ปกครองทันทีนะเด็กๆ! 🛡️"
	}
]

var questions: Array[Dictionary] = []

func _ready() -> void:
	level_number = 6
	super._ready()

	# Randomize and pick 3 unique questions from the question bank for this session
	randomize()
	var pool := CLASSROOM_QUESTION_BANK.duplicate()
	pool.shuffle()
	questions = pool.slice(0, 3)
	current_q = 0

	if btn_a: btn_a.pressed.connect(func(): answer_chosen(0))
	if btn_b: btn_b.pressed.connect(func(): answer_chosen(1))
	if btn_c: btn_c.pressed.connect(func(): answer_chosen(2))

	if desk_a_area:
		desk_a_area.body_entered.connect(func(b): if b.is_in_group("players"): near_desk_a = true)
		desk_a_area.body_exited.connect(func(b): if b.is_in_group("players"): near_desk_a = false)
	if desk_b_area:
		desk_b_area.body_entered.connect(func(b): if b.is_in_group("players"): near_desk_b = true)
		desk_b_area.body_exited.connect(func(b): if b.is_in_group("players"): near_desk_b = false)
	if desk_c_area:
		desk_c_area.body_entered.connect(func(b): if b.is_in_group("players"): near_desk_c = true)
		desk_c_area.body_exited.connect(func(b): if b.is_in_group("players"): near_desk_c = false)

	if portal_canteen:
		portal_canteen.target_level = 7
		portal_canteen.target_spawn_x = 100.0
		portal_canteen.is_locked = true
		portal_canteen.lock_message = "ต้องตอบคำถามคาบเรียนหรรษาและช่วยคุณครูจัดโต๊ะก่อนนะจ๊ะ! 🔔"

	_show_question()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if current_q < questions.size():
			if event.physical_keycode == KEY_1 or event.physical_keycode == KEY_A:
				answer_chosen(0)
				get_viewport().set_input_as_handled()
			elif event.physical_keycode == KEY_2 or event.physical_keycode == KEY_B:
				answer_chosen(1)
				get_viewport().set_input_as_handled()
			elif event.physical_keycode == KEY_3 or event.physical_keycode == KEY_C:
				answer_chosen(2)
				get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	super._process(delta)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	# Physical buzzer check on desks
	if current_q < questions.size() and interact_pressed:
		if near_desk_a:
			answer_chosen(0)
		elif near_desk_b:
			answer_chosen(1)
		elif near_desk_c:
			answer_chosen(2)

	# Interact near blackboard (x: 560 - 720) to clean board & tidy books after quiz
	if current_q >= questions.size() and not GameManager.teacher_board_done:
		if (p1 and abs(p1.global_position.x - 640.0) < 110.0) or (p2 and abs(p2.global_position.x - 640.0) < 110.0):
			if interact_pressed:
				GameManager.teacher_board_done = true
				GameManager.complete_good_deed("q_teacher_board")
				question_label.text = "🎉 ลบกระดานสะอาดเอี่ยม & จัดสมุดการบ้านเรียบร้อยแล้ว!\nคุณครูมาลี: 'ขอบใจของขวัญกับปีใหม่มากจ้ะ ได้เวลาพักเที่ยงแล้ว ไปโรงอาหารกันเลย!' 🔔✨"
				if explanation_label:
					explanation_label.text = "ประตูทางไปโรงอาหารเปิดแล้ว! เดินไปทางขวาของห้องเรียนได้เลย ➡️"
					explanation_label.modulate = Color(0.4, 1.0, 0.6)
				if portal_canteen:
					portal_canteen.is_locked = false

func _show_question() -> void:
	if current_q < questions.size():
		var data: Dictionary = questions[current_q]
		question_label.text = "คำถามที่ %d: %s" % [current_q + 1, data["q"]]
		if badge_step:
			badge_step.text = "ข้อที่ %d / %d" % [current_q + 1, questions.size()]
		if badge_score:
			badge_score.text = "⭐ ตอบถูก: %d / %d" % [GameManager.classroom_quiz_score, questions.size()]
		if btn_a: btn_a.text = "%s  [กด 1]" % data["choices"][0]
		if btn_b: btn_b.text = "%s  [กด 2]" % data["choices"][1]
		if btn_c: btn_c.text = "%s  [กด 3]" % data["choices"][2]
	else:
		question_label.text = "🎉 ตอบคำถามถูกต้องครบทุกข้อแล้ว!\nเดินไปที่โต๊ะครูหน้ากระดานดำแล้วกด [E/Shift] เพื่อช่วยคุณครูลบกระดานและจัดสมุดการบ้านนะจ๊ะ!"
		if badge_step:
			badge_step.text = "สำเร็จครบ 3 ข้อ! 🏆"
		if badge_score:
			badge_score.text = "⭐ คะแนนรวม: %d / %d" % [GameManager.classroom_quiz_score, questions.size()]
		if explanation_label:
			explanation_label.text = "🧹 เดินไปหน้ากระดานดำแล้วกดปุ่มโต้ตอบ [E / Shift] เพื่อช่วยคุณครูลบกระดาน"
			explanation_label.modulate = Color(1.0, 0.92, 0.4)
		if btn_a: btn_a.visible = false
		if btn_b: btn_b.visible = false
		if btn_c: btn_c.visible = false
		if indicator_a: indicator_a.visible = false
		if indicator_b: indicator_b.visible = false
		if indicator_c: indicator_c.visible = false
		GameManager.start_good_deed("q_teacher_board")
		if portal_canteen:
			portal_canteen.is_locked = false

func answer_chosen(choice_idx: int) -> void:
	if current_q >= questions.size():
		return

	var data: Dictionary = questions[current_q]
	if choice_idx == data["correct"]:
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.add_star()
		GameManager.classroom_quiz_score += 1
		if explanation_label:
			explanation_label.text = data["explain"]
			explanation_label.modulate = Color(0.4, 1.0, 0.6)
		GameManager.dialog_triggered.emit("คุณครูมาลี", data["explain"], "res://assets/characters/npcs/npc_teacher.png")
		current_q += 1
		_show_question()
	else:
		if AudioManager:
			AudioManager.play_sfx("wrong")
		if explanation_label:
			explanation_label.text = "❌ ยังไม่ถูกต้องจ้ะ ลองสังเกตคำใบ้แล้วเลือกใหม่อีกครั้งนะ!"
			explanation_label.modulate = Color(1.0, 0.45, 0.45)
		GameManager.dialog_triggered.emit("คุณครูมาลี", "ยังไม่ถูกต้องจ้ะ ลองสังเกตและช่วยกันคิดดูอีกครั้งนะ!", "res://assets/characters/npcs/npc_teacher.png")
