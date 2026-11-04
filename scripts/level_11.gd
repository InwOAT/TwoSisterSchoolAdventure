extends BaseLevel

@onready var portal_home: MaplePortal = $PortalSweetHome
@onready var umbrella_visual: Sprite2D = $UmbrellaVisual
@onready var friend_area: Area2D = $FriendUnderAwning
@onready var friend_sprite: Sprite2D = get_node_or_null("FriendUnderAwning/Sprite2D")
@onready var friend_label: Label = get_node_or_null("FriendUnderAwning/Label")
@onready var friend_prompt: Label = get_node_or_null("FriendUnderAwning/PromptLabel")

var friend_helped: bool = false
var near_friend: bool = false
var friend_anim_t: float = 0.0

func _ready() -> void:
	level_number = 11
	super._ready()

	GameManager.start_good_deed("q_share_umbrella")
	friend_helped = (GameManager.good_deeds.get("q_share_umbrella", {}).get("status", "") == "completed")

	if portal_home:
		portal_home.target_level = 12
		portal_home.target_spawn_x = 100.0
		_update_portal()

	if umbrella_visual:
		umbrella_visual.visible = GameManager.umbrella_active

	if friend_area:
		if friend_helped:
			if friend_label:
				friend_label.text = "เพื่อนนักเรียน (เดินใต้ร่ม ☔)"
				friend_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.65))
		friend_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_friend = true
				if friend_prompt:
					friend_prompt.visible = not friend_helped
		)
		friend_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_friend = false
				if friend_prompt:
					friend_prompt.visible = false
		)

func _get_level_width() -> float:
	return 4440.0

func _process(delta: float) -> void:
	super._process(delta)

	var use_umbrella_pressed := Input.is_action_just_pressed("p1_item") or Input.is_action_just_pressed("p2_item") or Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	# Activate umbrella
	if use_umbrella_pressed and GameManager.has_item("ร่ม") and not GameManager.umbrella_active:
		GameManager.umbrella_active = true
		if AudioManager:
			AudioManager.play_sfx("umbrella")
		if umbrella_visual:
			umbrella_visual.visible = true
		_update_portal()
		GameManager.dialog_triggered.emit("พี่ของขวัญ & น้องปีใหม่", "กางร่มสีหวานแสนอบอุ่นเรียบร้อย! เดินแบ่งปันร่มด้วยกันไม่เปียกฝนเลย! ☔ เดินไปชวนเพื่อนที่ติดฝนใต้ชายคาข้างหน้ากลับบ้านด้วยกันเถอะ!", "")

	# Share umbrella with friend under awning
	if near_friend and use_umbrella_pressed:
		if GameManager.umbrella_active and not friend_helped:
			friend_helped = true
			GameManager.complete_good_deed("q_share_umbrella")
			if friend_prompt:
				friend_prompt.visible = false
			if friend_label:
				friend_label.text = "เพื่อนนักเรียน (เดินใต้ร่ม ☔)"
				friend_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.65))
			_update_portal()
			GameManager.dialog_triggered.emit("เพื่อนนักเรียนข้างบ้าน", "โอ้โห! ขอบคุณของขวัญกับปีใหม่มากๆ เลยนะ! เราลืมพกร่มมา ดีใจจังที่มีเพื่อนมีน้ำใจแบบนี้ เดินกลับบ้านด้วยกันนะ! ☔✨ ⭐ ได้รับแต้มความดี!", "res://assets/characters/npcs/npc_boy_student.png")
		elif not GameManager.umbrella_active:
			GameManager.dialog_triggered.emit("เพื่อนนักเรียนข้างบ้าน", "ฮือๆ ฝนตกหนักมาก เราลืมเอาร่มมา ติดฝนอยู่ตรงนี้... สองพี่น้องมีร่มพกมาด้วยไหมนะ? (กด [Q] หรือ [E] เพื่อกางร่มก่อนนะ)", "res://assets/characters/npcs/npc_boy_student.png")
		else:
			GameManager.dialog_triggered.emit("เพื่อนนักเรียนข้างบ้าน", "เดินใต้ร่มอุ่นสบายมาก ขอบคุณสองพี่น้องอีกครั้งนะ!", "res://assets/characters/npcs/npc_boy_student.png")

	# Follow sisters with umbrella visual & warm player light
	var target_x: float = p1.global_position.x if p1 else 100.0
	if p1 and p2:
		target_x = (p1.global_position.x + p2.global_position.x) * 0.5

	# If friend has been helped, walk alongside the sisters under the shared umbrella!
	if friend_helped and friend_area:
		var prev_x := friend_area.global_position.x
		var desired_x := target_x - 22.0
		friend_area.global_position.x = move_toward(prev_x, desired_x, 220.0 * delta)
		var moved_dx := friend_area.global_position.x - prev_x
		if friend_sprite:
			if abs(moved_dx) > 0.2:
				friend_anim_t += delta * 10.0
				friend_sprite.flip_h = (moved_dx < 0.0)
				friend_sprite.position.y = -10.0 + sin(friend_anim_t) * 2.5
			else:
				friend_sprite.position.y = -10.0

	if umbrella_visual and umbrella_visual.visible and p1:
		umbrella_visual.global_position = Vector2(target_x, p1.global_position.y - 100.0)

	if has_node("PlayerLight") and p1:
		$PlayerLight.global_position = Vector2(target_x, p1.global_position.y - 45.0)

func _update_portal() -> void:
	if not portal_home:
		return
	var friend_ok: bool = friend_helped or (GameManager.good_deeds.get("q_share_umbrella", {}).get("status", "") == "completed")
	if GameManager.umbrella_active and friend_ok:
		portal_home.is_locked = false
		portal_home.portal_name = "เข้าสู่บ้านแสนสุข [เปิดแล้ว! ✨]"
	else:
		portal_home.is_locked = true
		portal_home.portal_name = "เข้าสู่บ้านแสนสุข [ทำเควสร่มก่อน]"
		if not GameManager.umbrella_active:
			portal_home.lock_message = "ฝนกำลังตกหนัก! กด [Q] หรือกด [E/Shift] เพื่อกาง 'ร่ม' ที่เตรียมมาตั้งแต่เช้า และแวะรับเพื่อนที่ติดฝนใต้ชายคา (กลางซอย) กลับบ้านด้วยกันนะจ๊ะ! ☔"
		else:
			portal_home.lock_message = "กางร่มแล้ว! อย่าลืมแวะรับ 'เพื่อนนักเรียนที่ติดฝน' ใต้ชายคาที่กลางซอย (x: 2120) เพื่อเดินกลับบ้านด้วยกันก่อนนะจ๊ะ! ☔🤝"
