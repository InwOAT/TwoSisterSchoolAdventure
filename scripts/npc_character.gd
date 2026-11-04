extends Area2D
class_name NPCCharacter

@export var npc_name: String = "คุณป้าร้านชำ"
@export var portrait_path: String = ""
@export var npc_sprite_path: String = ""
@export var dialog_lines: Array[String] = []
@export var courtesy_star_reward: bool = true
@export var quest_id: String = ""
@export var quest_trigger_on_talk: bool = true
@export var can_patrol: bool = false
@export var patrol_distance: float = 60.0
@export var walk_speed: float = 36.0

@onready var prompt_label: Label = $PromptLabel

var p1_near: bool = false
var p2_near: bool = false
var has_rewarded_star: bool = false
var current_line_idx: int = 0
var quest_badge: Label = null
var npc_sprite: Sprite2D = null

var origin_x: float = 0.0
var move_dir: float = 1.0
var pause_timer: float = 0.0
var walk_anim_time: float = 0.0

func _ready() -> void:
	origin_x = position.x
	# Auto-enable patrol for parents (คุณพ่อ, คุณแม่)
	if "แม่" in npc_name or "พ่อ" in npc_name:
		can_patrol = true
		if "แม่" in npc_name:
			patrol_distance = 55.0
			walk_speed = 34.0
		elif "พ่อ" in npc_name:
			patrol_distance = 50.0
			walk_speed = 35.0

	move_dir = 1.0 if (int(origin_x) % 2 == 0) else -1.0
	walk_anim_time = randf() * 10.0
	pause_timer = randf_range(0.4, 1.6)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label:
		prompt_label.visible = false
		prompt_label.text = "[E / Shift] ทักทาย " + npc_name
	
	_setup_maple_npc_visuals()
	
	if quest_id != "":
		_create_quest_badge()
		GameManager.good_deed_updated.connect(_on_quest_state_changed)
		_update_badge()

func _setup_maple_npc_visuals() -> void:
	# Hide placeholder ColorRect if present and replace with cute MapleStory Chibi NPC Sprite!
	var rect := get_node_or_null("ColorRect") as ColorRect
	var tex_path := npc_sprite_path
	var is_adult := ("แม่" in npc_name) or ("พ่อ" in npc_name)
	
	if tex_path == "":
		if "แม่" in npc_name and not "แม่ค้า" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_mom.png"
		elif "พ่อ" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_dad.png"
		elif "ตำรวจ" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_police.png"
		elif "พยาบาล" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_nurse.png"
		elif "หมอ" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_doctor.png"
		elif "รปภ" in npc_name or "ยาม" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_guard.png"
		elif "นายสถานี" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_station_master.png"
		elif "กระเป๋ารถเมล์" in npc_name or "คนขับ" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_conductor.png"
		elif "หลวงตา" in npc_name or "พระ" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_monk.png"
		elif "คุณตา" in npc_name or ("ตา" in npc_name and not "สายตา" in npc_name):
			tex_path = "res://assets/characters/npcs/npc_grandpa.png"
		elif "ครู" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_teacher.png"
		elif "ยาย" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_grandma.png"
		elif "ป้า" in npc_name and not "แม่ค้า" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_auntie.png"
		elif "อนุบาล" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_kindergarten.png"
		elif "แปลกหน้า" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_stranger.png"
		elif "แมว" in npc_name or "เจ้าส้ม" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_cat.png"
		elif "ลุง" in npc_name or "แม่ค้า" in npc_name or "ไปรษณีย์" in npc_name or "สหกรณ์" in npc_name:
			tex_path = "res://assets/characters/npcs/npc_vendor.png"
		else:
			tex_path = "res://assets/characters/npcs/npc_student.png"

	if ResourceLoader.exists(tex_path):
		if rect:
			rect.visible = false
		npc_sprite = Sprite2D.new()
		npc_sprite.texture = load(tex_path)
		# Dad and Mom characters are noticeably taller/larger adult figures
		if is_adult:
			npc_sprite.scale = Vector2(1.05, 1.05)
			npc_sprite.position = Vector2(0, -35)
		else:
			npc_sprite.scale = Vector2(0.62, 0.62)
			npc_sprite.position = Vector2(0, -5)
		add_child(npc_sprite)
		move_child(npc_sprite, 0)

	# Style NPC Name Label ABOVE HEAD (Create automatically if missing!)
	var lbl := get_node_or_null("Label") as Label
	if not lbl:
		lbl = Label.new()
		lbl.name = "Label"
		lbl.text = npc_name
		add_child(lbl)
	
	if lbl:
		lbl.text = npc_name
		lbl.offset_left = -65.0
		lbl.offset_right = 65.0
		lbl.offset_top = -145.0 if is_adult else -88.0
		lbl.offset_bottom = -120.0 if is_adult else -66.0
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.06, 0.1, 0.18, 0.88)
		sb.border_color = Color(0.4, 0.75, 1, 0.85)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		lbl.add_theme_stylebox_override("normal", sb)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1, 1))
		lbl.add_theme_font_size_override("font_size", 11)

	# Position prompt label above the nametag
	if prompt_label:
		prompt_label.offset_left = -105.0
		prompt_label.offset_right = 105.0
		prompt_label.offset_top = -208.0 if is_adult else -152.0
		prompt_label.offset_bottom = -178.0 if is_adult else -122.0
		prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		GameManager.style_prompt_label(prompt_label)

func _create_quest_badge() -> void:
	var is_adult := ("แม่" in npc_name) or ("พ่อ" in npc_name)
	quest_badge = Label.new()
	quest_badge.custom_minimum_size = Vector2(130, 22)
	quest_badge.position = Vector2(-65, -175 if is_adult else -118)
	quest_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_badge.add_theme_font_size_override("font_size", 11)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.1, 0.04, 0.85)
	sb.border_color = Color(1.0, 0.85, 0.2, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	quest_badge.add_theme_stylebox_override("normal", sb)
	add_child(quest_badge)

func _update_badge() -> void:
	if not quest_badge or quest_id == "" or not GameManager.good_deeds.has(quest_id):
		return
	
	var q: Dictionary = GameManager.good_deeds[quest_id]
	var status: String = str(q.get("status", ""))
	if status == "completed":
		quest_badge.text = "✅ สำเร็จแล้ว!"
		quest_badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	elif status == "in_progress":
		quest_badge.text = "⏳ กำลังทำเควส [?]"
		quest_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		quest_badge.text = "💡 เควสความดี [!]"
		quest_badge.add_theme_color_override("font_color", Color(1.0, 0.92, 0.3))

func _on_quest_state_changed(q_id: String, pts: int, _total: int, _title: String) -> void:
	if q_id == quest_id:
		_update_badge()
		if pts > 0:
			_play_happy_hop()
			GameManager.spawn_star_burst(global_position, Color(1.0, 0.72, 0.88))

func _play_happy_hop() -> void:
	if not npc_sprite or not is_inside_tree():
		return
	var is_adult := ("แม่" in npc_name) or ("พ่อ" in npc_name)
	var base_scale := Vector2(1.05, 1.05) if is_adult else Vector2(0.62, 0.62)
	npc_sprite.scale = Vector2(base_scale.x * 0.9, base_scale.y * 1.15)
	var tw := create_tween()
	tw.tween_property(npc_sprite, "scale", base_scale, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.004
	var is_adult := ("แม่" in npc_name) or ("พ่อ" in npc_name)
	var base_sprite_y: float = -35.0 if is_adult else -5.0
	var base_badge_y: float = -175.0 if is_adult else -118.0

	if can_patrol:
		if p1_near or p2_near:
			# Player nearby: Stop and turn towards nearest player
			var target_player: Node2D = null
			var players: Array[Node] = get_tree().get_nodes_in_group("players")
			if not players.is_empty():
				var closest_dist: float = 99999.0
				for p in players:
					if p is Node2D:
						var d: float = absf(p.global_position.x - global_position.x)
						if d < closest_dist:
							closest_dist = d
							target_player = p
			if target_player and npc_sprite:
				npc_sprite.flip_h = (target_player.global_position.x < global_position.x)
				npc_sprite.position.y = base_sprite_y + sin(t) * 1.8
			if quest_badge:
				quest_badge.position.y = base_badge_y + sin(t * 1.5) * 4.0
			pause_timer = 1.2
		else:
			# Ambient patrol walking
			if pause_timer > 0.0:
				pause_timer -= delta
				if npc_sprite:
					npc_sprite.position.y = base_sprite_y + sin(t) * 1.5
				if quest_badge:
					quest_badge.position.y = base_badge_y + sin(t * 1.5) * 3.0
			else:
				position.x += move_dir * walk_speed * delta
				walk_anim_time += delta * 7.5
				if npc_sprite:
					npc_sprite.flip_h = (move_dir < 0.0)
					npc_sprite.position.y = base_sprite_y + sin(walk_anim_time) * 2.8
				if quest_badge:
					quest_badge.position.y = base_badge_y + sin(walk_anim_time) * 2.8

				# Check patrol boundaries
				if move_dir > 0.0 and position.x >= origin_x + patrol_distance:
					position.x = origin_x + patrol_distance
					move_dir = -1.0
					pause_timer = randf_range(1.5, 3.2)
				elif move_dir < 0.0 and position.x <= origin_x - patrol_distance:
					position.x = origin_x - patrol_distance
					move_dir = 1.0
					pause_timer = randf_range(1.5, 3.2)
	else:
		if npc_sprite:
			npc_sprite.position.y = base_sprite_y + sin(t) * 2.0
		if quest_badge:
			quest_badge.position.y = base_badge_y + sin(t * 1.5) * 4.0

	var p1_pressed := p1_near and Input.is_action_just_pressed("p1_interact")
	var p2_pressed := p2_near and Input.is_action_just_pressed("p2_interact")

	if p1_pressed or p2_pressed:
		_interact()

func _interact() -> void:
	if dialog_lines.is_empty():
		return
	
	_play_happy_hop()
	var line := dialog_lines[current_line_idx % dialog_lines.size()]
	if courtesy_star_reward and not has_rewarded_star:
		has_rewarded_star = true
		GameManager.add_star()
		line += "\n\n(🌟 เด็กดีมีมารยาท ยกมือไหว้ผู้ใหญ่ น่ารักมากจ้า! +1 ดาวมารยาทดี)"

	GameManager.dialog_triggered.emit(npc_name, line, portrait_path)
	current_line_idx += 1

	if quest_id != "" and quest_trigger_on_talk:
		if GameManager.good_deeds.has(quest_id):
			if GameManager.good_deeds[quest_id]["status"] == "not_started":
				GameManager.good_deeds[quest_id]["status"] = "in_progress"
				var q: Dictionary = GameManager.good_deeds[quest_id]
				GameManager.good_deed_updated.emit(quest_id, 0, GameManager.good_deed_points, q["title"])
				_update_badge()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		p1_near = true
	elif body.is_in_group("player2"):
		p2_near = true
	
	if p1_near or p2_near:
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		p1_near = false
	elif body.is_in_group("player2"):
		p2_near = false
	
	if not p1_near and not p2_near:
		if prompt_label:
			prompt_label.visible = false
