extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var police_area: Area2D = $PoliceArea
@onready var prompt_police: Label = $PoliceArea/PromptLabel
@onready var badge_police: Label = $PoliceArea/QuestBadge
@onready var board_area: Area2D = $BoardArea
@onready var prompt_board: Label = $BoardArea/PromptLabel
@onready var counter_prop: Sprite2D = $CounterProp

var near_police: bool = false
var near_board: bool = false

func _ready() -> void:
	level_number = 202
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 450.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false
	
	if police_area:
		police_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_police = true
				if prompt_police: prompt_police.visible = true
		)
		police_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_police = false
				if prompt_police: prompt_police.visible = false
		)
	
	if board_area:
		board_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_board = true
				if prompt_board: prompt_board.visible = true
		)
		board_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_board = false
				if prompt_board: prompt_board.visible = false
		)
	
	_update_badges()
	
	await get_tree().create_timer(0.4).timeout
	if not GameManager.police_safety_done:
		GameManager.dialog_triggered.emit(
			"ร.ต.อ. สมชาย (ป้อมตำรวจ)",
			"ยินดีต้อนรับสู่ป้อมตำรวจชุมชนดอนโมงจ้ะเด็กๆ! ที่นี่คอยตรวจตราความปลอดภัยและรับแจ้งเหตุ 24 ชั่วโมง วันนี้มีทั้งเรื่องวินัยจราจรและคุณยายมาแจ้งแมวหายด้วยนะจ๊ะ! 👮 🚦",
			"res://assets/characters/npcs/npc_police.png"
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_police:
			_interact_police()
		elif near_board:
			_interact_board()

func _interact_police() -> void:
	if GameManager.has_item("ลูกแมวเจ้าส้ม") and not GameManager.village_cat_returned:
		GameManager.remove_item("ลูกแมวเจ้าส้ม")
		GameManager.village_cat_returned = true
		GameManager.police_safety_done = true
		GameManager.complete_good_deed("q_village_police")
		GameManager.add_star()
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("cheer")
		GameManager.dialog_triggered.emit(
			"ร.ต.อ. สมชาย (ป้อมตำรวจ)",
			"ยอดเยี่ยมมากเลยของขวัญและปีใหม่! ช่วยพา 'เจ้าส้ม' แมวของคุณยายที่หลงทางกลับมาส่งอย่างปลอดภัย คุณยายจะต้องดีใจมากแน่ๆ! ตำรวจขอมอบดาวเกียรติยศและยกย่องให้เป็นหนูน้อยพลเมืองดีตัวอย่างเลยจ้ะ! 🐱 ⭐⭐",
			"res://assets/characters/npcs/npc_police.png"
		)
	elif not GameManager.police_safety_done:
		GameManager.police_safety_done = true
		GameManager.village_police_visited = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"ร.ต.อ. สมชาย (ป้อมตำรวจ)",
			"บทเรียนวินัยจราจรจากคุณตำรวจ:\n1. ก่อนข้ามถนนให้หยุดรอบนทางเท้า มองขวา มองซ้าย แล้วมองขวาอีกครั้ง 🚦\n2. ข้ามตรงทางม้าลายหรือสะพานลอยเสมอ\n3. ถ้าเจอสัตว์เลี้ยงหลงทาง เช่น 'ลูกแมวเจ้าส้ม' แถวตลาดคลองถม ให้ช่วยอุ้มมาแจ้งที่นี่นะจ๊ะ! 👮",
			"res://assets/characters/npcs/npc_police.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ร.ต.อ. สมชาย (ป้อมตำรวจ)",
			"เดินทางไปโรงเรียนอย่างปลอดภัยนะจ๊ะเด็กๆ มีสติและข้ามถนนอย่างระมัดระวังเสมอ! หากมีเหตุด่วนเหตุร้ายโทร 191 ได้ตลอดเวลาจ้ะ! 👮 ✨",
			"res://assets/characters/npcs/npc_police.png"
		)
	_update_badges()

func _interact_board() -> void:
	if GameManager.village_cat_returned:
		GameManager.dialog_triggered.emit(
			"ป้ายประกาศชุมชนดอนโมง",
			"📋 [ประกาศด่วน]: พลเมืองดี 'พี่ของขวัญ & น้องปีใหม่' ได้ช่วยเหลือลูกแมวเจ้าส้มส่งคืนเจ้าของเรียบร้อยแล้ว! ขอขอบคุณในความมีน้ำใจ 🐱 💖",
			""
		)
	else:
		GameManager.dialog_triggered.emit(
			"ป้ายประกาศชุมชนดอนโมง",
			"📋 [ประกาศตามหาแมวหาย]: แมวพันธุ์ไทยสีส้มลายสลิด ชื่อ 'เจ้าส้ม' ปลอกคอกระดิ่งสีแดง หายไปแถวแผงผลไม้ตลาดคลองถม หากใครพบเห็นช่วยแจ้งป้อมตำรวจ 🐱 🔍",
			""
		)

func _update_badges() -> void:
	if badge_police:
		if GameManager.police_safety_done:
			badge_police.text = "✅ อบรมวินัยจราจรและแจ้งเหตุเรียบร้อย"
			badge_police.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_police.text = "💡 อบรมวินัยจราจรและแจ้งเหตุ [!]"
			badge_police.modulate = Color(1.0, 0.9, 0.3)
