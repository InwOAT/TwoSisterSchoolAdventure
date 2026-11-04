extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var grandma_area: Area2D = $GrandmaArea
@onready var prompt_grandma: Label = $GrandmaArea/PromptLabel
@onready var tea_table: Area2D = $TeaTableArea
@onready var prompt_table: Label = $TeaTableArea/PromptLabel

var near_grandma: bool = false
var near_table: bool = false
var tea_drank: bool = false

func _ready() -> void:
	level_number = 205
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 230.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false

	if grandma_area:
		grandma_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_grandma = true
				if prompt_grandma: prompt_grandma.visible = true
		)
		grandma_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_grandma = false
				if prompt_grandma: prompt_grandma.visible = false
		)

	if tea_table:
		tea_table.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_table = true
				if prompt_table: prompt_table.visible = true
		)
		tea_table.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_table = false
				if prompt_table: prompt_table.visible = false
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_grandma:
			_interact_grandma()
		elif near_table:
			_interact_table()

func _interact_grandma() -> void:
	if not tea_drank:
		GameManager.dialog_triggered.emit(
			"คุณยายใจดี",
			"สวัสดีจ้าหลานของขวัญและน้องปีใหม่! 👵 วันนี้ตื่นแต่เช้าจะไปโรงเรียนกันสินะลูก ดื่มน้ำชาอุ่นๆ หรือทานขนมทองหยอดที่โต๊ะก่อนได้นะจ๊ะ จะได้สดชื่นมีแรงเรียนหนังสือ!",
			"res://assets/characters/npcs/npc_grandma.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"คุณยายใจดี",
			"เด็กดีมีมารยาท เดินทางไปโรงเรียนให้ปลอดภัยนะลูก ข้ามถนนดูซ้ายดูขวาให้ดีๆ นะจ๊ะ! 👵 ✨",
			"res://assets/characters/npcs/npc_grandma.png"
		)

func _interact_table() -> void:
	if not tea_drank:
		tea_drank = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"โต๊ะน้ำชาไม้สักโบราณ",
			"🍵 สองพี่น้องจิบน้ำชาสมุนไพรอุ่นๆ และทานขนมไทยแสนอร่อยอย่างสุภาพเรียบร้อย ได้รับ 'แต้มมารยาทและความสดชื่น' +1 ดาว! ⭐",
			""
		)
	else:
		GameManager.dialog_triggered.emit(
			"โต๊ะน้ำชาไม้สักโบราณ",
			"กาน้ำชาและถ้วยเซรามิกโบราณจัดวางอย่างเป็นระเบียบสวยงาม 🍵",
			""
		)
