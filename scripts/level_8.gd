extends BaseLevel

@onready var portal_canteen: MaplePortal = $PortalBackCanteen
@onready var portal_return_bus: MaplePortal = $PortalReturnBus
@onready var portal_shrine: MaplePortal = get_node_or_null("PortalShrine")
@onready var portal_library: MaplePortal = get_node_or_null("PortalLibrary")
@onready var portal_infirmary: MaplePortal = get_node_or_null("PortalInfirmary")
@onready var portal_coop: MaplePortal = get_node_or_null("PortalCoop")
@onready var portal_flower: MaplePortal = get_node_or_null("PortalFlower")

# Quest Areas in Nong Ruea Community School
@onready var shrine_area: Area2D = $Zones/ShrineArea
@onready var library_area: Area2D = $Zones/LibraryArea
@onready var playground_area: Area2D = $Zones/PlaygroundArea
@onready var infirmary_area: Area2D = $Zones/InfirmaryArea
@onready var coop_area: Area2D = $Zones/CoopArea
@onready var flower_area: Area2D = $Zones/FlowerArea
@onready var flower_sprite: Sprite2D = $Zones/FlowerArea/FlowerSprite

var near_shrine: bool = false
var near_library: bool = false
var near_playground: bool = false
var near_infirmary: bool = false
var near_coop: bool = false
var near_flower: bool = false

func _ready() -> void:
	level_number = 8
	super._ready()

	if portal_canteen:
		portal_canteen.target_level = 7
		portal_canteen.target_spawn_x = 1100.0

	if portal_return_bus:
		portal_return_bus.target_level = 9
		portal_return_bus.target_spawn_x = 100.0
		_update_portal()

	if portal_shrine:
		portal_shrine.target_scene_path = "res://scenes/interiors/interior_school_shrine.tscn"
		portal_shrine.target_level = 804
		portal_shrine.target_spawn_x = 200.0
		portal_shrine.portal_name = "ศาลปู่-ย่า ประจำโรงเรียน [จุด 22]"
		portal_shrine.is_building_door = true

	if portal_library:
		portal_library.target_scene_path = "res://scenes/interiors/interior_school_library.tscn"
		portal_library.target_level = 801
		portal_library.target_spawn_x = 200.0
		portal_library.portal_name = "ห้องสมุดโรงเรียน [อาคาร 4]"
		portal_library.is_building_door = true

	if portal_infirmary:
		portal_infirmary.target_scene_path = "res://scenes/interiors/interior_school_infirmary.tscn"
		portal_infirmary.target_level = 802
		portal_infirmary.target_spawn_x = 200.0
		portal_infirmary.portal_name = "ห้องพยาบาล [อาคาร 14]"
		portal_infirmary.is_building_door = true

	if portal_coop:
		portal_coop.target_scene_path = "res://scenes/interiors/interior_school_coop.tscn"
		portal_coop.target_level = 803
		portal_coop.target_spawn_x = 200.0
		portal_coop.portal_name = "ร้านค้าสหกรณ์ [อาคาร 18]"
		portal_coop.is_building_door = true

	if portal_flower:
		portal_flower.target_scene_path = "res://scenes/interiors/interior_school_garden.tscn"
		portal_flower.target_level = 805
		portal_flower.target_spawn_x = 200.0
		portal_flower.portal_name = "แปลงเกษตรพฤกษศาสตร์ [จุด 17]"
		portal_flower.is_building_door = true

	# Connect area triggers
	if shrine_area:
		shrine_area.body_entered.connect(func(b): if b.is_in_group("players"): near_shrine = true; $Zones/ShrineArea/PromptLabel.visible = true)
		shrine_area.body_exited.connect(func(b): if b.is_in_group("players"): near_shrine = false; $Zones/ShrineArea/PromptLabel.visible = false)

	if library_area:
		library_area.body_entered.connect(func(b): if b.is_in_group("players"): near_library = true; $Zones/LibraryArea/PromptLabel.visible = true)
		library_area.body_exited.connect(func(b): if b.is_in_group("players"): near_library = false; $Zones/LibraryArea/PromptLabel.visible = false)

	if playground_area:
		playground_area.body_entered.connect(func(b): if b.is_in_group("players"): near_playground = true; $Zones/PlaygroundArea/PromptLabel.visible = true)
		playground_area.body_exited.connect(func(b): if b.is_in_group("players"): near_playground = false; $Zones/PlaygroundArea/PromptLabel.visible = false)

	if infirmary_area:
		infirmary_area.body_entered.connect(func(b): if b.is_in_group("players"): near_infirmary = true; $Zones/InfirmaryArea/PromptLabel.visible = true)
		infirmary_area.body_exited.connect(func(b): if b.is_in_group("players"): near_infirmary = false; $Zones/InfirmaryArea/PromptLabel.visible = false)

	if coop_area:
		coop_area.body_entered.connect(func(b): if b.is_in_group("players"): near_coop = true; $Zones/CoopArea/PromptLabel.visible = true)
		coop_area.body_exited.connect(func(b): if b.is_in_group("players"): near_coop = false; $Zones/CoopArea/PromptLabel.visible = false)

	if flower_area:
		flower_area.body_entered.connect(func(b): if b.is_in_group("players"): near_flower = true; $Zones/FlowerArea/PromptLabel.visible = true)
		flower_area.body_exited.connect(func(b): if b.is_in_group("players"): near_flower = false; $Zones/FlowerArea/PromptLabel.visible = false)

	if flower_sprite and GameManager.flowers_bloomed:
		flower_sprite.modulate = Color(1.3, 1.3, 1.2)

func _get_level_width() -> float:
	return 2220.0

func _process(delta: float) -> void:
	super._process(delta)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	if near_shrine and interact_pressed:
		_interact_shrine()
	elif near_library and interact_pressed:
		_interact_library()
	elif near_playground and interact_pressed:
		_interact_playground()
	elif near_infirmary and interact_pressed:
		_interact_infirmary()
	elif near_coop and interact_pressed:
		_interact_coop()
	elif near_flower and interact_pressed:
		_interact_flower()

func _interact_shrine() -> void:
	if not GameManager.grandpa_shrine_paid:
		GameManager.grandpa_shrine_paid = true
		GameManager.add_star()
		GameManager.dialog_triggered.emit(
			"ศาลปู่-ย่า ประจำโรงเรียนชุมชนหนองเรือ [จุด 22]",
			"🙏 สองพี่น้องยกมือไหว้สิ่งศักดิ์สิทธิ์ประจำโรงเรียน ขอพรให้มีสติปัญญาและเรียนหนังสืออย่างมีความสุข! ⭐ ได้รับดาวมารยาท + 10 แต้มความดี!\n(สามารถกด [↑] หรือเดินเข้าวงกลมประตูเพื่อเข้าไปไหว้ที่โต๊ะบูชาด้านในได้ด้วยนะจ๊ะ)",
			""
		)
	else:
		GameManager.dialog_triggered.emit(
			"ศาลปู่-ย่า ประจำโรงเรียนชุมชนหนองเรือ [จุด 22]",
			"🙏 สองพี่น้องยกมือไหว้ขอพรเรียบร้อยแล้ว! สามารถกดเดินเข้าประตูเพื่อเข้าไปสักการะที่โต๊ะหมู่บูชาด้านในได้ตลอดเวลาจ้ะ ✨",
			""
		)

func _interact_library() -> void:
	GameManager.dialog_triggered.emit(
		"ห้องสมุดและศูนย์ดิจิทัล [อาคาร 4]",
		"📖 เดินเข้าวงกลมเรืองแสงที่ประตูห้องสมุดเพื่อเข้าไปจัดชั้นหนังสือและค้นคว้าตำราพฤกษศาสตร์ได้เลยจ้ะ! 📚",
		""
	)

func _interact_playground() -> void:
	if not GameManager.injured_student_helped:
		if GameManager.has_item("กล่องปฐมพยาบาล") or GameManager.infirmary_firstaid_done:
			GameManager.injured_student_helped = true
			GameManager.remove_item("กล่องปฐมพยาบาล")
			GameManager.complete_good_deed("q_first_aid_friend")
			GameManager.add_star()
			GameManager.add_star()
			GameManager.dialog_triggered.emit(
				"สนามเด็กเล่น [จุด 23]",
				"🩹 สองพี่น้องนำกล่องยามาทำแผลให้น้องอนุบาลอย่างอ่อนโยน น้องหยุดร้องไห้และยิ้มอย่างมีความสุข! น้องมอบ 'คูปองสหกรณ์ 10 บาท' ให้เป็นสินน้ำใจ! ⭐⭐",
				"res://assets/characters/npcs/npc_kindergarten.png"
			)
			if not GameManager.has_item("คูปองสหกรณ์ 10 บาท"):
				GameManager.add_item("คูปองสหกรณ์ 10 บาท")
		else:
			GameManager.start_good_deed("q_first_aid_friend")
			GameManager.dialog_triggered.emit(
				"น้องอนุบาล (น้องกานต์)",
				"ฮือๆ... หนูหกล้มหัวเข่าถลอกเจ็บจังเลย พี่ๆ ช่วยไปขอกล่องยาทำแผลที่ [อาคาร 14 ห้องพยาบาล] มาช่วยหนูหน่อยได้ไหมครับ... แงงง 😭",
				"res://assets/characters/npcs/npc_kindergarten.png"
			)
	else:
		GameManager.dialog_triggered.emit(
			"น้องอนุบาล (น้องกานต์)",
			"ขอบคุณพี่ของขวัญกับพี่ปีใหม่มากครับ! หนูหายเจ็บแล้ว นำคูปองไปซื้อของที่ร้านสหกรณ์ [อาคาร 18] ได้เลยนะครับ! 😄",
			"res://assets/characters/npcs/npc_kindergarten.png"
		)

func _interact_infirmary() -> void:
	GameManager.dialog_triggered.emit(
		"ห้องพยาบาล [อาคาร 14]",
		"🏥 เดินเข้าวงกลมเรืองแสงที่ประตูห้องพยาบาลเพื่อเข้าไปชั่งน้ำหนัก วัดส่วนสูง และรับกล่องปฐมพยาบาลได้เลยจ้ะ!",
		""
	)

func _interact_coop() -> void:
	GameManager.dialog_triggered.emit(
		"ร้านค้าสหกรณ์ [อาคาร 18]",
		"🏪 เดินเข้าวงกลมเรืองแสงที่ประตูร้านสหกรณ์เพื่อนำคูปองไปซื้อปุ๋ยอินทรีย์บำรุงแปลงดอกไม้ได้เลยจ้ะ!",
		""
	)

func _interact_flower() -> void:
	if GameManager.flowers_bloomed:
		GameManager.dialog_triggered.emit(
			"แปลงเกษตรพฤกษศาสตร์ [ริมสระน้ำ 17]",
			"🌸 ดอกไม้ในแปลงบานสะพรั่งสีสันสดใส ส่งกลิ่นหอมชื่นใจไปทั่วโรงเรียน! สองพี่น้องสามารถเดินเข้าประตูเพื่อเข้าไปชื่นชมในเรือนเพาะชำได้เลยจ้ะ! 🌸✨",
			""
		)
		return

	var has_can = GameManager.has_item("บัวรดน้ำ")
	var has_book = GameManager.has_item("ตำราพฤกษศาสตร์")
	var has_fert = GameManager.has_item("ปุ๋ยอินทรีย์")

	if has_can and has_book and has_fert:
		GameManager.flowers_fertilized = true
		GameManager.flowers_bloomed = true
		GameManager.complete_good_deed("q_flower_garden")
		GameManager.add_star()
		GameManager.add_star()
		if flower_sprite:
			flower_sprite.modulate = Color(1.3, 1.3, 1.2)
		GameManager.dialog_triggered.emit(
			"แปลงเกษตรพฤกษศาสตร์ [ริมสระน้ำ 17]",
			"🎉 สำเร็จแล้ว! สองพี่น้องเปิดตำราพฤกษศาสตร์ ใส่ปุ๋ยอินทรีย์ และใช้บัวรดน้ำรดจนทั่ว! ดอกไม้บานสะพรั่งงดงามตระการตา! ⭐⭐ ประตูโรงเรียน [จุด 24] เปิดแล้ว ได้เวลากลับบ้าน!",
			""
		)
		_update_portal()
	else:
		GameManager.dialog_triggered.emit(
			"แปลงเกษตรพฤกษศาสตร์ [ริมสระน้ำ 17]",
			"💡 เดินเข้าวงกลมเรืองแสงที่ประตู [จุด 17] เพื่อเข้าไปในเรือนเพาะชำและแปลงดอกไม้ จากนั้นหยิบบัวรดน้ำมารดน้ำแปลงดอกไม้ให้บานสะพรั่ง จึงจะผ่านด่านได้นะจ๊ะ! 💧🌸",
			""
		)

func _update_portal() -> void:
	if not portal_return_bus:
		return
	if GameManager.flowers_bloomed:
		portal_return_bus.is_locked = false
		if flower_sprite:
			flower_sprite.modulate = Color(1.3, 1.3, 1.2)
	else:
		portal_return_bus.is_locked = true
		portal_return_bus.lock_message = "ช่วยเข้าไปรดน้ำแปลงดอกไม้โรงเรียน [จุด 17] ให้บานสะพรั่งก่อนกลับบ้านนะจ๊ะ! (เดินเข้าแปลงดอกไม้ [จุด 17] เพื่อรดน้ำ) 🌸💧"
