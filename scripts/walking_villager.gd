extends Node2D
class_name WalkingVillager

@export var villager_name: String = "ชาวบ้าน"
@export var sprite_texture_path: String = ""
@export var patrol_distance: float = 110.0
@export var walk_speed: float = 45.0
@export var is_stationary: bool = false
@export var ambient_dialog: String = "สวัสดีตอนเช้าจ้าเด็กๆ!"
@export var has_umbrella: bool = false
@export var umbrella_texture_path: String = "res://assets/items/item_umbrella.png"
@export var umbrella_color: Color = Color.WHITE
@export var is_running_from_rain: bool = false

var origin_x: float = 0.0
var move_dir: float = 1.0
var pause_timer: float = 0.0
var walk_anim_time: float = 0.0
var player_near: bool = false
var umbrella_sprite: Sprite2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_tag: Label = $NameTag
@onready var bubble_label: Label = $BubbleLabel
@onready var trigger_area: Area2D = $TriggerArea

func _ready() -> void:
	origin_x = position.x
	move_dir = 1.0 if (int(origin_x) % 2 == 0) else -1.0
	walk_anim_time = randf() * 10.0
	pause_timer = randf_range(0.2, 1.5)

	if name_tag:
		name_tag.text = villager_name

	if sprite_texture_path != "" and ResourceLoader.exists(sprite_texture_path) and sprite:
		sprite.texture = load(sprite_texture_path)

	if has_umbrella:
		umbrella_sprite = Sprite2D.new()
		umbrella_sprite.name = "Umbrella"
		if ResourceLoader.exists(umbrella_texture_path):
			umbrella_sprite.texture = load(umbrella_texture_path)
		else:
			umbrella_sprite.texture = load("res://assets/items/item_umbrella.png")
		umbrella_sprite.scale = Vector2(0.68, 0.68)
		umbrella_sprite.modulate = umbrella_color
		umbrella_sprite.position = Vector2(8.0, -48.0)
		umbrella_sprite.z_index = 1
		add_child(umbrella_sprite)

		if name_tag:
			name_tag.offset_top = -102.0
			name_tag.offset_bottom = -82.0
		if bubble_label:
			bubble_label.offset_top = -145.0
			bubble_label.offset_bottom = -117.0

	if bubble_label:
		bubble_label.text = ambient_dialog
		bubble_label.visible = false

	if trigger_area:
		trigger_area.body_entered.connect(_on_player_entered)
		trigger_area.body_exited.connect(_on_player_exited)

func _process(delta: float) -> void:
	if not is_stationary:
		if pause_timer > 0.0:
			pause_timer -= delta
			if sprite:
				sprite.position.y = -5.0
			if umbrella_sprite:
				umbrella_sprite.position.y = -48.0
		else:
			position.x += move_dir * walk_speed * delta
			var anim_freq: float = 14.0 if is_running_from_rain else 8.5
			var bob_amt: float = 3.2 if is_running_from_rain else 2.2
			walk_anim_time += delta * anim_freq
			if sprite:
				sprite.flip_h = (move_dir < 0.0)
				sprite.position.y = -5.0 + sin(walk_anim_time) * bob_amt
			if umbrella_sprite:
				umbrella_sprite.flip_h = (move_dir < 0.0)
				umbrella_sprite.position.x = -8.0 if (move_dir < 0.0) else 8.0
				umbrella_sprite.position.y = -48.0 + (sprite.position.y + 5.0)

			# Check patrol boundaries
			if move_dir > 0.0 and position.x >= origin_x + patrol_distance:
				position.x = origin_x + patrol_distance
				move_dir = -1.0
				var pause_min = 0.6 if is_running_from_rain else 1.4
				var pause_max = 1.2 if is_running_from_rain else 2.8
				pause_timer = randf_range(pause_min, pause_max)
			elif move_dir < 0.0 and position.x <= origin_x - patrol_distance:
				position.x = origin_x - patrol_distance
				move_dir = 1.0
				var pause_min = 0.6 if is_running_from_rain else 1.4
				var pause_max = 1.2 if is_running_from_rain else 2.8
				pause_timer = randf_range(pause_min, pause_max)
	else:
		walk_anim_time += delta * 2.0
		if sprite:
			sprite.position.y = -5.0 + sin(walk_anim_time) * 1.2
		if umbrella_sprite:
			umbrella_sprite.position.y = -48.0 + sin(walk_anim_time) * 1.2

	if bubble_label and bubble_label.visible:
		var base_y: float = -145.0 if has_umbrella else -120.0
		bubble_label.position.y = base_y + sin(Time.get_ticks_msec() * 0.005) * 3.0

	if player_near and (Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")):
		interact()

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		player_near = true
		if bubble_label:
			bubble_label.visible = true
		if sprite and not is_stationary:
			sprite.flip_h = (body.global_position.x < global_position.x)
			if umbrella_sprite:
				umbrella_sprite.flip_h = sprite.flip_h
				umbrella_sprite.position.x = -8.0 if sprite.flip_h else 8.0

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		player_near = false
		if bubble_label:
			bubble_label.visible = false

func interact() -> void:
	GameManager.dialog_triggered.emit(villager_name, ambient_dialog, sprite_texture_path)
