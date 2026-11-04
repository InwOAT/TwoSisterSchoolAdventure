extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var altar_area: Area2D = $AltarArea
@onready var prompt_altar: Label = $AltarArea/PromptLabel
@onready var badge_altar: Label = $AltarArea/QuestBadge
@onready var altar_prop: Sprite2D = $AltarProp

var near_altar: bool = false

func _ready() -> void:
	level_number = 804
	super._ready()

	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_8.tscn"
		exit_portal.target_spawn_x = 320.0
		exit_portal.target_level = 8
		exit_portal.portal_name = "ออกไปลานโรงเรียน (ศาลปู่-ย่า)"
		exit_portal.is_locked = false
		exit_portal.is_building_door = true

	if altar_area:
		altar_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_altar = true
				if prompt_altar: prompt_altar.visible = true
		)
		altar_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_altar = false
				if prompt_altar: prompt_altar.visible = false
		)

	_update_badges()

	await get_tree().create_timer(0.4).timeout
	if not GameManager.grandpa_shrine_paid:
		GameManager.dialog_triggered.emit(
			"ศาลปู่-ย่า ประจำโรงเรียนชุมชนหนองเรือ",
			"🙏 ยินดีต้อนรับสู่ศาลปู่-ย่า สิ่งศักดิ์สิทธิ์ประจำโรงเรียนชุมชนหนองเรือ สองพี่น้องสามารถเดินเข้าไปที่โต๊ะหมู่บูชาเพื่อยกมือไหว้ขอพรได้เลยจ้ะ! ✨",
			""
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed and near_altar:
		_interact_altar()

func _interact_altar() -> void:
	if not GameManager.grandpa_shrine_paid:
		GameManager.grandpa_shrine_paid = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"ศาลปู่-ย่า ประจำโรงเรียนชุมชนหนองเรือ [จุด 22]",
			"🙏 สองพี่น้องยกมือไหว้สิ่งศักดิ์สิทธิ์ประจำโรงเรียนชุมชนหนองเรือ ขอพรให้มีสติปัญญาและเรียนหนังสืออย่างมีความสุข! ⭐ ได้รับดาวมารยาท + 10 แต้มความดี!",
			""
		)
	else:
		GameManager.dialog_triggered.emit(
			"ศาลปู่-ย่า ประจำโรงเรียนชุมชนหนองเรือ",
			"✨ ปู่-ย่าให้พร: 'ขอให้หลานๆ ทั้งสองตั้งใจศึกษาหาความรู้ เป็นเด็กดี มีน้ำใจช่วยเหลือเพื่อนๆ และชุมชนนะหลานเอ๊ย' 🌸",
			""
		)
	_update_badges()

func _update_badges() -> void:
	if badge_altar:
		if GameManager.grandpa_shrine_paid:
			badge_altar.text = "✅ ไหว้ขอพรศาลปู่-ย่าเรียบร้อยแล้ว"
			badge_altar.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_altar.text = "💡 ไหว้ขอพรสิ่งศักดิ์สิทธิ์ประจำโรงเรียน [!]"
			badge_altar.modulate = Color(1.0, 0.9, 0.3)
