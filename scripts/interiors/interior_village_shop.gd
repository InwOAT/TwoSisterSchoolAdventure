extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var uncle_sit_area: Area2D = $UncleSitArea
@onready var prompt_uncle: Label = $UncleSitArea/PromptLabel
@onready var badge_uncle: Label = $UncleSitArea/QuestBadge
@onready var shelf_prop: Sprite2D = $ShelfProp

var near_uncle: bool = false
var math_quiz_active: bool = false

func _ready() -> void:
	level_number = 201
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 1850.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false
	
	if uncle_sit_area:
		uncle_sit_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_uncle = true
				if prompt_uncle: prompt_uncle.visible = true
		)
		uncle_sit_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_uncle = false
				if prompt_uncle: prompt_uncle.visible = false
		)
	
	_update_badges()
	
	# Friendly welcome dialog
	await get_tree().create_timer(0.4).timeout
	if not GameManager.shop_groceries_bought:
		GameManager.dialog_triggered.emit(
			"ลุงสิทธิ์ (ร้านชำ & Lotus's)",
			"สวัสดีจ้าของขวัญและปีใหม่! เดินเข้ามาในร้านลุงสิทธิ์แล้ว อากาศเย็นสบายไหม? ป้าสมศรีฝากมาซื้อของใช่ไหมจ๊ะ เข้ามาหาลุงที่เคาน์เตอร์ได้เลย! 🥚🥛",
			"res://assets/characters/npcs/npc_uncle_somkiat.png"
		)

func _process(_delta: float) -> void:
	if near_uncle and (Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")):
		_interact_uncle()

func _interact_uncle() -> void:
	if not GameManager.shop_groceries_bought:
		# Mini interaction / quiz for change calculation
		GameManager.dialog_triggered.emit(
			"ลุงสิทธิ์ (ร้านชำ & Lotus's)",
			"ป้าสมศรีให้เงินมา 20 บาท ซื้อ 'ไข่ไก่สด' 10 บาท และ 'นมถั่วเหลือง' 5 บาท รวมเป็น 15 บาท...\nเด็กๆ ช่วยลุงคิดหน่อยสิจ๊ะว่า 20 บาท ลบ 15 บาท ลุงต้องทอนเงินให้กี่บาท? (ตอบ 5 บาทในใจ แล้วลุงหยิบของให้เลยนะ!) 🥚🥛✨",
			"res://assets/characters/npcs/npc_uncle_somkiat.png"
		)
		
		# Award items and complete errand
		GameManager.shop_groceries_bought = true
		GameManager.add_item("ไข่ไก่สดและนมถั่วเหลือง")
		GameManager.complete_good_deed("q_auntie_errand")
		GameManager.add_star()
		
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("coin")
			AudioManager.play_sfx("sister_cheer")
			
		_update_badges()
	else:
		GameManager.dialog_triggered.emit(
			"ลุงสิทธิ์ (ร้านชำ & Lotus's)",
			"ได้ไข่ไก่สด นมถั่วเหลือง และเงินทอน 5 บาทครบถ้วนแล้ว! รีบเดินออกประตูทางซ้าย นำไปให้ป้าสมศรีที่นั่งพักรออยู่ที่ศาลาพักใจนะจ๊ะเด็กดี! 💖",
			"res://assets/characters/npcs/npc_uncle_somkiat.png"
		)

func _update_badges() -> void:
	if badge_uncle:
		if GameManager.shop_groceries_bought:
			badge_uncle.text = "✅ ซื้อของและรับเงินทอนเรียบร้อย"
			badge_uncle.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_uncle.text = "💡 ซื้อของให้ป้าสมศรี [!]"
			badge_uncle.modulate = Color(1.0, 0.9, 0.3)
