extends CharacterBody2D
class_name PushableObject

@export var object_name: String = "เก้าอี้ไม้"
@export var min_x: float = 480.0
@export var max_x: float = 785.0
var gravity: float = 980.0
var push_speed: float = 0.0
var sfx_push_timer: float = 0.0

func _ready() -> void:
	add_to_group("pushable")
	collision_mask = 1 # Collide ONLY with Floor/Walls (Layer 1), never trap Players!
	var col := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col:
		col.one_way_collision = true
		col.one_way_collision_margin = 12.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Detect if any player is walking into the side of this chair to push it smoothly
	var players := get_tree().get_nodes_in_group("players")
	for p in players:
		if p is CharacterBody2D:
			var dy: float = abs(p.global_position.y - (global_position.y + 32.0))
			var dx: float = global_position.x - p.global_position.x
			# Player is on the ground next to the chair and moving toward it
			if dy < 35.0 and abs(dx) > 12.0 and abs(dx) < 58.0:
				if (dx > 0.0 and p.velocity.x > 20.0) or (dx < 0.0 and p.velocity.x < -20.0):
					push_speed = sign(dx) * 145.0

	velocity.x = move_toward(velocity.x, push_speed, 450.0 * delta)
	push_speed = move_toward(push_speed, 0, 350.0 * delta)

	if abs(velocity.x) > 25.0:
		sfx_push_timer -= delta
		if sfx_push_timer <= 0.0:
			sfx_push_timer = 0.28
			if AudioManager:
				AudioManager.play_sfx("push", randf_range(0.9, 1.1), -4.0)

	move_and_slide()

	# Keep within safe room bounds so it never blocks walls or doors
	global_position.x = clampf(global_position.x, min_x, max_x)

func apply_push(force: Vector2) -> void:
	push_speed = force.x
