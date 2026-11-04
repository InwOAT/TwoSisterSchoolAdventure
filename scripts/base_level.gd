extends Node2D
class_name BaseLevel

@export var level_number: int = 1
@export var add_maple_platforms: bool = false

@onready var p1: PlayerKhongkwan = $Players/PlayerKhongkwan
@onready var p2: PlayerPeemai = $Players/PlayerPeemai
@onready var camera: Camera2D = $Camera2D

var max_level_width: float = 1280.0

func _ready() -> void:
	GameManager.current_level = level_number
	var hud := get_node_or_null("HUD") as GameHUD
	if hud:
		hud._update_level_title()
	max_level_width = _get_level_width()
	_setup_camera()
	
	# Spawn players at designated x
	if p1:
		p1.global_position.x = GameManager.spawn_x
		p1.target_to_follow = p2
	if p2:
		p2.global_position.x = GameManager.spawn_x - 40.0
		p2.target_to_follow = p1

	_upgrade_level_to_maple_side_view()
	_style_all_prompt_labels(self)
	GameManager.play_scene_entry_fade(self)
	_trigger_entry_sister_banter()

	if AudioManager:
		AudioManager.play_level_bgm(level_number)

func _trigger_entry_sister_banter() -> void:
	if not p1 or not p2:
		return
	var banter := {
		1: ["เช้าแล้ว! ช่วยคุณแม่เก็บโต๊ะก่อนไปเรียนกันนะ ☀️", "รับทราบค่ะพี่ของขวัญ! 🍽️"],
		2: ["ซอยหมู่บ้านคึกคักจัง อย่าลืมแวะช่วยคุณป้าสมศรีนะ!", "ไปกันเลยค่ะ! 🥚"],
		25: ["ถึงศาลารอรถเมล์แล้ว ดูตารางรถสาย 514 กัน!", "คุณตานั่งรอรถอยู่ตรงนั้นด้วยค่ะ 🥤"],
		3: ["ขึ้นรถเมล์แล้ว เตรียมจ่ายค่าโดยสารและจับราวดีๆ นะ", "ค่ะพี่ของขวัญ! 🚌"],
		4: ["สถานีรถสองแถว! ต้องดูป้ายสีรถให้ดีก่อนขึ้นนะ", "คันสีฟ้าไปโรงเรียนใช่ไหมคะ? 🚐"],
		5: ["ถึงหน้าโรงเรียนแล้ว! สวัสดีคุณครูเวรกันก่อนนะ 🙏", "สวัสดีค่ะคุณครู! 🌸"],
		6: ["ตั้งใจเรียนและตอบคำถามคุณครูกันนะปีใหม่!", "สู้ๆ ค่ะพี่ของขวัญ! 📝"],
		7: ["พักเที่ยงแล้ว! หอมกลิ่นกับข้าวโรงอาหารจังเลย~ 🍱", "เลือกอาหารให้ครบ 5 หมู่กันนะคะ! 😋"],
		8: ["ไปช่วยกันดูแลแปลงดอกไม้ให้บานสะพรั่งกันเถอะ!", "เย้! ดอกไม้ต้องสวยมากแน่ๆ ค่ะ 🌸"],
		9: ["ได้เวลากลับบ้านแล้ว เอ๊ะ เหรียญกลิ้งไปไหนนะ?", "เดี๋ยวปีใหม่ช่วยมุดหาให้นะคะ! 🪙"],
		95: ["ถึงท่ารถต่อรถเมล์ขากลับแล้ว เตรียมตัวขึ้นรถกัน!", "ใกล้ถึงบ้านเราแล้ว~ 🚏"],
		10: ["ขากลับต้องระวังคนแปลกหน้า และดูแลของมีค่าด้วยนะ", "เข้าใจแล้วค่ะพี่ของขวัญ! 🛡️"],
		11: ["ฝนตกแล้ว! รีบกางร่มแบ่งเพื่อนกลับบ้านด้วยกันเร็ว ☔", "มาอยู่ในร่มด้วยกันนะคะ! ☂️"],
		12: ["กลับมาถึงบ้านแสนสุขแล้ว ช่วยงานบ้านคุณพ่อคุณแม่กัน!", "หนูจะช่วยนวดไหล่ให้คุณพ่อเองค่ะ! 💖"]
	}
	if banter.has(level_number):
		var pair: Array = banter[level_number]
		p1.show_emote(pair[0], 3.5)
		p2.show_emote(pair[1], 3.8)

func _get_level_width() -> float:
	match level_number:
		1, 3, 6, 9, 10, 12:
			return 1280.0
		25, 95:
			return 2560.0
		2:
			return 4200.0
		4, 5, 7, 11:
			return 1800.0
		8:
			return 2220.0
		_:
			var wr := get_node_or_null("WallRight") as Node2D
			if wr:
				return wr.position.x + 20.0
			return 1280.0

func _setup_camera() -> void:
	if not camera:
		return
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = 720
	camera.limit_right = int(max_level_width)
	if max_level_width <= 1280.0:
		camera.global_position = Vector2(640, 360)
	else:
		var initial_x := clampf(GameManager.spawn_x, 640.0, max_level_width - 640.0)
		camera.global_position = Vector2(initial_x, 360)

func _upgrade_level_to_maple_side_view() -> void:
	# 1. Replace any placeholder ColorRect buildings/NPCs inside Zones with MapleStory 2D Side-View Sprites!
	var zones := get_node_or_null("Zones")
	if zones:
		for area in zones.get_children():
			_style_zone_node(area)

	# 2. Add MapleStory M multi-tiered One-Way Platforms & Ladders!
	if not add_maple_platforms:
		return

	var plat_tex_path := "res://assets/environment/maple_platform_grass.png"
	if level_number in [1, 6, 7, 12]:
		plat_tex_path = "res://assets/environment/maple_platform_wood.png"
	var plat_tex: Texture2D = load(plat_tex_path) if ResourceLoader.exists(plat_tex_path) else null
	var ladder_tex: Texture2D = load("res://assets/environment/maple_ladder.png") if ResourceLoader.exists("res://assets/environment/maple_ladder.png") else null

	var layout: Array = _get_maple_platform_layout()
	var plat_root := Node2D.new()
	plat_root.name = "MaplePlatforms"
	add_child(plat_root)
	# Keep behind Players so characters walk in front of ladders and platforms
	if has_node("Players"):
		move_child(plat_root, get_node("Players").get_index())

	for item in layout:
		var px: float = item.get("x", 600.0)
		var py: float = item.get("y", 470.0)
		var pw: float = item.get("w", 256.0)
		var has_ladder: bool = item.get("ladder", false)
		var ladder_offset_x: float = item.get("ladder_dx", 0.0)

		# Create One-Way StaticBody2D Platform
		var sb := StaticBody2D.new()
		sb.position = Vector2(px, py)
		sb.collision_layer = 1
		sb.collision_mask = 6

		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(pw, 22.0)
		col.shape = rect
		col.one_way_collision = true
		col.one_way_collision_margin = 8.0
		sb.add_child(col)

		if plat_tex:
			var sp := Sprite2D.new()
			sp.texture = plat_tex
			sp.scale = Vector2(pw / 256.0, 0.85)
			sp.position = Vector2(0, 6)
			sb.add_child(sp)

		plat_root.add_child(sb)

		# Optional Climbable MapleStory Ladder from lower floor/platform up to this platform!
		if has_ladder and ladder_tex:
			var l_height: float = item.get("ladder_h", 170.0)
			var ladder_area := MapleLadder.new()
			ladder_area.position = Vector2(px + ladder_offset_x, py + l_height * 0.5)
			ladder_area.ladder_height = l_height

			var l_col := CollisionShape2D.new()
			var l_rect := RectangleShape2D.new()
			l_rect.size = Vector2(38.0, l_height)
			l_col.shape = l_rect
			ladder_area.add_child(l_col)

			var l_sp := Sprite2D.new()
			l_sp.texture = ladder_tex
			l_sp.scale = Vector2(0.75, l_height / 220.0)
			ladder_area.add_child(l_sp)

			plat_root.add_child(ladder_area)

func _get_maple_platform_layout() -> Array:
	# ทุกฉากในเกมเดินบนพื้นราบเรียบสไตล์ Storybook Side-Scrolling ไม่ต้องมีพื้นที่ลอยหรือบันไดบังทัศนียภาพ
	return []

func _style_zone_node(node: Node) -> void:
	var n_name := node.name
	var bldg_rect := node.get_node_or_null("Building") as ColorRect
	if not bldg_rect:
		bldg_rect = node.get_node_or_null("ColorRect") as ColorRect
	if not bldg_rect:
		bldg_rect = node.get_node_or_null("CatRect") as ColorRect

	var bldg_tex_path := ""
	var npc_tex_path := ""
	var is_cat := false

	if "Police" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_police.png"
		npc_tex_path = "res://assets/characters/npcs/npc_police.png"
	elif "Market" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_market.png"
		npc_tex_path = "res://assets/characters/npcs/npc_vendor.png"
	elif "UncleSit" in n_name or "Coop" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_lotus.png"
		npc_tex_path = "res://assets/characters/npcs/npc_vendor.png"
	elif "Auntie" in n_name:
		npc_tex_path = "res://assets/characters/npcs/npc_auntie.png"
	elif "Infirmary" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_clinic.png"
		npc_tex_path = "res://assets/characters/npcs/npc_nurse.png"
	elif "Doctor" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_clinic.png"
		npc_tex_path = "res://assets/characters/npcs/npc_doctor.png"
	elif "Temple" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_temple.png"
		npc_tex_path = "res://assets/characters/npcs/npc_monk.png"
	elif "Shrine" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_temple.png"
	elif "Post" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_post.png"
		npc_tex_path = "res://assets/characters/npcs/npc_vendor.png"
	elif "Library" in n_name:
		bldg_tex_path = "res://assets/environment/bldg_police.png"
		npc_tex_path = "res://assets/characters/npcs/npc_teacher.png"
	elif "Playground" in n_name:
		npc_tex_path = "res://assets/characters/npcs/npc_kindergarten.png"
	elif "LostCat" in n_name:
		npc_tex_path = "res://assets/characters/npcs/npc_cat.png"
		is_cat = true

	if bldg_rect and (bldg_tex_path != "" or npc_tex_path != ""):
		bldg_rect.visible = false

	if bldg_tex_path != "" and ResourceLoader.exists(bldg_tex_path):
		var b_sp := Sprite2D.new()
		b_sp.texture = load(bldg_tex_path)
		b_sp.scale = Vector2(0.95, 0.95)
		b_sp.position = Vector2(0, -32)
		node.add_child(b_sp)
		node.move_child(b_sp, 0)

	if npc_tex_path != "" and ResourceLoader.exists(npc_tex_path):
		var n_sp := Sprite2D.new()
		n_sp.texture = load(npc_tex_path)
		if is_cat:
			n_sp.scale = Vector2(0.55, 0.55)
			n_sp.position = Vector2(0, -4)
		else:
			n_sp.scale = Vector2(0.60, 0.60)
			n_sp.position = Vector2(52 if bldg_tex_path != "" else 0, 8)
		node.add_child(n_sp)

	# Style Zone Label in MapleStory M banner style!
	var lbl := node.get_node_or_null("Label") as Label
	if lbl:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.06, 0.09, 0.16, 0.84)
		sb.border_color = Color(1.0, 0.85, 0.35, 0.85)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		lbl.add_theme_stylebox_override("normal", sb)
		lbl.offset_top = -138.0 if bldg_tex_path != "" else -82.0
		lbl.offset_bottom = lbl.offset_top + 22.0

func _style_all_prompt_labels(node: Node) -> void:
	if node is Label:
		var n_low := node.name.to_lower()
		if "prompt" in n_low:
			GameManager.style_prompt_label(node)
	for child in node.get_children():
		_style_all_prompt_labels(child)

func _process(_delta: float) -> void:
	# Camera smoothly centers between both players within level boundaries
	if camera and p1 and p2:
		if max_level_width <= 1280.0:
			camera.global_position = Vector2(640, 360)
		else:
			var mid_x := (p1.global_position.x + p2.global_position.x) * 0.5
			var target_x := clampf(mid_x, 640.0, max_level_width - 640.0)
			camera.global_position = Vector2(target_x, 360)
