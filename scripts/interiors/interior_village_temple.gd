extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var monk_area: Area2D = $MonkArea
@onready var prompt_monk: Label = $MonkArea/PromptLabel
@onready var badge_monk: Label = $MonkArea/QuestBadge
@onready var broom_area: Area2D = $BroomArea
@onready var prompt_broom: Label = $BroomArea/PromptLabel
@onready var altar_prop: Sprite2D = $AltarProp

var near_monk: bool = false
var near_broom: bool = false

func _ready() -> void:
	level_number = 204
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 3350.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false
	
	if monk_area:
		monk_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_monk = true
				if prompt_monk: prompt_monk.visible = true
		)
		monk_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_monk = false
				if prompt_monk: prompt_monk.visible = false
		)
	
	if broom_area:
		broom_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_broom = true
				if prompt_broom: prompt_broom.visible = true
		)
		broom_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_broom = false
				if prompt_broom: prompt_broom.visible = false
		)
	
	_update_badges()
	
	await get_tree().create_timer(0.4).timeout
	if not GameManager.temple_hall_swept:
		GameManager.dialog_triggered.emit(
			"หลวงตาบุญชื่น (วัดมงคลนิมิต)",
			"เจริญพรโยมหนูของขวัญและโยมหนูปีใหม่! ก้าวเข้ามาในศาลาการเปรียญวัดมงคลนิมิตแล้ว จิตใจสงบเย็นร่มรื่น เข้ามากราบพระประธานและช่วยกันดูแลวัดวาอารามนะจ๊ะ 🙏 ✨",
			"res://assets/characters/npcs/npc_grandpa.png"
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_monk:
			_interact_monk()
		elif near_broom:
			_interact_broom()

func _interact_monk() -> void:
	if not GameManager.temple_hall_swept:
		GameManager.temple_hall_swept = true
		GameManager.village_temple_cleaned = true
		GameManager.complete_good_deed("q_village_temple")
		GameManager.add_star()
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("cheer")
		GameManager.dialog_triggered.emit(
			"หลวงตาบุญชื่น (วัดมงคลนิมิต)",
			"สาธุ... โยมหนูทั้งสองกราบพระเบญจางคประดิษฐ์ได้อย่างงดงาม มีสัมมาคารวะและกตัญญูรู้คุณ ขออาราธนาคุณพระศรีรัตนตรัยคุ้มครองให้เรียนเก่ง เป็นเด็กดี และแคล้วคลาดปลอดภัยในทุกการเดินทางนะจ๊ะ! 🙏 ⭐⭐",
			"res://assets/characters/npcs/npc_grandpa.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"หลวงตาบุญชื่น (วัดมงคลนิมิต)",
			"ศาลาวัดสะอาดสว่างไสว จิตใจผ่องใสบริสุทธิ์ ขอให้เจริญด้วยอายุ วรรณะ สุขะ พละ นะโยมหนู 🙏 ✨",
			"res://assets/characters/npcs/npc_grandpa.png"
		)
	_update_badges()

func _interact_broom() -> void:
	GameManager.add_star()
	if AudioManager:
		AudioManager.play_sfx("correct")
	GameManager.dialog_triggered.emit(
		"ลานศาลาวัดมงคลนิมิต",
		"🧹 พี่ของขวัญและน้องปีใหม่ช่วยกันจับไม้กวาดทางมะพร้าว กวาดใบไม้และฝุ่นผงบนลานไม้สักทองจนสะอาดเอี่ยมอ่อง! พระและญาติโยมที่มาทำบุญต่างชื่นชมในจิตอาสา! ⭐ 💖",
		""
	)
	if not GameManager.temple_hall_swept:
		GameManager.temple_hall_swept = true
		GameManager.village_temple_cleaned = true
		GameManager.complete_good_deed("q_village_temple")
		_update_badges()

func _update_badges() -> void:
	if badge_monk:
		if GameManager.temple_hall_swept:
			badge_monk.text = "✅ กราบพระและกวาดศาลาเรียบร้อย"
			badge_monk.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_monk.text = "💡 กราบพระประธานและกวาดศาลา [!]"
			badge_monk.modulate = Color(1.0, 0.9, 0.3)
