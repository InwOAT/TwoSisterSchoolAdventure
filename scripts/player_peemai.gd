extends CharacterBody2D
class_name PlayerPeemai

@export var walk_speed: float = 185.0
@export var run_speed: float = 305.0
@export var crawl_speed: float = 125.0
@export var climb_speed: float = 170.0
@export var jump_velocity: float = -435.0

var gravity: float = 980.0
var target_to_follow: Node2D = null

# Stamina & Energy System
var max_stamina: float = 100.0
var stamina: float = 100.0
var is_exhausted: bool = false
var is_running: bool = false

# MapleStory M Ladder / Rope Climbing
var near_ladders: int = 0
var is_climbing: bool = false
var ladder_x: float = 0.0

var stamina_drain_run: float = 24.0
var stamina_drain_walk: float = 4.0
var stamina_recover_idle: float = 18.0

var last_tap_time_left: float = -1.0
var last_tap_time_right: float = -1.0
var walk_anim_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var name_tag: Label = $NameTag
@onready var emote_label: Label = $EmoteLabel
@onready var stamina_bar: ProgressBar = $StaminaBar

var current_mood: String = "normal"
var is_crawling: bool = false
var emote_timer: float = 0.0
var _was_on_floor: bool = true
var _base_scale: Vector2 = Vector2(0.46, 0.46)
var _dust_timer: float = 0.0
var _cheer_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("player2")
	add_to_group("players")
	if sprite:
		_base_scale = sprite.scale
	if name_tag:
		name_tag.text = "น้องปีใหม่ (P2)"
	_update_texture()
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina

func set_near_ladder(near: bool, lx: float = 0.0) -> void:
	if near:
		near_ladders += 1
		ladder_x = lx
	else:
		near_ladders = maxi(0, near_ladders - 1)
		if near_ladders == 0:
			is_climbing = false

func _physics_process(delta: float) -> void:
	var is_solo := (GameManager.active_player_solo == 0) # Controlled by AI if Khongkwan is solo active
	var single_pad := (Input.get_connected_joypads().size() <= 1)
	var direction := 0.0
	var v_dir := 0.0

	# 1. Exhausted State Check (เหนื่อยหอบ)
	if is_exhausted:
		is_climbing = false
		if not is_on_floor():
			velocity.y += gravity * delta
		direction = 0.0
		velocity.x = move_toward(velocity.x, 0, walk_speed * 6 * delta)
		if sprite:
			sprite.frame = 7
			sprite.position.y = -60.0 + sin(Time.get_ticks_msec() * 0.016) * 4.0
		
		stamina += stamina_recover_idle * delta
		if stamina >= 30.0:
			is_exhausted = false
			set_mood("normal")
			if emote_label:
				emote_label.visible = false
		
		_update_stamina_ui()
		move_and_slide()
		return

	# 2. Controls when NOT exhausted
	if not is_solo:
		var now := Time.get_ticks_msec() / 1000.0
		var left_just := Input.is_action_just_pressed("p2_left") or (single_pad and Input.is_action_just_pressed("p1_left"))
		var right_just := Input.is_action_just_pressed("p2_right") or (single_pad and Input.is_action_just_pressed("p1_right"))
		
		if left_just:
			if now - last_tap_time_left < 0.28:
				is_running = true
			last_tap_time_left = now
		elif right_just:
			if now - last_tap_time_right < 0.28:
				is_running = true
			last_tap_time_right = now

		var sprint_held := Input.is_action_pressed("p2_sprint") or (single_pad and Input.is_action_pressed("p1_sprint"))
		if sprint_held:
			is_running = true
		elif not Input.is_action_pressed("p2_left") and not Input.is_action_pressed("p2_right") and not (single_pad and (Input.is_action_pressed("p1_left") or Input.is_action_pressed("p1_right"))):
			is_running = false

		var up_pressed := Input.is_action_pressed("p2_up") or (single_pad and Input.is_action_pressed("p1_up"))
		var down_pressed := Input.is_action_pressed("p2_down") or (single_pad and Input.is_action_pressed("p1_down"))
		if up_pressed:
			v_dir = -1.0
		elif down_pressed:
			v_dir = 1.0

		var left_pressed := Input.is_action_pressed("p2_left") or (single_pad and Input.is_action_pressed("p1_left"))
		var right_pressed := Input.is_action_pressed("p2_right") or (single_pad and Input.is_action_pressed("p1_right"))
		var jump_pressed := Input.is_action_just_pressed("p2_jump") or (single_pad and Input.is_action_just_pressed("p1_jump"))
		var interact_pressed := Input.is_action_just_pressed("p2_interact") or (single_pad and Input.is_action_just_pressed("p1_interact"))

		if left_pressed:
			direction = -1.0
		elif right_pressed:
			direction = 1.0

		# Ladder climbing check (MapleStory M style - only climb UP from floor, or UP/DOWN while in air)
		if near_ladders > 0 and ((v_dir < 0.0) or (v_dir > 0.0 and not is_on_floor())):
			is_climbing = true
			_set_crawl(false)
			global_position.x = lerpf(global_position.x, ladder_x, 12.0 * delta)
		elif direction != 0.0 and v_dir == 0.0:
			is_climbing = false

		if is_climbing:
			velocity.y = v_dir * climb_speed
			velocity.x = direction * (walk_speed * 0.65)
			if jump_pressed:
				is_climbing = false
				velocity.y = jump_velocity * 0.85
			elif is_on_floor() and v_dir >= 0.0:
				is_climbing = false
		else:
			if not is_on_floor():
				velocity.y += gravity * delta
			if down_pressed and is_on_floor():
				_set_crawl(true)
				is_running = false
			else:
				_set_crawl(false)

			if jump_pressed and is_on_floor():
				if down_pressed and global_position.y < 590.0:
					position.y += 6.0
				elif not is_crawling:
					velocity.y = jump_velocity
					if sprite:
						sprite.scale = Vector2(_base_scale.x * 0.86, _base_scale.y * 1.15)
					GameManager.spawn_dust_puff(global_position, 6)
					if AudioManager:
						AudioManager.play_sfx("jump", 1.25)

		if interact_pressed:
			if not _try_sister_cheer():
				show_emote("สวัสดีค่ะ! 😊")
				GameManager.add_star()
	else:
		# AI follow Khongkwan
		is_climbing = false
		_set_crawl(false)
		if not is_on_floor():
			velocity.y += gravity * delta
		if target_to_follow != null:
			var dist_x: float = target_to_follow.global_position.x - global_position.x
			if abs(dist_x) > 65.0:
				direction = sign(dist_x)
				is_running = abs(dist_x) > 150.0
			else:
				is_running = false
			if (is_on_wall() or target_to_follow.global_position.y < global_position.y - 30.0) and is_on_floor():
				velocity.y = jump_velocity
				if sprite:
					sprite.scale = Vector2(_base_scale.x * 0.86, _base_scale.y * 1.15)

	# 3. Energy Consumption & MapleStory Side-View Frame Animation
	var current_move_speed := crawl_speed if is_crawling else (run_speed if is_running else walk_speed)
	var base_y := -60.0 if not is_crawling else -36.0

	if is_climbing:
		if sprite:
			walk_anim_time += delta * (8.5 if v_dir != 0.0 else 0.0)
			sprite.frame = 6 if int(walk_anim_time) % 2 == 0 else 3
			sprite.position.y = base_y
		stamina = minf(max_stamina, stamina + stamina_recover_idle * 0.5 * delta)
	elif direction != 0:
		velocity.x = direction * current_move_speed
		if sprite:
			sprite.flip_h = (direction < 0)
			walk_anim_time += delta * (14.0 if is_running else 9.0)
			if not is_on_floor():
				sprite.frame = 6
				sprite.position.y = base_y
			else:
				var walk_frames := [2, 3, 4, 5]
				sprite.frame = walk_frames[int(walk_anim_time) % 4]
				sprite.position.y = base_y + sin(walk_anim_time * PI) * (3.0 if is_running else 2.0)
				if is_running:
					_dust_timer -= delta
					if _dust_timer <= 0.0:
						_dust_timer = 0.24
						GameManager.spawn_dust_puff(global_position, 4)

		var drain := stamina_drain_run if is_running else stamina_drain_walk
		stamina -= drain * delta
		if stamina <= 0.0:
			stamina = 0.0
			is_exhausted = true
			set_mood("worried")
			show_emote("แฮ่ก... แฮ่ก... เหนื่อยจัง 💦", 999.0)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * 4 * delta)
		if sprite:
			if not is_on_floor():
				sprite.frame = 6
			elif current_mood == "happy":
				sprite.frame = 6
			elif current_mood == "worried":
				sprite.frame = 7
			else:
				walk_anim_time += delta * 2.4
				sprite.frame = 0 if int(walk_anim_time) % 2 == 0 else 1
			sprite.position.y = base_y
		stamina = minf(max_stamina, stamina + stamina_recover_idle * delta)

	move_and_slide()

	# Landing squash & dust puff
	var on_flr := is_on_floor()
	if on_flr and not _was_on_floor:
		if sprite and not is_crawling:
			sprite.scale = Vector2(_base_scale.x * 1.15, _base_scale.y * 0.85)
		GameManager.spawn_dust_puff(global_position, 6)
		if AudioManager:
			AudioManager.play_sfx("land", randf_range(1.05, 1.2), -4.0)
	_was_on_floor = on_flr

	if sprite:
		var target_scale := Vector2(0.48, 0.30) if is_crawling else _base_scale
		sprite.scale = sprite.scale.lerp(target_scale, minf(1.0, 14.0 * delta))

	if _cheer_cooldown > 0.0:
		_cheer_cooldown -= delta

	# Handle push collision with Pushable objects
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider := col.get_collider()
		if collider != null and collider.is_in_group("pushable"):
			collider.apply_push(Vector2(direction * 100.0, 0))

	if emote_timer > 0:
		emote_timer -= delta
		if emote_timer <= 0 and emote_label and not is_exhausted:
			emote_label.visible = false

	_update_stamina_ui()

func _update_stamina_ui() -> void:
	if stamina_bar:
		stamina_bar.value = stamina
		stamina_bar.visible = (stamina < max_stamina or is_exhausted)
		if is_exhausted or stamina < 25.0:
			stamina_bar.modulate = Color(1.0, 0.2, 0.2)
		elif stamina < 55.0:
			stamina_bar.modulate = Color(1.0, 0.85, 0.2)
		else:
			stamina_bar.modulate = Color(0.3, 1.0, 0.4)
	
	GameManager.stamina_updated.emit(1, stamina, max_stamina, is_exhausted)

func _set_crawl(crawl: bool) -> void:
	if is_crawling == crawl:
		return
	is_crawling = crawl
	if collision_shape and collision_shape.shape is CapsuleShape2D:
		var cap := collision_shape.shape as CapsuleShape2D
		if is_crawling:
			cap.height = 36.0
			collision_shape.position.y = -18.0
			if sprite:
				sprite.scale = Vector2(0.48, 0.30)
		else:
			cap.height = 76.0
			collision_shape.position.y = -38.0
			if sprite:
				sprite.scale = Vector2(0.46, 0.46)

func show_emote(text: String, duration: float = 2.0) -> void:
	if emote_label:
		emote_label.text = text
		emote_label.visible = true
		emote_timer = duration

func set_mood(mood: String) -> void:
	current_mood = mood
	_update_texture()

func _update_texture() -> void:
	if not sprite:
		return
	var sheet_path := "res://assets/characters/peemai/spritesheet_maple.png"
	if ResourceLoader.exists(sheet_path):
		sprite.texture = load(sheet_path)
		sprite.hframes = 8
	if current_mood == "happy":
		sprite.frame = 6
	elif current_mood == "worried":
		sprite.frame = 7
	else:
		sprite.frame = 0

func _try_sister_cheer() -> bool:
	if _cheer_cooldown > 0.0 or target_to_follow == null:
		return false
	var dist := global_position.distance_to(target_to_follow.global_position)
	if dist > 95.0:
		return false
	var sister_exhausted: bool = target_to_follow.get("is_exhausted") == true
	var sister_stamina: float = float(target_to_follow.get("stamina")) if "stamina" in target_to_follow else 100.0
	if not sister_exhausted and sister_stamina >= 85.0 and stamina >= 85.0:
		return false

	_cheer_cooldown = 3.0
	stamina = max_stamina
	is_exhausted = false
	set_mood("happy")
	show_emote("🙌 แปะมือเชียร์! พี่ของขวัญสู้ๆ นะคะ! 💖", 2.5)

	if "stamina" in target_to_follow:
		target_to_follow.set("stamina", 100.0)
	if "is_exhausted" in target_to_follow:
		target_to_follow.set("is_exhausted", false)
	if target_to_follow.has_method("set_mood"):
		target_to_follow.call("set_mood", "happy")
	if target_to_follow.has_method("show_emote"):
		target_to_follow.call("show_emote", "🙌 ขอบใจจ้ะปีใหม่! มีแรงลุยต่อแล้ว! ✨", 2.5)

	if AudioManager:
		AudioManager.play_sfx("sister_cheer")
	var mid := (global_position + target_to_follow.global_position) * 0.5
	GameManager.spawn_star_burst(mid, Color(1.0, 0.55, 0.85))
	GameManager.spawn_floating_text(mid, "💖 พลังคู่หูพี่น้อง! ฟื้นฟูกำลัง 100%!", Color(1.0, 0.65, 0.88), -110.0)
	GameManager.add_star()
	return true

