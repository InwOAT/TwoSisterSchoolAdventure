extends Area2D
class_name MaplePortal

@export var target_level: int = 1
@export var target_scene_path: String = ""
@export var target_spawn_x: float = 120.0
@export var portal_name: String = "วาป"
@export var is_locked: bool = false:
	set(val):
		var was_locked := is_locked
		is_locked = val
		_update_portal_visuals()
		if was_locked and not is_locked and is_inside_tree() and GameManager:
			GameManager.spawn_star_burst(global_position, Color(0.25, 1.0, 0.88))
@export var lock_message: String = "ทางยังไม่เปิด ต้องทำเควสในฉากให้ครบก่อนนะจ๊ะ!"
@export var is_building_door: bool = false # เมื่อเป็น true จะใช้แสงสีทองอร่าม (Royal Warm Gold) สำหรับประตูสถานที่
@export var portal_scale: float = 1.0 # ตัวคูณปรับสเกลขนาดวงกลมและเสาแสงให้ยืดหยุ่น

var p1_inside: bool = false
var p2_inside: bool = false
var pulse_time: float = 0.0
var current_beam_height: float = 0.0

@onready var light_circle: Sprite2D = get_node_or_null("LightCircle")
@onready var vertical_beam: Sprite2D = get_node_or_null("VerticalBeam")
@onready var rising_sparkles: CPUParticles2D = get_node_or_null("RisingSparkles")
@onready var light_beam: CanvasItem = get_node_or_null("LightBeam")
@onready var status_badge: PanelContainer = get_node_or_null("StatusBadge")
@onready var badge_label: Label = get_node_or_null("StatusBadge/BadgeLabel")
@onready var prompt_label: Label = get_node_or_null("PromptLabel")

# Crimson Red colors (ก่อนทำเควสเสร็จ / ยังผ่านไม่ได้ - สำหรับวาปที่ล็อกอยู่ วงกลมเรืองแสงสีแดงเตือนชัดเจน)
const COLOR_LOCKED_RED := Color(1.0, 0.18, 0.22, 0.98)
const COLOR_LOCKED_BEAM := Color(1.0, 0.25, 0.25, 0.85)
const COLOR_LOCKED_AMBER := COLOR_LOCKED_RED # Backward compatibility alias

# Emerald Cyan colors (เมื่อทำเควสครบแล้ว - สำหรับวาปผ่านฉากหลัก / Next Level Portal)
const COLOR_UNLOCKED_CYAN := Color(0.18, 1.0, 0.85, 0.98)
const COLOR_UNLOCKED_BEAM := Color(0.25, 1.0, 0.88, 0.92)

# Warm Royal Gold / Amber Amber Glow (สำหรับประตูเดินเข้าสถานที่ต่างๆ / Building Door Portal)
const COLOR_DOOR_GOLD := Color(1.0, 0.82, 0.22, 0.98)
const COLOR_DOOR_BEAM := Color(1.0, 0.88, 0.35, 0.92)
const COLOR_DOOR_SPARKLE := Color(1.0, 0.92, 0.45, 1.0)

var _style_locked: StyleBoxFlat
var _style_unlocked: StyleBoxFlat

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_styles()
	
	# อัตโนมัติ: ถ้าปลายทางเป็นห้องภายใน หรืออยู่ในห้องภายใน หรือชื่อโหนดมี Door/ประตู ให้ตั้งเป็นประตูสถานที่ทันที
	var scene_path := ""
	if get_tree() and get_tree().current_scene:
		scene_path = get_tree().current_scene.scene_file_path
	if "scenes/interiors/" in target_scene_path or target_level > 200 or "interiors/" in scene_path or "Door" in name or "door" in name.to_lower():
		is_building_door = true
	
	current_beam_height = 0.0 if is_locked else 1.0
	_update_portal_visuals()

func _setup_styles() -> void:
	_style_locked = StyleBoxFlat.new()
	_style_locked.bg_color = Color(0.24, 0.04, 0.04, 0.95)
	_style_locked.border_color = Color(1.0, 0.22, 0.22, 0.98)
	_style_locked.set_border_width_all(2)
	_style_locked.set_corner_radius_all(8)
	_style_locked.shadow_color = Color(0, 0, 0, 0.45)
	_style_locked.shadow_size = 4
	_style_locked.content_margin_left = 10.0
	_style_locked.content_margin_top = 4.0
	_style_locked.content_margin_right = 10.0
	_style_locked.content_margin_bottom = 4.0

	_style_unlocked = StyleBoxFlat.new()
	_style_unlocked.bg_color = Color(0.04, 0.22, 0.20, 0.95)
	_style_unlocked.border_color = Color(0.22, 1.0, 0.85, 0.98)
	_style_unlocked.set_border_width_all(2)
	_style_unlocked.set_corner_radius_all(8)
	_style_unlocked.shadow_color = Color(0, 0, 0, 0.45)
	_style_unlocked.shadow_size = 4
	_style_unlocked.content_margin_left = 10.0
	_style_unlocked.content_margin_top = 4.0
	_style_unlocked.content_margin_right = 10.0
	_style_unlocked.content_margin_bottom = 4.0

func _update_prompt() -> void:
	_update_portal_visuals()

func _update_portal_visuals() -> void:
	if not is_inside_tree():
		return
	
	if is_locked:
		# สีแดงเรืองแสง (Crimson Red) พร้อมป้ายแจ้ง: ยังผ่านไม่ได้ / ต้องทำเควสให้ครบก่อน
		if light_circle:
			light_circle.modulate = COLOR_LOCKED_RED
		if vertical_beam:
			vertical_beam.visible = false
			current_beam_height = 0.0
		elif light_beam:
			light_beam.visible = false
		
		if rising_sparkles:
			rising_sparkles.emitting = false
		
		if status_badge:
			status_badge.visible = false
		
		if prompt_label:
			prompt_label.text = "🔒 ยังผ่านไม่ได้: " + lock_message
			if GameManager:
				GameManager.style_prompt_label(prompt_label, COLOR_LOCKED_RED, Color(1.0, 0.45, 0.45))
			else:
				prompt_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	elif is_building_door:
		# แสงสีทองอบอุ่น (Royal Warm Gold) สำหรับประตูเดินเข้าสถานที่ต่างๆ ไม่ซ้ำกับวาปผ่านฉาก
		if light_circle:
			light_circle.modulate = COLOR_DOOR_GOLD
		if vertical_beam:
			vertical_beam.visible = true
			vertical_beam.modulate = COLOR_DOOR_BEAM
		elif light_beam:
			light_beam.visible = true
			light_beam.modulate = COLOR_DOOR_GOLD
		
		if rising_sparkles:
			rising_sparkles.emitting = true
			rising_sparkles.modulate = COLOR_DOOR_SPARKLE
			rising_sparkles.emission_rect_extents = Vector2(11, 3)
		
		if status_badge:
			status_badge.visible = false
		
		if prompt_label:
			prompt_label.text = "🚪 กด [W/↑/E] เข้าสู่ " + portal_name
			if GameManager:
				GameManager.style_prompt_label(prompt_label, COLOR_DOOR_GOLD, Color(1.0, 0.96, 0.88))
			else:
				prompt_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4))
	else:
		# วาปผ่านฉากหลัก (Next Level Portal): สีเขียว-ฟ้าสดใส (Emerald Cyan)
		if light_circle:
			light_circle.modulate = COLOR_UNLOCKED_CYAN
		if vertical_beam:
			vertical_beam.visible = true
			vertical_beam.modulate = Color(0.4, 1.0, 0.92, 0.98)
		elif light_beam:
			light_beam.visible = true
			light_beam.modulate = COLOR_UNLOCKED_CYAN
		
		if rising_sparkles:
			rising_sparkles.emitting = true
			rising_sparkles.modulate = Color(0.5, 1.0, 0.95, 1.0)
			rising_sparkles.emission_rect_extents = Vector2(16, 4)
		
		if status_badge:
			status_badge.visible = false
		
		if prompt_label:
			prompt_label.text = "🚪 กด [W/↑/E] เข้าสู่ " + portal_name
			if GameManager:
				GameManager.style_prompt_label(prompt_label, COLOR_UNLOCKED_CYAN, Color(0.85, 1.0, 0.95))
			else:
				prompt_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.7))

func _process(delta: float) -> void:
	pulse_time += delta
	
	# ปรับสเกลฐาน: ประตูสถานที่ (Building Door) จะมีขนาดกะทัดรัดพอดีกรอบประตู ไม่เทอะทะ
	var base_circle_x: float = (0.28 if is_building_door else 0.40) * portal_scale
	var base_circle_y: float = (0.115 if is_building_door else 0.165) * portal_scale
	
	# Light Circle floor pulsing
	if light_circle:
		var speed := 4.8 if not is_locked else 2.5
		var amp := 0.07 if not is_locked else 0.04
		var s := 1.0 + sin(pulse_time * speed) * amp
		light_circle.scale = Vector2(base_circle_x * s, base_circle_y * s)
	
	# Vertical light beam animation: rises up beautifully
	var beam = vertical_beam if vertical_beam else light_beam
	if beam:
		var beam_x_base: float = (0.32 if is_building_door else 0.48) * portal_scale
		var beam_h_max: float = 1.15 if is_building_door else 1.30
		var beam_y_max: float = 100.0 if is_building_door else 115.0
		
		if is_locked:
			current_beam_height = move_toward(current_beam_height, 0.0, delta * 3.5)
			if current_beam_height <= 0.01:
				beam.visible = false
			else:
				beam.visible = true
				beam.scale = Vector2(beam_x_base, current_beam_height * 0.9)
				beam.position.y = - (current_beam_height * 85.0)
		else:
			beam.visible = true
			current_beam_height = move_toward(current_beam_height, 1.0, delta * 3.0)
			var breathe := 1.0 + sin(pulse_time * 3.5) * 0.08
			beam.scale = Vector2(beam_x_base * (1.0 + sin(pulse_time * 2.2) * 0.05), current_beam_height * beam_h_max * breathe)
			beam.position.y = - (current_beam_height * beam_y_max * breathe)
			
			var base_a := 0.92
			beam.modulate.a = clamp(base_a + sin(pulse_time * 4.2) * 0.08, 0.7, 1.0)

	# Input check for portal activation
	var activate_p1 := p1_inside and (Input.is_action_just_pressed("p1_up") or Input.is_action_just_pressed("p1_interact"))
	var activate_p2 := p2_inside and (Input.is_action_just_pressed("p2_up") or Input.is_action_just_pressed("p2_interact"))

	if activate_p1 or activate_p2:
		_activate_portal()

func _activate_portal() -> void:
	# Auto-unlock for house door (Level 1 -> 2) or classroom door (Level 5 -> 6) when holding key
	if is_locked:
		if target_level == 2 and GameManager.has_item("กุญแจบ้าน"):
			is_locked = false
			GameManager.house_unlocked = true
			_update_portal_visuals()
		elif target_level == 6 and GameManager.has_item("กุญแจห้องและสมุดเช็คชื่อ"):
			is_locked = false
			GameManager.classroom_unlocked = true
			_update_portal_visuals()
		else:
			var msg := lock_message
			if msg == "":
				msg = "ทางยังไม่เปิด ต้องทำเควสในฉากให้ครบก่อนนะจ๊ะ!"
			GameManager.dialog_triggered.emit("ระบบ", "🔒 " + msg, "")
			return
	
	if AudioManager:
		AudioManager.play_sfx("portal")
	
	if target_scene_path != "":
		print("[Portal] Entering portal to scene: ", target_scene_path)
		GameManager.change_scene_to_file(target_scene_path, target_spawn_x, target_level)
	else:
		print("[Portal] Entering portal to Level ", target_level)
		GameManager.change_level(target_level, target_spawn_x)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player1"):
		p1_inside = true
	elif body.is_in_group("player2"):
		p2_inside = true
	
	if p1_inside or p2_inside:
		if is_locked and target_level == 2 and GameManager.has_item("กุญแจบ้าน"):
			is_locked = false
			GameManager.house_unlocked = true
		elif is_locked and target_level == 6 and GameManager.has_item("กุญแจห้องและสมุดเช็คชื่อ"):
			is_locked = false
			GameManager.classroom_unlocked = true
		_update_portal_visuals()
		if prompt_label:
			prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player1"):
		p1_inside = false
	elif body.is_in_group("player2"):
		p2_inside = false
	
	if not p1_inside and not p2_inside:
		if prompt_label:
			prompt_label.visible = false
