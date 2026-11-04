extends PanelContainer
class_name SchoolMiniMap

@onready var map_texture: TextureRect = $VBox/MapBox/MapTexture
@onready var marker: Control = $VBox/MapBox/MapTexture/Marker
@onready var marker_dot: ColorRect = $VBox/MapBox/MapTexture/Marker/Dot
@onready var zone_label: Label = $VBox/ZoneLabel
@onready var btn_expand: Button = $VBox/Header/BtnExpand

var tex_school: Texture2D = preload("res://assets/ui/school_map.png")
var tex_village: Texture2D = preload("res://assets/ui/village_map.png")

var pulse_time: float = 0.0

func _ready() -> void:
	if btn_expand:
		btn_expand.pressed.connect(func(): GameManager.map_toggled.emit())

func _process(delta: float) -> void:
	pulse_time += delta * 6.0
	if marker_dot:
		# Glowing pulsing animation for player marker
		var s := 1.0 + sin(pulse_time) * 0.25
		marker_dot.scale = Vector2(s, s)

	_update_player_position()

func _update_player_position() -> void:
	if not visible:
		return
	
	var cur_lvl := GameManager.current_level
	var map_size := map_texture.size
	if map_size.x <= 10 or map_size.y <= 10:
		return

	# Handle Don Mong Village Hub (Scene 2)
	if cur_lvl == 2:
		map_texture.texture = tex_village
		marker.visible = true
		
		var players = get_tree().get_nodes_in_group("players")
		var px := 200.0
		if not players.is_empty():
			px = players[0].global_position.x
		
		var target_norm := Vector2(0.5, 0.5)
		var zone_name := ""
		
		if px < 700.0:
			target_norm = Vector2(0.18, 0.44)
			zone_name = "📍 [ป้อมตำรวจ] เทศบาลดอนโมง"
		elif px < 1400.0:
			target_norm = Vector2(0.32, 0.36)
			zone_name = "📍 [ตลาดสด] ตลาดนัดคลองถม"
		elif px < 2100.0:
			target_norm = Vector2(0.46, 0.54)
			zone_name = "📍 [ร้านค้า] Lotus's & ร้านชำ"
		elif px < 2800.0:
			target_norm = Vector2(0.60, 0.45)
			zone_name = "📍 [สถานพยาบาล] คลินิกหมอดอนโมง"
		elif px < 3500.0:
			target_norm = Vector2(0.78, 0.44)
			zone_name = "📍 [ศาสนสถาน] วัดมงคลนิมิต"
		else:
			target_norm = Vector2(0.92, 0.52)
			zone_name = "📍 [ไปรษณีย์] ไปรษณีย์ไทย & รถเมล์"
		
		zone_label.text = zone_name
		var target_px := target_norm * map_size
		marker.position = marker.position.lerp(target_px, 0.15)
		return

	# If outside school levels (and not level 2), show general status
	if cur_lvl < 5 or cur_lvl > 8:
		map_texture.texture = tex_village
		if cur_lvl == 1:
			zone_label.text = "📍 ในบ้านแสนสุข"
		elif cur_lvl < 5:
			zone_label.text = "📍 กำลังเดินทางไปโรงเรียน"
		else:
			zone_label.text = "📍 เดินทางกลับบ้านหลังเลิกเรียน"
		marker.visible = false
		return
	
	# School Levels (5 - 8)
	map_texture.texture = tex_school
	marker.visible = true

	var target_norm := Vector2(0.5, 0.5)
	var zone_name := ""

	match cur_lvl:
		5:
			target_norm = Vector2(0.54, 0.70)
			zone_name = "📍 [จุด 24] หน้าประตูโรงเรียน"
		6:
			target_norm = Vector2(0.38, 0.40)
			zone_name = "📍 [อาคาร 4/5] ห้องเรียน"
		7:
			var players = get_tree().get_nodes_in_group("players")
			var px := 400.0
			if not players.is_empty():
				px = players[0].global_position.x
			if px > 850.0:
				target_norm = Vector2(0.38, 0.28)
				zone_name = "📍 [อาคาร 20] ห้องเก็บพัสดุ"
			else:
				target_norm = Vector2(0.24, 0.20)
				zone_name = "📍 [อาคาร 13] โรงอาหาร"
		8:
			var players = get_tree().get_nodes_in_group("players")
			var px := 300.0
			if not players.is_empty():
				px = players[0].global_position.x
			
			if px < 480.0:
				target_norm = Vector2(0.58, 0.32)
				zone_name = "📍 [จุด 22] ศาล ปู่-ย่า"
			elif px < 880.0:
				target_norm = Vector2(0.26, 0.44)
				zone_name = "📍 [อาคาร 4] ห้องสมุด"
			elif px < 1250.0:
				target_norm = Vector2(0.30, 0.30)
				zone_name = "📍 [จุด 23] สนามเด็กเล่น"
			elif px < 1580.0:
				target_norm = Vector2(0.60, 0.48)
				zone_name = "📍 [อาคาร 14] ห้องพยาบาล"
			elif px < 1860.0:
				target_norm = Vector2(0.58, 0.28)
				zone_name = "📍 [อาคาร 18] ร้านค้าสหกรณ์"
			elif px < 2050.0:
				target_norm = Vector2(0.23, 0.62)
				zone_name = "📍 [จุด 17] แปลงดอกไม้"
			else:
				target_norm = Vector2(0.54, 0.70)
				zone_name = "📍 [จุด 24] ประตูโรงเรียน"

	zone_label.text = zone_name
	
	# Smooth marker interpolation
	var target_px := target_norm * map_size
	marker.position = marker.position.lerp(target_px, 0.15)
