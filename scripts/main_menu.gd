extends Control

@onready var btn_start: Button = $VBoxContainer/BtnStart
@onready var btn_controls: Button = $VBoxContainer/BtnControls
@onready var btn_quit: Button = $VBoxContainer/BtnQuit
@onready var controls_panel: Panel = $ControlsPanel
@onready var btn_close_controls: Button = $ControlsPanel/BtnCloseControls
@onready var btn_audio: Button = get_node_or_null("BtnAudio")

var is_starting: bool = false

@onready var characters_area: Control = $Characters
@onready var sprite_kk: Sprite2D = $Characters/SpriteKhongkwan
@onready var sprite_pm: Sprite2D = $Characters/SpritePeemai
@onready var shadow_kk: Panel = $Characters/ShadowKhongkwan
@onready var shadow_pm: Panel = $Characters/ShadowPeemai
@onready var emote_kk: Label = $Characters/EmoteKhongkwan
@onready var emote_pm: Label = $Characters/EmotePeemai
@onready var butterfly: Label = $Characters/Butterfly
@onready var sparkles_root: Node2D = $Characters/SparklesRoot

@onready var stage_hint: Label = $CharacterStage/StageHint

# Ground and stage parameters (Stage is 760px wide, 265px tall)
const MIN_X: float = 65.0
const MAX_X: float = 695.0
const GROUND_Y_KK: float = 170.0
const GROUND_Y_PM: float = 182.0
const SHADOW_Y_KK: float = 232.0
const SHADOW_Y_PM: float = 234.0

# Base scales
const BASE_SCALE_KK := Vector2(0.50, 0.50)
const BASE_SCALE_PM := Vector2(0.44, 0.44)

# Positions & velocities
var kk_x: float = 240.0
var pm_x: float = 130.0
var kk_dir: float = 1.0
var pm_dir: float = 1.0
var kk_speed: float = 135.0
var pm_speed: float = 148.0

# Animation timers
var kk_anim_t: float = 0.0
var pm_anim_t: float = 0.0
var walk_frames: Array[int] = [2, 3, 4, 5]

# Jump states
var kk_jumping: bool = false
var kk_jump_t: float = 0.0
var kk_jump_dur: float = 0.58
var kk_jump_h: float = 75.0
var kk_next_jump: float = 1.8

var pm_jumping: bool = false
var pm_jump_t: float = 0.0
var pm_jump_dur: float = 0.52
var pm_jump_h: float = 65.0
var pm_next_jump: float = 2.4

# Butterfly flight
var butterfly_x: float = 380.0
var butterfly_y: float = 115.0
var butterfly_t: float = 0.0

# Emote speech bubbles
var emote_cycle_timer: float = 2.0
var emote_display_timer: float = 0.0
var active_emote_speaker: int = 0 # 0 = KK, 1 = PM
var quote_idx_kk: int = 0
var quote_idx_pm: int = 0

var kk_quotes: Array[String] = [
	"ไปโรงเรียนกันเถอะปีใหม่! 🎒",
	"วิ่งเร็วๆ เดี๋ยวไม่ทันรถเมล์! 🚌💨",
	"ฮึบ! กระโดดสูงงง! 🌸",
	"จับพี่ให้ได้สิ! 🏃‍♀️✨",
	"วันนี้หนูจะทำความดี! ⭐",
	"เย้! วันนี้แดดแจ่มใสจัง ☀️"
]

var pm_quotes: Array[String] = [
	"รอหนูด้วยยย พี่ของขวัญ! 🏃‍♀️",
	"เย้ๆๆ สนุกจังเลย! 💖",
	"ฮ่าๆๆ จับพี่ของขวัญได้แล้ว! 🎈",
	"กระโดดดดด! ✨",
	"ผีเสื้อจ๋า บินไปไหนน่ะ! 🦋",
	"หนูอยากกินขนมที่โรงอาหาร! 🍦"
]

# Floating particles
var sparkles: Array[Dictionary] = []

func _ready() -> void:
	# Play lovely and cheerful Title Theme BGM
	if AudioManager:
		AudioManager.play_title_bgm()

	btn_start.pressed.connect(_on_start_pressed)
	btn_controls.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		controls_panel.visible = true
	)
	btn_quit.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		get_tree().quit()
	)
	btn_close_controls.pressed.connect(func():
		if AudioManager: AudioManager.play_sfx("ui_click")
		controls_panel.visible = false
	)
	controls_panel.visible = false

	# Button Hover SFX
	btn_start.mouse_entered.connect(func(): if AudioManager: AudioManager.play_sfx("ui_hover", 1.0, -6.0))
	btn_controls.mouse_entered.connect(func(): if AudioManager: AudioManager.play_sfx("ui_hover", 1.1, -6.0))
	btn_quit.mouse_entered.connect(func(): if AudioManager: AudioManager.play_sfx("ui_hover", 0.95, -6.0))
	btn_close_controls.mouse_entered.connect(func(): if AudioManager: AudioManager.play_sfx("ui_hover", 1.0, -6.0))

	# Audio Mute / Sound Toggle Button
	if btn_audio:
		btn_audio.text = "🔇" if (AudioManager and AudioManager.is_muted) else "🔊"
		btn_audio.pressed.connect(_on_audio_toggle_pressed)
		btn_audio.mouse_entered.connect(func(): if AudioManager: AudioManager.play_sfx("ui_hover", 1.15, -6.0))

	if characters_area:
		characters_area.gui_input.connect(_on_characters_gui_input)

	# Initial positions
	_update_character_transforms(0.0)

func _on_audio_toggle_pressed() -> void:
	if AudioManager:
		var muted: bool = AudioManager.toggle_mute()
		if btn_audio:
			btn_audio.text = "🔇" if muted else "🔊"
		if not muted:
			AudioManager.play_sfx("ui_click")

func _process(delta: float) -> void:
	if stage_hint:
		stage_hint.modulate.a = 0.65 + sin(Time.get_ticks_msec() * 0.0035) * 0.35
	_update_chasing_movement(delta)
	_update_jumping_physics(delta)
	_update_butterfly(delta)
	_update_emotes(delta)
	_update_sparkles(delta)
	_update_character_transforms(delta)

func _update_chasing_movement(delta: float) -> void:
	# 1. Khongkwan leads the run
	kk_x += kk_dir * kk_speed * delta

	# Turn around at borders with a playful jump!
	if kk_dir > 0.0 and kk_x >= MAX_X:
		kk_dir = -1.0
		_kk_jump(80.0)
		_spawn_burst(Vector2(kk_x, GROUND_Y_KK))
	elif kk_dir < 0.0 and kk_x <= MIN_X:
		kk_dir = 1.0
		_kk_jump(80.0)
		_spawn_burst(Vector2(kk_x, GROUND_Y_KK))

	# 2. Peemai chases her big sister playfully
	var dist_to_kk := kk_x - pm_x
	var target_dir := signf(dist_to_kk)
	if target_dir != 0.0:
		pm_dir = target_dir

	var speed_mult := 1.0
	var abs_dist := absf(dist_to_kk)
	if abs_dist > 160.0:
		speed_mult = 1.35 # Run faster to catch up!
	elif abs_dist < 50.0:
		speed_mult = 0.85 # Slow down / play tag!
		if not pm_jumping and randf() < 0.03:
			_pm_jump(70.0)

	pm_x += pm_dir * (pm_speed * speed_mult) * delta
	pm_x = clampf(pm_x, MIN_X, MAX_X)

func _update_jumping_physics(delta: float) -> void:
	# Khongkwan periodic jump
	kk_next_jump -= delta
	if kk_next_jump <= 0.0 and not kk_jumping:
		_kk_jump(randf_range(65.0, 85.0))
		kk_next_jump = randf_range(2.2, 4.2)

	if kk_jumping:
		kk_jump_t += delta
		if kk_jump_t >= kk_jump_dur:
			kk_jumping = false
			_spawn_burst(Vector2(kk_x, GROUND_Y_KK))
			if AudioManager and not is_starting:
				AudioManager.play_sfx("land", 1.2, -18.0)
			# Sister synchronization jump!
			if not pm_jumping and randf() < 0.65:
				_pm_jump(65.0)

	# Peemai periodic jump
	pm_next_jump -= delta
	if pm_next_jump <= 0.0 and not pm_jumping:
		_pm_jump(randf_range(55.0, 75.0))
		pm_next_jump = randf_range(1.8, 3.8)

	if pm_jumping:
		pm_jump_t += delta
		if pm_jump_t >= pm_jump_dur:
			pm_jumping = false
			_spawn_burst(Vector2(pm_x, GROUND_Y_PM))
			if AudioManager and not is_starting:
				AudioManager.play_sfx("land", 1.35, -18.0)

func _kk_jump(h: float) -> void:
	kk_jumping = true
	kk_jump_t = 0.0
	kk_jump_h = h
	kk_jump_dur = 0.56
	if AudioManager and not is_starting:
		AudioManager.play_sfx("jump", 1.25, -14.0)

func _pm_jump(h: float) -> void:
	pm_jumping = true
	pm_jump_t = 0.0
	pm_jump_h = h
	pm_jump_dur = 0.50
	if AudioManager and not is_starting:
		AudioManager.play_sfx("jump", 1.45, -14.0)

func _update_character_transforms(delta: float) -> void:
	# Khongkwan
	var kk_y_off := 0.0
	if kk_jumping:
		var p := clampf(kk_jump_t / kk_jump_dur, 0.0, 1.0)
		kk_y_off = -sin(p * PI) * kk_jump_h
		sprite_kk.frame = 6 # Joyful jump pose!
		sprite_kk.scale = Vector2(BASE_SCALE_KK.x * 0.92, BASE_SCALE_KK.y * 1.12)
	else:
		kk_anim_t += delta * 11.5
		sprite_kk.frame = walk_frames[int(kk_anim_t) % 4]
		kk_y_off = sin(kk_anim_t * PI) * 2.8 # running bob
		sprite_kk.scale = BASE_SCALE_KK

	sprite_kk.position = Vector2(kk_x, GROUND_Y_KK + kk_y_off)
	sprite_kk.flip_h = (kk_dir < 0.0)

	# Khongkwan shadow
	if shadow_kk:
		shadow_kk.position = Vector2(kk_x - 24.0, SHADOW_Y_KK)
		var s_ratio := clampf(absf(kk_y_off) / 80.0, 0.0, 1.0)
		shadow_kk.scale = Vector2(1.0 - s_ratio * 0.45, 1.0 - s_ratio * 0.45)
		shadow_kk.modulate.a = 0.75 - s_ratio * 0.45

	# Peemai
	var pm_y_off := 0.0
	if pm_jumping:
		var p := clampf(pm_jump_t / pm_jump_dur, 0.0, 1.0)
		pm_y_off = -sin(p * PI) * pm_jump_h
		sprite_pm.frame = 6 # Joyful jump pose!
		sprite_pm.scale = Vector2(BASE_SCALE_PM.x * 0.92, BASE_SCALE_PM.y * 1.12)
	else:
		pm_anim_t += delta * 12.5
		sprite_pm.frame = walk_frames[int(pm_anim_t) % 4]
		pm_y_off = sin(pm_anim_t * PI) * 2.5 # running bob
		sprite_pm.scale = BASE_SCALE_PM

	sprite_pm.position = Vector2(pm_x, GROUND_Y_PM + pm_y_off)
	sprite_pm.flip_h = (pm_dir < 0.0)

	# Peemai shadow
	if shadow_pm:
		shadow_pm.position = Vector2(pm_x - 21.0, SHADOW_Y_PM)
		var s_ratio := clampf(absf(pm_y_off) / 70.0, 0.0, 1.0)
		shadow_pm.scale = Vector2(1.0 - s_ratio * 0.45, 1.0 - s_ratio * 0.45)
		shadow_pm.modulate.a = 0.75 - s_ratio * 0.45

	# Emote bubbles positions
	if emote_kk and emote_kk.visible:
		var bx := clampf(kk_x - emote_kk.size.x * 0.5, 12.0, 748.0 - emote_kk.size.x)
		var by := clampf(GROUND_Y_KK + kk_y_off - 82.0, 12.0, 180.0)
		emote_kk.position = Vector2(bx, by)
	if emote_pm and emote_pm.visible:
		var bx := clampf(pm_x - emote_pm.size.x * 0.5, 12.0, 748.0 - emote_pm.size.x)
		var by := clampf(GROUND_Y_PM + pm_y_off - 78.0, 12.0, 180.0)
		emote_pm.position = Vector2(bx, by)

func _update_butterfly(delta: float) -> void:
	if not butterfly:
		return
	butterfly_t += delta
	# Butterfly flutters in front of whoever is leading
	var lead_x: float = kk_x if kk_dir > 0.0 else pm_x
	var target_x: float = clampf(lead_x + kk_dir * 85.0, MIN_X + 20.0, MAX_X - 20.0)
	butterfly_x = lerp(butterfly_x, target_x, delta * 2.8)
	butterfly_y = 105.0 + sin(butterfly_t * 5.0) * 20.0 + cos(butterfly_t * 2.3) * 8.0

	butterfly.position = Vector2(butterfly_x, butterfly_y)
	butterfly.scale.x = 1.0 if kk_dir > 0.0 else -1.0

func _update_emotes(delta: float) -> void:
	if emote_display_timer > 0.0:
		emote_display_timer -= delta
		if emote_display_timer <= 0.0:
			if emote_kk: emote_kk.visible = false
			if emote_pm: emote_pm.visible = false

	emote_cycle_timer -= delta
	if emote_cycle_timer <= 0.0:
		emote_cycle_timer = randf_range(3.2, 5.0)
		emote_display_timer = 2.4
		if active_emote_speaker == 0:
			if emote_kk:
				emote_kk.text = kk_quotes[quote_idx_kk % kk_quotes.size()]
				quote_idx_kk += 1
				emote_kk.visible = true
			if emote_pm: emote_pm.visible = false
			active_emote_speaker = 1
		else:
			if emote_pm:
				emote_pm.text = pm_quotes[quote_idx_pm % pm_quotes.size()]
				quote_idx_pm += 1
				emote_pm.visible = true
			if emote_kk: emote_kk.visible = false
			active_emote_speaker = 0

func _on_characters_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_interactive_jump()

func _interactive_jump() -> void:
	# Play joyful cheer and jump audio!
	if AudioManager:
		AudioManager.play_sfx("sister_cheer", 1.0, 1.0)
		AudioManager.play_sfx("jump", 1.15, -4.0)

	# Both sisters do a high joyful jump together!
	_kk_jump(90.0)
	_pm_jump(85.0)
	_spawn_burst(Vector2(kk_x, GROUND_Y_KK))
	_spawn_burst(Vector2(pm_x, GROUND_Y_PM))

	# Show cheer emotes!
	if emote_kk:
		emote_kk.text = "เย้ๆๆ! เล่นด้วยกันนะ! 🎉"
		emote_kk.visible = true
	if emote_pm:
		emote_pm.text = "ฮ่าๆๆ สนุกที่สุดเลย! 💖"
		emote_pm.visible = true
	emote_display_timer = 2.5

func _spawn_burst(origin: Vector2) -> void:
	if not sparkles_root:
		return
	var emojis: Array[String] = ["✨", "⭐", "💖", "🌸", "🎵", "🎈"]
	for i in range(3):
		var lbl := Label.new()
		lbl.text = emojis[randi() % emojis.size()]
		lbl.add_theme_font_size_override("font_size", randi_range(13, 17))
		lbl.position = origin + Vector2(randf_range(-25.0, 25.0), randf_range(-15.0, 10.0))
		sparkles_root.add_child(lbl)

		var vel := Vector2(randf_range(-40.0, 40.0), randf_range(-60.0, -110.0))
		sparkles.append({
			"node": lbl,
			"vel": vel,
			"life": 0.85,
			"max_life": 0.85
		})

func _update_sparkles(delta: float) -> void:
	var to_remove: Array[int] = []
	for i in range(sparkles.size()):
		var p: Dictionary = sparkles[i]
		p["life"] -= delta
		if p["life"] <= 0.0:
			if is_instance_valid(p["node"]):
				p["node"].queue_free()
			to_remove.append(i)
		else:
			var node: Label = p["node"]
			node.position += p["vel"] * delta
			p["vel"].y += 35.0 * delta # gentle gravity
			var alpha: float = p["life"] / p["max_life"]
			node.modulate.a = alpha

	for i in range(to_remove.size() - 1, -1, -1):
		sparkles.remove_at(to_remove[i])

func _on_start_pressed() -> void:
	if is_starting:
		return
	is_starting = true
	btn_start.disabled = true
	
	if AudioManager:
		AudioManager.play_sfx("game_start", 1.0, 3.0)
	
	# Gentle button pulse and transition
	var tw := create_tween()
	tw.tween_property(btn_start, "scale", Vector2(1.08, 1.08), 0.12)
	tw.tween_property(btn_start, "scale", Vector2(1.0, 1.0), 0.12)
	
	await get_tree().create_timer(0.35).timeout
	GameManager.reset_all_state()
	GameManager.change_level(1, 120.0)
