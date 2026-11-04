extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var barista_area: Area2D = $BaristaArea
@onready var prompt_barista: Label = $BaristaArea/PromptLabel
@onready var menu_board: Area2D = $MenuArea
@onready var prompt_menu: Label = $MenuArea/PromptLabel

var near_barista: bool = false
var near_menu: bool = false
var milk_ordered: bool = false

func _ready() -> void:
	level_number = 206
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 760.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false

	if barista_area:
		barista_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_barista = true
				if prompt_barista: prompt_barista.visible = true
		)
		barista_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_barista = false
				if prompt_barista: prompt_barista.visible = false
		)

	if menu_board:
		menu_board.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_menu = true
				if prompt_menu: prompt_menu.visible = true
		)
		menu_board.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_menu = false
				if prompt_menu: prompt_menu.visible = false
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_barista:
			_interact_barista()
		elif near_menu:
			_interact_menu()

func _interact_barista() -> void:
	if not milk_ordered:
		milk_ordered = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"พี่บาริสต้าตูน",
			"สวัสดีจ้าของขวัญกับปีใหม่! ☕ Clock Fee ยินดีต้อนรับจ้า! เช้าๆ แบบนี้สำหรับน้องๆ วัยเรียน พี่ชง 'นมอุ่นมอลต์น้ำผึ้ง' ร้อนๆ บำรุงสมองให้ดื่มฟรีคนละแก้วนะจ๊ะ! +1 ดาวคนเก่ง! ⭐",
			"res://assets/characters/npcs/npc_station_master.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"พี่บาริสต้าตูน",
			"ทานให้อร่อยนะเด็กๆ ดื่มนมก่อนไปเรียนจะช่วยให้สมาธิดีตลอดทั้งวันเลยจ้า! 🥛 ☕",
			"res://assets/characters/npcs/npc_station_master.png"
		)

func _interact_menu() -> void:
	GameManager.dialog_triggered.emit(
		"กระดานเมนู Clock Fee",
		"📋 เมนูแนะนำเช้านี้: นมสดฮอกไกโดอุ่น, ชาเขียวมัทฉะน้ำผึ้ง, มินิครัวซองต์เนยสด 🥐 🥛",
		""
	)
