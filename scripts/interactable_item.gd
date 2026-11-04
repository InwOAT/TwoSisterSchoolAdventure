extends Area2D
class_name InteractableItem

@export var item_name: String = "กุญแจบ้าน"
@export var pickup_message: String = "เก็บไอเทมสำเร็จ!"
@export var required_height_character: String = "" # e.g. "player1" (Khongkwan) or "player2" (Peemai)
@export var requires_crawling: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var sprite: Sprite2D = $Sprite2D

var p1_near: bool = false
var p2_near: bool = false
var peemai_ref: PlayerPeemai = null
var _collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label:
		prompt_label.visible = false
		prompt_label.text = "[E / Shift] เก็บ " + item_name
	
	# If already in inventory, remove from scene
	if GameManager.has_item(item_name):
		queue_free()

func _process(_delta: float) -> void:
	if _collected:
		return
	# Subtle floating animation
	if sprite:
		sprite.position.y = sin(Time.get_ticks_msec() * 0.006) * 4.0

	var p1_pressed := p1_near and Input.is_action_just_pressed("p1_interact")
	var p2_pressed := p2_near and Input.is_action_just_pressed("p2_interact")

	if p1_pressed or p2_pressed:
		_attempt_pickup()

func _attempt_pickup() -> void:
	if _collected:
		return
	if requires_crawling:
		if p2_near and peemai_ref != null and peemai_ref.is_crawling:
			_collect()
		else:
			GameManager.dialog_triggered.emit("ระบบ", "ช่องนี้แคบมาก! น้องปีใหม่ต้องกด [↓] ก้มตัวมุดเข้าไปเก็บนะจ๊ะ!", "")
		return

	if required_height_character == "player1" and not p1_near:
		GameManager.dialog_triggered.emit("ระบบ", "ไอเทมนี้อยู่สูงเกินไป! ต้องให้พี่ของขวัญที่ตัวสูงกว่าเป็นคนเอื้อมหยิบ!", "")
		return

	_collect()

func _collect() -> void:
	if _collected:
		return
	_collected = true
	if prompt_label:
		prompt_label.visible = false
	if AudioManager:
		AudioManager.play_sfx("pickup")
	GameManager.spawn_star_burst(global_position, Color(1.0, 0.92, 0.35))
	GameManager.add_item(item_name)
	if item_name == "กุญแจบ้าน":
		GameManager.house_unlocked = true
	GameManager.dialog_triggered.emit("ระบบ", pickup_message, "")
	if sprite and is_inside_tree():
		var tw := create_tween().set_parallel(true)
		tw.tween_property(sprite, "position:y", sprite.position.y - 48.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(sprite, "scale", sprite.scale * 1.35, 0.16)
		tw.tween_property(sprite, "modulate:a", 0.0, 0.32)
		tw.chain().tween_callback(queue_free)
	else:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		p1_near = true
	elif body.is_in_group("player2"):
		p2_near = true
		if body is PlayerPeemai:
			peemai_ref = body as PlayerPeemai
	
	if p1_near or p2_near:
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		p1_near = false
	elif body.is_in_group("player2"):
		p2_near = false
		if body is PlayerPeemai:
			peemai_ref = null
	
	if not p1_near and not p2_near:
		if prompt_label:
			prompt_label.visible = false
