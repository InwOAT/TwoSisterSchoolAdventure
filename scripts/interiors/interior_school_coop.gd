extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var vendor_area: Area2D = $VendorArea
@onready var prompt_vendor: Label = $VendorArea/PromptLabel
@onready var badge_vendor: Label = $VendorArea/QuestBadge
@onready var stationary_area: Area2D = $StationaryArea
@onready var prompt_stationery: Label = $StationaryArea/PromptLabel
@onready var coop_shelf_prop: Sprite2D = $CoopShelfProp

var near_vendor: bool = false
var near_stationery: bool = false

func _ready() -> void:
	level_number = 803
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_8.tscn"
		exit_portal.target_spawn_x = 1660.0
		exit_portal.target_level = 8
		exit_portal.portal_name = "ออกไปลานเกษตรโรงเรียน"
		exit_portal.is_locked = false
	
	if vendor_area:
		vendor_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_vendor = true
				if prompt_vendor: prompt_vendor.visible = true
		)
		vendor_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_vendor = false
				if prompt_vendor: prompt_vendor.visible = false
		)
	
	if stationary_area:
		stationary_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_stationery = true
				if prompt_stationery: prompt_stationery.visible = true
		)
		stationary_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_stationery = false
				if prompt_stationery: prompt_stationery.visible = false
		)
	
	_update_badges()
	
	await get_tree().create_timer(0.4).timeout
	if not GameManager.coop_supplies_bought:
		GameManager.dialog_triggered.emit(
			"ป้าแอ๋ว (ร้านค้าสหกรณ์โรงเรียน)",
			"สวัสดีจ้าเด็กๆ! สหกรณ์โรงเรียนชุมชนหนองเรือมีทั้งเครื่องเขียน นมกล่อง และปุ๋ยชีวภาพสำหรับแปลงเกษตร ถ้ามีคูปองหรือเหรียญบาท นำมาแลกซื้อของได้เลยนะจ๊ะ! 🛒 ✏️",
			"res://assets/characters/npcs/npc_vendor.png"
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_vendor:
			_interact_vendor()
		elif near_stationery:
			_interact_stationery()

func _interact_vendor() -> void:
	if GameManager.has_item("คูปองสหกรณ์"):
		GameManager.remove_item("คูปองสหกรณ์")
		GameManager.add_item("ปุ๋ยอินทรีย์")
		GameManager.coop_supplies_bought = true
		GameManager.add_star()
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"ป้าแอ๋ว (ร้านค้าสหกรณ์โรงเรียน)",
			"นำคูปองรางวัลความดี 10 บาทมาแลกซื้อ 'ถุงปุ๋ยอินทรีย์ชีวภาพ' เรียบร้อยจ้า! ปุ๋ยนี้อุดมด้วยสารอาหารบำรุงดินอย่างดี รีบนำไปใส่แปลงดอกไม้ริมสระน้ำนะเด็กดี! 🌱 🌸 ⭐⭐",
			"res://assets/characters/npcs/npc_vendor.png"
		)
	elif not GameManager.coop_supplies_bought:
		GameManager.coop_supplies_bought = true
		if not GameManager.has_item("ปุ๋ยอินทรีย์"):
			GameManager.add_item("ปุ๋ยอินทรีย์")
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"ป้าแอ๋ว (ร้านค้าสหกรณ์โรงเรียน)",
			"ยินดีต้อนรับจ้ะ! ป้าจัดชุดเครื่องเขียนและ 'ปุ๋ยอินทรีย์' ให้เด็กดีทั้งสองคนเลยนะ นำไปบำรุงแปลงดอกไม้โรงเรียนให้สวยงามได้เลยจ้ะ! ✏️ 🌱 ⭐",
			"res://assets/characters/npcs/npc_vendor.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ป้าแอ๋ว (ร้านค้าสหกรณ์โรงเรียน)",
			"ได้อุปกรณ์และปุ๋ยอินทรีย์ครบถ้วนแล้ว! รีบนำไปดูแลแปลงดอกไม้ให้บานสะพรั่งนะจ๊ะเด็กๆ! 💖 ✨",
			"res://assets/characters/npcs/npc_vendor.png"
		)
	_update_badges()

func _interact_stationery() -> void:
	GameManager.add_star()
	if AudioManager:
		AudioManager.play_sfx("correct")
	GameManager.dialog_triggered.emit(
		"ชั้นวางเครื่องเขียนและสมุดการบ้าน",
		"✏️ [ชั้นวางอุปกรณ์การเรียนสหกรณ์]:\nมีดินสอ 2B ยางลบก้อนนุ่ม และไม้บรรทัดใส ครบถ้วนสำหรับเตรียมตัวทำการบ้านช่วงเย็นอย่างมีประสิทธิภาพ! 📐 📝 ⭐",
		""
	)

func _update_badges() -> void:
	if badge_vendor:
		if GameManager.coop_supplies_bought:
			badge_vendor.text = "✅ แลกซื้อปุ๋ยอินทรีย์และเครื่องเขียนเรียบร้อย"
			badge_vendor.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_vendor.text = "💡 แลกซื้อปุ๋ยอินทรีย์และเครื่องเขียน [!]"
			badge_vendor.modulate = Color(1.0, 0.9, 0.3)
