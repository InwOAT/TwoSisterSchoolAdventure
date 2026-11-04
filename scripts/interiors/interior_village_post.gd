extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var officer_area: Area2D = $PostOfficerArea
@onready var prompt_officer: Label = $PostOfficerArea/PromptLabel
@onready var scale_area: Area2D = $ScaleArea
@onready var prompt_scale: Label = $ScaleArea/PromptLabel

var near_officer: bool = false
var near_scale: bool = false
var postcard_stamped: bool = false

func _ready() -> void:
	level_number = 211
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 3950.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false

	if officer_area:
		officer_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_officer = true
				if prompt_officer: prompt_officer.visible = true
		)
		officer_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_officer = false
				if prompt_officer: prompt_officer.visible = false
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

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_officer:
			_interact_officer()
		elif near_scale:
			_interact_scale()

func _interact_officer() -> void:
	if not postcard_stamped:
		postcard_stamped = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"พี่เจ้าหน้าที่ไปรษณีย์",
			"สวัสดีจ้าเด็กๆ! 📮 ไปรษณีย์ไทยสาขาดอนโมงยินดีต้อนรับจ้า! วันนี้มีโปสการ์ดภาพวาดหมู่บ้านดอนโมงที่ระลึกแจกให้น้องๆ ช่วยกันติดแสตมป์ส่งความสุขให้คุณปู่คุณย่าด้วยนะจ๊ะ! +1 ดาวการสื่อสาร! ⭐",
			"res://assets/characters/npcs/npc_station_master.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"พี่เจ้าหน้าที่ไปรษณีย์",
			"ส่งจดหมายหรือพัสดุ ต้องเขียนจ่าหน้าซองชื่อผู้รับและรหัสไปรษณีย์ 5 หลักให้ชัดเจนเสมอ พัสดุก็จะถึงมือผู้รับอย่างรวดเร็วและปลอดภัยจ้า! 📮 📦",
			"res://assets/characters/npcs/npc_station_master.png"
		)

func _interact_scale() -> void:
	GameManager.dialog_triggered.emit(
		"เครื่องชั่งพัสดุดิจิทัล",
		"⚖️ เครื่องชั่งน้ำหนักพัสดุแม่นยำสูง แสดงน้ำหนักพัสดุมาตรฐานเพื่อคำนวณอัตราค่าบริการอย่างเที่ยงตรง",
		""
	)
