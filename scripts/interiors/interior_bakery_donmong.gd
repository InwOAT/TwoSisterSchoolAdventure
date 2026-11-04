extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var baker_area: Area2D = $BakerArea
@onready var prompt_baker: Label = $BakerArea/PromptLabel
@onready var oven_area: Area2D = $OvenArea
@onready var prompt_oven: Label = $OvenArea/PromptLabel

var near_baker: bool = false
var near_oven: bool = false
var bread_sampled: bool = false

func _ready() -> void:
	level_number = 209
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_2.tscn"
		exit_portal.target_spawn_x = 2320.0
		exit_portal.target_level = 2
		exit_portal.portal_name = "ออกไปซอยหมู่บ้านดอนโมง"
		exit_portal.is_locked = false

	if baker_area:
		baker_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_baker = true
				if prompt_baker: prompt_baker.visible = true
		)
		baker_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_baker = false
				if prompt_baker: prompt_baker.visible = false
		)

	if oven_area:
		oven_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_oven = true
				if prompt_oven: prompt_oven.visible = true
		)
		oven_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_oven = false
				if prompt_oven: prompt_oven.visible = false
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_baker:
			_interact_baker()
		elif near_oven:
			_interact_oven()

func _interact_baker() -> void:
	if not bread_sampled:
		bread_sampled = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
		GameManager.dialog_triggered.emit(
			"เชฟขนมปังลุงนพ",
			"กลิ่นขนมปังอบใหม่หอมกรุ่นเลยใช่ไหมจ๊ะเด็กๆ! 🥐 ลุงอบ 'ครัวซองต์เนยสดโฮลวีต' ร้อนๆ ให้ชิมฟรีคนละชิ้นนะลูก ขนมปังโฮลวีตมีกากใยสูง ให้พลังงานยาวนานเหมาะกับวัยกำลังโต! +1 ดาวสุขภาพดี! ⭐",
			"res://assets/characters/npcs/npc_vendor.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"เชฟขนมปังลุงนพ",
			"ขนมปังและพายสับปะรดของฝากดอนโมง อบสดใหม่จากเตาทุกเช้าเลยจ้า! 🍞 🥐",
			"res://assets/characters/npcs/npc_vendor.png"
		)

func _interact_oven() -> void:
	GameManager.dialog_triggered.emit(
		"เตาอบขนมปังหอมกรุ่น",
		"🔥 เตาอบขนมปังอุณหภูมิกำลังพอเหมาะ ส่องดูด้านในเห็นขนมปังขึ้นฟูสีเหลืองทองน่ารับประทานมาก!",
		""
	)
