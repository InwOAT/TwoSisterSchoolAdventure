extends Area2D
class_name MapleLadder

@export var ladder_height: float = 160.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_near_ladder"):
		body.set_near_ladder(true, global_position.x)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_near_ladder"):
		body.set_near_ladder(false, global_position.x)
