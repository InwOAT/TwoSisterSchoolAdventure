extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var gardner_area: Area2D = $GardnerArea
@onready var prompt_gardner: Label = $GardnerArea/PromptLabel
@onready var herb_area: Area2D = $HerbArea
@onready var prompt_herb: Label = $HerbArea/PromptLabel

var near_gardner: bool = false
var near_herb: bool = false
var tea_brewed: bool = false

func _ready() -> void:
	level_number = 210
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 3660.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false

	if gardner_area:
		gardner_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_gardner = true
				if prompt_gardner: prompt_gardner.visible = true
		)
		gardner_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_gardner = false
				if prompt_gardner: prompt_gardner.visible = false
		)

	if herb_area:
		herb_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_herb = true
				if prompt_herb: prompt_herb.visible = true
		)
		herb_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_herb = false
				if prompt_herb: prompt_herb.visible = false
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_gardner:
			_interact_gardner()
		elif near_herb:
			_interact_herb()

func _interact_gardner() -> void:
	if not tea_brewed:
		tea_brewed = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"ลุงอิน คนสวนใจดี",
			"ยินดีต้อนรับสู่บ้านสวนร่มเย็นจ้ะเด็กๆ! 🌳 ลุงปลูกสมุนไพรพื้นบ้าน ทั้งใบเตยหอม ตะไคร้ และอัญชัน ดื่มน้ำสมุนไพรต้มช่วยดับกระหาย คลายร้อน และมีประโยชน์ต่อสายตามากนะลูก! +1 ดาวธรรมชาติศึกษา! ⭐",
			"res://assets/characters/npcs/npc_grandpa.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ลุงอิน คนสวนใจดี",
			"การดูแลต้นไม้ต้องรดน้ำสม่ำเสมอ พรวนดิน และใช้ปุ๋ยอินทรีย์ธรรมชาติ ต้นไม้ก็จะเติบโตเขียวชอุ่มให้ร่มเงาจ้ะ! 🌿 🌳",
			"res://assets/characters/npcs/npc_grandpa.png"
		)

func _interact_herb() -> void:
	GameManager.dialog_triggered.emit(
		"ชั้นตากสมุนไพรอบแห้ง",
		"🌿 สมุนไพรอบแห้งส่งกลิ่นหอมชื่นใจ: ใบเตยหอม ดอกอัญชัน ตะไคร้หอม ปลอดสารพิษ 100%",
		""
	)
