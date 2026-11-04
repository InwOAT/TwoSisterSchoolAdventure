extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var leader_area: Area2D = $LeaderArea
@onready var prompt_leader: Label = $LeaderArea/PromptLabel
@onready var poster_area: Area2D = $PosterArea
@onready var prompt_poster: Label = $PosterArea/PromptLabel

var near_leader: bool = false
var near_poster: bool = false
var reward_given: bool = false

func _ready() -> void:
	level_number = 208
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 1560.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false

	if leader_area:
		leader_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_leader = true
				if prompt_leader: prompt_leader.visible = true
		)
		leader_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_leader = false
				if prompt_leader: prompt_leader.visible = false
		)

	if poster_area:
		poster_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_poster = true
				if prompt_poster: prompt_poster.visible = true
		)
		poster_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_poster = false
				if prompt_poster: prompt_poster.visible = false
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_leader:
			_interact_leader()
		elif near_poster:
			_interact_poster()

func _interact_leader() -> void:
	if not reward_given:
		reward_given = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"ผู้ใหญ่บ้านดอนโมง",
			"สวัสดีหลานๆ ทั้งสอง! 🏡 ที่นี่คือที่ทำการบ้านพักชุมชนดอนโมง ศูนย์รวมความร่วมมือและช่วยเหลือลูกบ้าน ขอบใจที่หนูๆ เป็นเด็กดีช่วยทำความสะอาดบ้านและมีน้ำใจต่อส่วนรวมนะลูก! +1 ดาวจิตอาสา! ⭐",
			"res://assets/characters/npcs/npc_guard.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ผู้ใหญ่บ้านดอนโมง",
			"ความสามัคคีและน้ำใจคือหัวใจของชุมชนเรา มีปัญหาอะไรแวะมาปรึกษาผู้ใหญ่ได้เสมอนะจ๊ะ! 🏡 ✨",
			"res://assets/characters/npcs/npc_guard.png"
		)

func _interact_poster() -> void:
	GameManager.dialog_triggered.emit(
		"ป้ายความรู้สุขอนามัยชุมชน",
		"📋 บอร์ดให้ความรู้: 1. ล้างมือบ่อยๆ ด้วยสบู่ 2. แยกขยะก่อนทิ้ง 3. ช่วยกันดูแลแม่น้ำลำคลองให้สะอาดใส 💧 🌿",
		""
	)
