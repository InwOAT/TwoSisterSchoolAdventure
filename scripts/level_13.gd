extends BaseLevel

@onready var homework_area: Area2D = $HomeworkArea
@onready var prompt_desk: Label = $HomeworkArea/PromptLabel
@onready var desk_label: Label = $HomeworkArea/Label

@onready var parent_group: Node2D = $ParentGroup
@onready var dad_sprite: Sprite2D = $ParentGroup/DadSprite
@onready var mom_sprite: Sprite2D = $ParentGroup/MomSprite

@onready var homework_modal: CanvasLayer = $HomeworkModal
@onready var subject_badge: Label = $HomeworkModal/Card/VBox/Header/SubjectBadge
@onready var question_label: Label = $HomeworkModal/Card/VBox/QuestionLabel
@onready var btn_c1: Button = $HomeworkModal/Card/VBox/BtnChoice1
@onready var btn_c2: Button = $HomeworkModal/Card/VBox/BtnChoice2
@onready var btn_c3: Button = $HomeworkModal/Card/VBox/BtnChoice3

@onready var ending_layer: CanvasLayer = $EndingLayer
@onready var confetti: CPUParticles2D = $EndingLayer/ConfettiParticles
@onready var score_label: Label = $EndingLayer/EndingCard/VBox/ScoreLabel
@onready var title_label: Label = $EndingLayer/EndingCard/VBox/TitleLabel
@onready var btn_restart: Button = $EndingLayer/EndingCard/VBox/BtnRestart

var near_desk: bool = false
var homework_completed: bool = false
var parents_arrived: bool = false
var current_question_index: int = 0
var parents_walking: bool = false
var parents_target_x: float = 340.0

# Question Pool 1: คณิตศาสตร์ (Math & Logic - 5 questions)
const MATH_POOL: Array[Dictionary] = [
	{
		"question": "หากซื้อสมุดเล่มละ 15 บาท จ่ายด้วยธนบัตร 20 บาท แม่ค้าจะทอนเงินกี่บาท?",
		"choices": ["A. 3 บาท [กด 1]", "B. 5 บาท [กด 2]", "C. 10 บาท [กด 3]"],
		"correct": 1
	},
	{
		"question": "ถ้าสองพี่น้องช่วยกันหยอดกระปุกออมสินวันละ 10 บาท เป็นเวลา 5 วัน จะมีเงินออมรวมกี่บาท?",
		"choices": ["A. 40 บาท [กด 1]", "B. 50 บาท [กด 2]", "C. 60 บาท [กด 3]"],
		"correct": 1
	},
	{
		"question": "ซื้อดินสอแท่งละ 6 บาท และยางลบก้อนละ 4 บาท รวมเป็นเงินต้องจ่ายกี่บาท?",
		"choices": ["A. 10 บาท [กด 1]", "B. 12 บาท [กด 2]", "C. 14 บาท [กด 3]"],
		"correct": 0
	},
	{
		"question": "เริ่มทำการบ้านเวลา 18:00 น. ทำเสร็จเวลา 18:45 น. ใช้เวลาทำการบ้านทั้งหมดกี่นาที?",
		"choices": ["A. 30 นาที [กด 1]", "B. 45 นาที [กด 2]", "C. 60 นาที [กด 3]"],
		"correct": 1
	},
	{
		"question": "มีขนมคุ้กกี้ 12 ชิ้น แบ่งให้พี่ของขวัญและน้องปีใหม่เท่าๆ กัน จะได้คนละกี่ชิ้น?",
		"choices": ["A. คนละ 4 ชิ้น [กด 1]", "B. คนละ 6 ชิ้น [กด 2]", "C. คนละ 8 ชิ้น [กด 3]"],
		"correct": 1
	}
]

# Question Pool 2: ภาษาไทย & มารยาท (Thai Language & Etiquette - 5 questions)
const THAI_POOL: Array[Dictionary] = [
	{
		"question": "การแสดงความเคารพต่อคุณครูและผู้ใหญ่ตามมารยาทไทย ควรปฏิบัติอย่างไร?",
		"choices": ["A. ยกมือไหว้พร้อมกล่าวสวัสดีค่ะ/ครับ [กด 1]", "B. โบกมือทักทาย [กด 2]", "C. ก้มหน้าเดินผ่าน [กด 3]"],
		"correct": 0
	},
	{
		"question": "เมื่อได้รับความช่วยเหลือหรือสิ่งของจากผู้อื่น ควรกล่าวคำใดเป็นอันดับแรก?",
		"choices": ["A. ขอบคุณค่ะ / ขอบคุณครับ [กด 1]", "B. ขอโทษค่ะ / ขอโทษครับ [กด 2]", "C. ไม่เป็นไร [กด 3]"],
		"correct": 0
	},
	{
		"question": "หากเผลอทำน้ำหกใส่โต๊ะ หรือเดินชนผู้อื่นโดยไม่ได้ตั้งใจ ควรพูดว่าอย่างไร?",
		"choices": ["A. ไม่เกี่ยวกัน [กด 1]", "B. ขอโทษค่ะ / ขอโทษครับ [กด 2]", "C. หัวเราะใส่ [กด 3]"],
		"correct": 1
	},
	{
		"question": "เมื่อพบคนชรา สตรีมีครรภ์ หรือผู้พิการขึ้นมาบนรถประจำทาง ควรทำอย่างไร?",
		"choices": ["A. มีน้ำใจสละที่นั่งให้ท่าน [กด 1]", "B. นั่งไขว่ห้างแกล้งหลับ [กด 2]", "C. วางกระเป๋าจองที่นั่ง [กด 3]"],
		"correct": 0
	},
	{
		"question": "การปฏิบัติตนเป็นลูกที่ดีและแสดงความกตัญญูกตเวทิตาต่อพ่อแม่ ควรทำอย่างไร?",
		"choices": ["A. เชื่อฟังคำสอนและช่วยเหลืองานบ้าน [กด 1]", "B. งอแงขอซื้อของเล่นราคาแพง [กด 2]", "C. เล่นเกมทั้งวันไม่ช่วยงาน [กด 3]"],
		"correct": 0
	}
]

# Question Pool 3: สุขศึกษา & จิตอาสา (Health, Science & Community - 5 questions)
const HEALTH_POOL: Array[Dictionary] = [
	{
		"question": "การรับประทานอาหารให้ครบ 5 หมู่ และช่วยเก็บจานข้าวหลังรับประทานเสร็จ มีประโยชน์อย่างไร?",
		"choices": ["A. ได้กินแต่ขนมหวาน [กด 1]", "B. ทำให้ร่างกายแข็งแรง และมีระเบียบวินัย [กด 2]", "C. ไม่ต้องออกกำลังกาย [กด 3]"],
		"correct": 1
	},
	{
		"question": "เด็กวัยเรียนควรเข้านอนแต่หัวค่ำและนอนหลับพักผ่อนให้เพียงพอวันละกี่ชั่วโมง?",
		"choices": ["A. 4 - 5 ชั่วโมง [กด 1]", "B. 8 - 10 ชั่วโมง [กด 2]", "C. 14 ชั่วโมง [กด 3]"],
		"correct": 1
	},
	{
		"question": "เมื่อกลับถึงบ้าน ควรทำสิ่งใดเป็นอันดับแรกเพื่อสุขอนามัยที่ดีของตนเองและครอบครัว?",
		"choices": ["A. ถอดรองเท้าจัดเข้าชั้นและล้างมือให้สะอาด [กด 1]", "B. วิ่งขึ้นเตียงนอนทันที [กด 2]", "C. หยิบขนมกินโดยไม่ล้างมือ [กด 3]"],
		"correct": 0
	},
	{
		"question": "เศษอาหารและเปลือกผลไม้เหลือทิ้ง ควรทิ้งลงในถังขยะประเภทใด?",
		"choices": ["A. ถังขยะเปียก (ย่อยสลายได้) [กด 1]", "B. ถังขยะรีไซเคิล [กด 2]", "C. ถังขยะอันตราย [กด 3]"],
		"correct": 0
	},
	{
		"question": "ข้อใดเป็นการช่วยประหยัดพลังงานไฟฟ้าและลดภาวะโลกร้อนในบ้าน?",
		"choices": ["A. ปิดไฟและพัดลมเมื่อไม่ได้ใช้งาน [กด 1]", "B. เปิดไฟทิ้งไว้ทั้งคืน [กด 2]", "C. เปิดตู้เย็นทิ้งไว้ [กด 3]"],
		"correct": 0
	}
]

var active_questions: Array[Dictionary] = []

func _ready() -> void:
	level_number = 13
	super._ready()

	if homework_area:
		if prompt_desk and GameManager:
			GameManager.style_prompt_label(prompt_desk)
		homework_area.body_entered.connect(func(b): if b.is_in_group("players"): near_desk = true; prompt_desk.visible = not homework_completed)
		homework_area.body_exited.connect(func(b): if b.is_in_group("players"): near_desk = false; prompt_desk.visible = false)

	if btn_c1: btn_c1.pressed.connect(func(): _answer_question(0))
	if btn_c2: btn_c2.pressed.connect(func(): _answer_question(1))
	if btn_c3: btn_c3.pressed.connect(func(): _answer_question(2))

	if btn_restart:
		btn_restart.pressed.connect(func():
			GameManager.reset_all_state()
			GameManager.change_level(1, 120.0)
		)

	if ending_layer:
		ending_layer.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if homework_modal and homework_modal.visible:
			if event.physical_keycode == KEY_1 or event.physical_keycode == KEY_A:
				_answer_question(0)
				get_viewport().set_input_as_handled()
			elif event.physical_keycode == KEY_2 or event.physical_keycode == KEY_B:
				_answer_question(1)
				get_viewport().set_input_as_handled()
			elif event.physical_keycode == KEY_3 or event.physical_keycode == KEY_C:
				_answer_question(2)
				get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	super._process(delta)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	if near_desk and interact_pressed and not homework_completed:
		_open_homework_modal()

	# Parents walking animation into bedroom
	if parents_walking and parent_group:
		parent_group.position.x += 160.0 * delta
		var bob := sin(Time.get_ticks_msec() * 0.015) * 3.0
		if dad_sprite: dad_sprite.position.y = -134.0 + bob
		if mom_sprite: mom_sprite.position.y = -134.0 - bob
		if parent_group.position.x >= parents_target_x:
			parent_group.position.x = parents_target_x
			parents_walking = false
			_trigger_parents_dialog()

func _open_homework_modal() -> void:
	if homework_completed:
		return

	# Randomly pick 1 question from Math, 1 from Thai, 1 from Health for this study session
	randomize()
	var q1: Dictionary = MATH_POOL[randi() % MATH_POOL.size()].duplicate()
	q1["subject"] = "📚 วิชาที่ 1/3: คณิตศาสตร์ (การคิดเลข & การออม)"

	var q2: Dictionary = THAI_POOL[randi() % THAI_POOL.size()].duplicate()
	q2["subject"] = "🙏 วิชาที่ 2/3: ภาษาไทย & มารยาท (สัมมาคารวะ)"

	var q3: Dictionary = HEALTH_POOL[randi() % HEALTH_POOL.size()].duplicate()
	q3["subject"] = "🥗 วิชาที่ 3/3: สุขศึกษา & จิตอาสา (สุขอนามัย)"

	active_questions = [q1, q2, q3]
	current_question_index = 0
	_show_question(current_question_index)
	homework_modal.visible = true

func _show_question(idx: int) -> void:
	if idx >= active_questions.size():
		_complete_homework()
		return
	var q: Dictionary = active_questions[idx]
	subject_badge.text = q["subject"]
	question_label.text = q["question"]
	btn_c1.text = q["choices"][0]
	btn_c2.text = q["choices"][1]
	btn_c3.text = q["choices"][2]

func _answer_question(choice: int) -> void:
	if current_question_index >= active_questions.size():
		return
	var q: Dictionary = active_questions[current_question_index]
	if choice == q["correct"]:
		if AudioManager:
			AudioManager.play_sfx("coin")
		current_question_index += 1
		if current_question_index >= active_questions.size():
			_complete_homework()
		else:
			_show_question(current_question_index)
	else:
		GameManager.dialog_triggered.emit("ตรวจคำตอบ", "เอ๊ะ ข้อนี้ยังไม่ถูกต้องนะจ๊ะ ลองคิดทบทวนดูอีกครั้ง!", "")

func _complete_homework() -> void:
	homework_completed = true
	homework_modal.visible = false
	prompt_desk.visible = false
	desk_label.text = "✅ ทำการบ้านเสร็จครบทุกวิชาแล้ว!"
	desk_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))

	GameManager.add_star()
	GameManager.good_deed_points += 30
	GameManager.stars_changed.emit()

	# Start parents walking into bedroom
	_parents_walk_in()

func _parents_walk_in() -> void:
	if parents_arrived:
		return
	parents_arrived = true
	if parent_group:
		parent_group.position.x = 40.0
		parent_group.visible = true
	parents_walking = true

func _trigger_parents_dialog() -> void:
	GameManager.dialog_triggered.emit(
		"คุณพ่อ & คุณแม่",
		"👨‍👩‍👧‍👧 คุณพ่อ: 'พ่อกับแม่เห็นลูกๆ ตั้งใจทำการบ้านจนเสร็จ และช่วยเหลืองานบ้านตลอดวัน พ่อภูมิใจในตัวลูกทั้งสองมากนะจ๊ะ ❤️'\n\n👩 คุณแม่: 'วันนี้พี่ของขวัญและน้องปีใหม่ทำความดีมากมาย ทั้งช่วยแม่เก็บโต๊ะ กวาดบ้าน แยกขยะ มีน้ำใจกับเพื่อน และตั้งใจเรียน ลูกคือของขวัญที่ดีที่สุดของพ่อกับแม่จ้ะ คืนนี้พักผ่อนให้สบาย นอนหลับฝันดีนะลูกรัก ราตรีสวัสดิ์จ้ะ 🌙✨'",
		"res://assets/characters/npcs/portrait_dad.png"
	)

	# Show Ending Screen after dialog
	get_tree().create_timer(4.5).timeout.connect(_show_ending_screen)

func _show_ending_screen() -> void:
	if ending_layer:
		score_label.text = "💖 แต้มความดีรวม: %d แต้ม   |   ⭐ ดาวมารยาท: %d ดวง" % [GameManager.good_deed_points, GameManager.etiquette_stars]
		title_label.text = "🏆 ฉายาที่ได้รับ: " + GameManager.get_good_deed_title()
		ending_layer.visible = true
		if confetti:
			confetti.emitting = true
		if AudioManager:
			AudioManager.play_sfx("applause")
