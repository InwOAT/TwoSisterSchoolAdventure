extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var fruit_vendor: Area2D = $FruitVendorArea
@onready var prompt_fruit: Label = $FruitVendorArea/PromptLabel
@onready var cat_box: Area2D = $CatBasketArea
@onready var prompt_cat: Label = $CatBasketArea/PromptLabel

var near_vendor: bool = false
var near_cat: bool = false

func _ready() -> void:
	level_number = 207
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 1050.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false

	if fruit_vendor:
		fruit_vendor.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_vendor = true
				if prompt_fruit: prompt_fruit.visible = true
		)
		fruit_vendor.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_vendor = false
				if prompt_fruit: prompt_fruit.visible = false
		)

	if cat_box:
		cat_box.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_cat = true
				if prompt_cat: prompt_cat.visible = true
		)
		cat_box.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_cat = false
				if prompt_cat: prompt_cat.visible = false
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_vendor:
			_interact_vendor()
		elif near_cat:
			_interact_cat()

func _interact_vendor() -> void:
	GameManager.dialog_triggered.emit(
		"ป้าเพ็ญ แผงผลไม้สดคลองถม",
		"ผลไม้สดๆ จากสวนจ้าเด็กๆ ส้มสายน้ำผึ้ง กล้วยน้ำว้า แตงโมหวานฉ่ำ ทานผลไม้ทุกวันทำให้ร่างกายแข็งแรง ขับถ่ายสะดวก มีวิตามินซีสูงป้องกันหวัดนะจ๊ะ! 🍊 🍌",
		"res://assets/characters/npcs/npc_fruit_vendor.png"
	)

func _interact_cat() -> void:
	if not GameManager.village_cat_found and not GameManager.village_cat_returned:
		GameManager.village_cat_found = true
		GameManager.add_item("ลูกแมวเจ้าส้ม")
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"กล่องผลไม้ข้างแผง",
			"เหมียว~ 🐱 น้องปีใหม่ได้ยินเสียงร้องเบาๆ! พบ 'ลูกแมวเจ้าส้ม' นอนขดตัวหลบอยู่หลังลังผลไม้! รีบพาไปแจ้งคุณตำรวจที่ป้อมกันเถอะ!",
			""
		)
	elif GameManager.has_item("ลูกแมวเจ้าส้ม"):
		GameManager.dialog_triggered.emit(
			"กล่องผลไม้ข้างแผง",
			"อุ้มลูกแมวเจ้าส้มไว้ในอ้อมกอดแล้ว รีบนำไปส่งที่คุณตำรวจที่ป้อมเทศบาลดอนโมงนะจ๊ะ! 🐱",
			""
		)
	else:
		GameManager.dialog_triggered.emit(
			"กล่องผลไม้ข้างแผง",
			"ลังผลไม้และตระกร้าสานจัดวางเรียบร้อย ลูกแมวเจ้าส้มได้กลับบ้านอย่างปลอดภัยแล้วจ้า 🐱 ✨",
			""
		)
