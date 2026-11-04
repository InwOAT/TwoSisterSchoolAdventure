extends BaseLevel

@onready var portal_home: MaplePortal = $PortalHome
@onready var portal_bus: MaplePortal = $PortalBus

# Zone NPCs and Interactive areas
@onready var cat_spot: Node2D = $Zones/LostCatSpot

var near_police: bool = false
var near_cat: bool = false
var near_market: bool = false
var near_shop: bool = false
var near_auntie: bool = false
var near_doctor: bool = false
var near_temple: bool = false
var near_post: bool = false

var badge_police: Label = null
var badge_cat: Label = null
var badge_market: Label = null
var badge_shop: Label = null
var badge_doctor: Label = null
var badge_temple: Label = null
var badge_post: Label = null

func _ready() -> void:
	level_number = 2
	super._ready()

	# Start village quest entries in good deeds diary
	GameManager.start_good_deed("q_village_police")
	GameManager.start_good_deed("q_village_market")
	GameManager.start_good_deed("q_auntie_errand")
	GameManager.start_good_deed("q_village_doctor")
	GameManager.start_good_deed("q_village_temple")
	GameManager.start_good_deed("q_village_post")

	if portal_home:
		portal_home.target_level = 1
		portal_home.target_spawn_x = 1150.0

	if portal_bus:
		portal_bus.target_scene_path = "res://scenes/levels/level_2_bus_stop.tscn"
		portal_bus.target_level = 25
		portal_bus.target_spawn_x = 100.0
		portal_bus.portal_name = "ศาลาป้ายรอขึ้นรถเมล์"
		_check_bus_ready()

	# Connect zone area triggers
	$Zones/PoliceArea.body_entered.connect(func(b): if b.is_in_group("players"): near_police = true; $Zones/PoliceArea/PromptLabel.visible = true)
	$Zones/PoliceArea.body_exited.connect(func(b): if b.is_in_group("players"): near_police = false; $Zones/PoliceArea/PromptLabel.visible = false)

	$Zones/LostCatArea.body_entered.connect(func(b): if b.is_in_group("players"): near_cat = true; $Zones/LostCatArea/PromptLabel.visible = true)
	$Zones/LostCatArea.body_exited.connect(func(b): if b.is_in_group("players"): near_cat = false; $Zones/LostCatArea/PromptLabel.visible = false)

	$Zones/MarketArea.body_entered.connect(func(b): if b.is_in_group("players"): near_market = true; $Zones/MarketArea/PromptLabel.visible = true)
	$Zones/MarketArea.body_exited.connect(func(b): if b.is_in_group("players"): near_market = false; $Zones/MarketArea/PromptLabel.visible = false)

	$Zones/UncleSitArea.body_entered.connect(func(b): if b.is_in_group("players"): near_shop = true; $Zones/UncleSitArea/PromptLabel.visible = true)
	$Zones/UncleSitArea.body_exited.connect(func(b): if b.is_in_group("players"): near_shop = false; $Zones/UncleSitArea/PromptLabel.visible = false)

	$Zones/AuntieArea.body_entered.connect(func(b): if b.is_in_group("players"): near_auntie = true; $Zones/AuntieArea/PromptLabel.visible = true)
	$Zones/AuntieArea.body_exited.connect(func(b): if b.is_in_group("players"): near_auntie = false; $Zones/AuntieArea/PromptLabel.visible = false)

	$Zones/DoctorArea.body_entered.connect(func(b): if b.is_in_group("players"): near_doctor = true; $Zones/DoctorArea/PromptLabel.visible = true)
	$Zones/DoctorArea.body_exited.connect(func(b): if b.is_in_group("players"): near_doctor = false; $Zones/DoctorArea/PromptLabel.visible = false)

	$Zones/TempleArea.body_entered.connect(func(b): if b.is_in_group("players"): near_temple = true; $Zones/TempleArea/PromptLabel.visible = true)
	$Zones/TempleArea.body_exited.connect(func(b): if b.is_in_group("players"): near_temple = false; $Zones/TempleArea/PromptLabel.visible = false)

	$Zones/PostArea.body_entered.connect(func(b): if b.is_in_group("players"): near_post = true; $Zones/PostArea/PromptLabel.visible = true)
	$Zones/PostArea.body_exited.connect(func(b): if b.is_in_group("players"): near_post = false; $Zones/PostArea/PromptLabel.visible = false)

	if GameManager.village_cat_found or GameManager.village_cat_returned:
		if cat_spot: cat_spot.visible = false

	_setup_village_quest_badges()
	_update_village_badges()

func _setup_village_quest_badges() -> void:
	badge_police = _create_zone_badge($Zones/PoliceArea, Vector2(0, -162))
	badge_market = _create_zone_badge($Zones/MarketArea, Vector2(0, -162))
	badge_cat = _create_zone_badge($Zones/LostCatSpot, Vector2(0, -56))
	badge_shop = _create_zone_badge($Zones/UncleSitArea, Vector2(0, -162))
	badge_doctor = _create_zone_badge($Zones/DoctorArea, Vector2(0, -162))
	badge_temple = _create_zone_badge($Zones/TempleArea, Vector2(0, -162))
	badge_post = _create_zone_badge($Zones/PostArea, Vector2(0, -162))

func _create_zone_badge(parent_node: Node, pos: Vector2) -> Label:
	if not parent_node:
		return null
	var existing := parent_node.get_node_or_null("QuestBadge") as Label
	if existing:
		return existing
	var lbl := Label.new()
	lbl.name = "QuestBadge"
	lbl.offset_left = pos.x - 90.0
	lbl.offset_right = pos.x + 90.0
	lbl.offset_top = pos.y - 11.0
	lbl.offset_bottom = pos.y + 11.0
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 11)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.10, 0.08, 0.03, 0.90)
	sb.border_color = Color(1.0, 0.85, 0.25, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	lbl.add_theme_stylebox_override("normal", sb)
	parent_node.add_child(lbl)
	return lbl

func _update_village_badges() -> void:
	var badge_auntie: Label = $Zones/AuntieArea/QuestBadge if has_node("Zones/AuntieArea/QuestBadge") else null
	if badge_auntie:
		if GameManager.auntie_errand_done:
			badge_auntie.visible = true
			badge_auntie.text = "✅ ช่วยซื้อของเรียบร้อย"
			badge_auntie.modulate = Color(0.35, 1.0, 0.5)
		elif GameManager.has_item("ไข่ไก่และนมถั่วเหลือง") or GameManager.has_item("ไข่ไก่สดและนมถั่วเหลือง") or GameManager.shop_groceries_bought:
			badge_auntie.visible = true
			badge_auntie.text = "💡 นำของมาส่งป้าสมศรี [!]"
			badge_auntie.modulate = Color(0.4, 1.0, 0.4, 1.0)
		else:
			badge_auntie.visible = true
			badge_auntie.text = "💡 เควสช่วยซื้อของ [!]"
			badge_auntie.modulate = Color(1.0, 0.9, 0.3, 1.0)

	if badge_shop:
		if GameManager.auntie_errand_done:
			badge_shop.text = "✅ ซื้อของส่งป้าสมศรีแล้ว"
			badge_shop.modulate = Color(0.35, 1.0, 0.5)
		elif GameManager.has_item("ไข่ไก่และนมถั่วเหลือง") or GameManager.has_item("ไข่ไก่สดและนมถั่วเหลือง") or GameManager.shop_groceries_bought:
			badge_shop.text = "✅ ได้ของครบแล้ว (นำไปส่งป้า)"
			badge_shop.modulate = Color(0.4, 1.0, 0.55)
		else:
			badge_shop.text = "💡 ซื้อไข่ไก่ & นมถั่วเหลือง [!]"
			badge_shop.modulate = Color(1.0, 0.9, 0.3)

	if badge_police:
		if GameManager.village_cat_returned or GameManager.police_safety_done:
			badge_police.text = "✅ ส่งคืนแมวหลง & วินัยจราจร"
			badge_police.modulate = Color(0.35, 1.0, 0.5)
		elif GameManager.has_item("ลูกแมวเจ้าส้ม"):
			badge_police.text = "💡 นำลูกแมวมาคืนคุณตำรวจ [!]"
			badge_police.modulate = Color(0.4, 1.0, 0.55)
		else:
			badge_police.text = "💡 เควสตามหาแมวหลง [!]"
			badge_police.modulate = Color(1.0, 0.9, 0.3)

	if badge_cat:
		badge_cat.visible = not (GameManager.village_cat_found or GameManager.village_cat_returned)
		badge_cat.text = "💡 อุ้มลูกแมวหลง [!]"
		badge_cat.modulate = Color(1.0, 0.85, 0.3)

	if badge_market:
		if GameManager.village_veggies_bought:
			badge_market.text = "✅ ซื้อผักสดปลอดสารพิษแล้ว"
			badge_market.modulate = Color(0.35, 1.0, 0.5)
		else:
			badge_market.text = "💡 เควสจ่ายตลาดซื้อผักสด [!]"
			badge_market.modulate = Color(1.0, 0.9, 0.3)

	if badge_doctor:
		if GameManager.village_doctor_visited or GameManager.doctor_eyedrops_received:
			badge_doctor.text = "✅ รับยาวิตามินให้คุณยายแล้ว"
			badge_doctor.modulate = Color(0.35, 1.0, 0.5)
		else:
			badge_doctor.text = "💡 เควสรับยาให้คุณยาย [!]"
			badge_doctor.modulate = Color(1.0, 0.9, 0.3)

	if badge_temple:
		if GameManager.village_temple_cleaned or GameManager.temple_hall_swept:
			badge_temple.text = "✅ ไหว้พระ & กวาดลานวัดแล้ว"
			badge_temple.modulate = Color(0.35, 1.0, 0.5)
		else:
			badge_temple.text = "💡 เควสไหว้พระ & กวาดวัด [!]"
			badge_temple.modulate = Color(1.0, 0.9, 0.3)

	if badge_post:
		if GameManager.village_letter_sent:
			badge_post.text = "✅ ส่งจดหมายให้คุณยายแล้ว"
			badge_post.modulate = Color(0.35, 1.0, 0.5)
		else:
			badge_post.text = "💡 เควสหยอดตู้ส่งจดหมาย [!]"
			badge_post.modulate = Color(1.0, 0.9, 0.3)

func _process(delta: float) -> void:
	super._process(delta)
	_check_bus_ready()
	_update_village_badges()

	# Clamp camera inside the wide village level boundaries (0 - 4200)
	if camera and p1 and p2:
		var mid_x := (p1.global_position.x + p2.global_position.x) * 0.5
		camera.global_position.x = clamp(mid_x, 640.0, 3560.0)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	if not interact_pressed:
		return

	if near_police:
		_interact_police()
	elif near_cat:
		_interact_cat()
	elif near_market:
		_interact_market()
	elif near_shop:
		_interact_shop()
	elif near_auntie:
		_interact_auntie()
	elif near_doctor:
		_interact_doctor()
	elif near_temple:
		_interact_temple()
	elif near_post:
		_interact_post()

func _interact_police() -> void:
	if GameManager.has_item("ลูกแมวเจ้าส้ม") and not GameManager.village_cat_returned:
		GameManager.remove_item("ลูกแมวเจ้าส้ม")
		GameManager.village_cat_returned = true
		GameManager.complete_good_deed("q_village_police")
		GameManager.dialog_triggered.emit("ร.ต.อ. สมชาย (ป้อมตำรวจ)", "โอ้โห! ขอบใจหนูๆ มากนะจ๊ะที่ช่วยพา 'เจ้าส้ม' แมวของคุณยายกลับมาได้อย่างปลอดภัย! ตำรวจดอนโมงขอมอบดาวมารยาทดีและยกย่องให้เป็นพลเมืองดีตัวอย่างเลยจ้ะ! 👮 ⭐", "")
	elif not GameManager.village_cat_returned:
		GameManager.village_police_visited = true
		GameManager.dialog_triggered.emit("ร.ต.อ. สมชาย (ป้อมตำรวจ)", "สวัสดีจ้ะเด็กๆ! ตำรวจดอนโมงยินดีรับใช้ มีคุณยายมาแจ้งว่าลูกแมวน้อยสีส้มชื่อ 'เจ้าส้ม' หลงทางไปแถวตลาดคลองถม ถ้าเจอช่วยอุ้มมาคืนทีนะ! และก่อนข้ามถนนมลิวรรณ อย่าลืมมองซ้ายมองขวาและข้ามทางม้าลายเสมอนะจ๊ะ! 🚦", "")
	else:
		GameManager.dialog_triggered.emit("ร.ต.อ. สมชาย (ป้อมตำรวจ)", "ปลอดภัยไว้ก่อนนะเด็กๆ ข้ามถนนทางม้าลายอย่างมีสตินะจ๊ะ! 👮", "")

func _interact_cat() -> void:
	if not GameManager.village_cat_found and not GameManager.village_cat_returned:
		GameManager.village_cat_found = true
		GameManager.add_item("ลูกแมวเจ้าส้ม")
		if cat_spot: cat_spot.visible = false
		GameManager.dialog_triggered.emit("ลูกแมวเจ้าส้ม", "เหมียว... เหมียว... 🐱 (น้องปีใหม่และพี่ของขวัญช่วยอุ้มลูกแมวน้อยเจ้าส้มใส่ตะกร้าอย่างทะนุถนอม รีบนำไปส่งคุณตำรวจที่ป้อมเทศบาลหน้าหมู่บ้านนะ!)", "")
	elif GameManager.has_item("ลูกแมวเจ้าส้ม"):
		GameManager.dialog_triggered.emit("ลูกแมวเจ้าส้ม", "เหมียวๆ รีบพาเจ้าส้มไปหาคุณตำรวจที่ป้อมทางซ้ายมือเถอะ! 🐱", "")
	else:
		GameManager.dialog_triggered.emit("ตลาดคลองถม", "บริเวณแผงขายผลไม้ตลาดคลองถม สะอาดเป็นระเบียบ", "")

func _interact_market() -> void:
	if not GameManager.village_veggies_bought:
		GameManager.village_veggies_bought = true
		GameManager.add_item("ผักกาดขาวและแตงกวา")
		GameManager.complete_good_deed("q_village_market")
		GameManager.dialog_triggered.emit("ป้าบุญมี (ตลาดนัดคลองถม)", "สวัสดีจ้าหลานๆ! มาช่วยคุณแม่จ่ายตลาดใช่ไหมจ๊ะ? ป้าจัด 'ผักกาดขาวสดและแตงกวาปลอดสารพิษ' ให้เต็มถุงเลย 20 บาทพอดีจ้ะ ได้ทั้งของสดและแต้มความดีนะเด็กดี! 🥦 ⭐", "")
	else:
		GameManager.dialog_triggered.emit("ป้าบุญมี (ตลาดนัดคลองถม)", "ตลาดนัดคลองถมดอนโมงมีผักสด ผลไม้ และของอร่อยมากมายจ้า! 🥬", "")

func _interact_shop() -> void:
	var q_status: String = GameManager.good_deeds.get("q_auntie_errand", {}).get("status", "")
	if q_status == "in_progress" and not GameManager.has_item("ไข่ไก่และนมถั่วเหลือง"):
		GameManager.add_item("ไข่ไก่และนมถั่วเหลือง")
		GameManager.dialog_triggered.emit("ลุงสิทธิ์ (ร้านชำ & Lotus's)", "สวัสดีจ้ะหลานๆ! มาซื้อของให้ป้าสมศรีใช่ไหม? นี่จ้ะ 'ไข่ไก่สดและนมถั่วเหลือง' 15 บาท ลุงทอนเงินให้ 5 บาทด้วยนะ นำไปให้ป้าสมศรีที่ศาลาพักใจได้เลย!", "")
	elif GameManager.has_item("ไข่ไก่และนมถั่วเหลือง"):
		GameManager.dialog_triggered.emit("ลุงสิทธิ์ (ร้านชำ & Lotus's)", "ได้ของครบแล้ว รีบนำไปส่งให้ป้าสมศรีที่นั่งพักรออยู่ที่ศาลาพักใจนะจ๊ะ!", "")
	else:
		GameManager.dialog_triggered.emit("ลุงสิทธิ์ (ร้านชำ & Lotus's)", "สวัสดีจ้าของขวัญและปีใหม่! ร้านลุงสิทธิ์และ Lotus's Go Fresh ดอนโมง มีของสด ขนม และเครื่องดื่มคุณภาพดีมากมายจ้า!", "")

func _interact_auntie() -> void:
	var has_eggs = GameManager.has_item("ไข่ไก่และนมถั่วเหลือง") or GameManager.has_item("ไข่ไก่สดและนมถั่วเหลือง") or GameManager.shop_groceries_bought
	if has_eggs and not GameManager.auntie_errand_done:
		GameManager.remove_item("ไข่ไก่และนมถั่วเหลือง")
		GameManager.remove_item("ไข่ไก่สดและนมถั่วเหลือง")
		GameManager.auntie_errand_done = true
		GameManager.complete_good_deed("q_auntie_errand")
		GameManager.money_baht += 5
		if AudioManager:
			AudioManager.play_sfx("coin")
		GameManager.auntie_talked = true
		GameManager.dialog_triggered.emit("คุณป้าสมศรี", "ขอบใจหนูทั้งสองคนมากเลยนะจ๊ะ! ซื้อของได้ถูกต้องแถมนำเงินทอน 5 บาทมาคืนครบถ้วน ป้าขอยกเงินทอน 5 บาทนี้ให้เป็นรางวัลคนดีมีน้ำใจจ้ะ! 🪙\n(อ้อ แล้วเย็นนี้ฝนจะตกนะลูก ลืมบัตรนักเรียนกับร่มไว้ที่บ้านหรือเปล่าจ๊ะ?)", "")
	elif not GameManager.auntie_errand_done:
		GameManager.start_good_deed("q_auntie_errand")
		GameManager.dialog_triggered.emit("คุณป้าสมศรี", "สวัสดีจ้ะเด็กๆ วันนี้ป้าเจ็บขา มานั่งพักที่ศาลาพักใจ อยากได้ 'ไข่ไก่สดและนมถั่วเหลือง' จากร้านชำลุงสิทธิ์ ช่วยป้าเดินไปซื้อให้หน่อยนะลูก ป้าให้เงินไว้ 20 บาทจ้ะ!", "")
	else:
		if not GameManager.has_item("บัตรนักเรียน") or not GameManager.has_item("ร่ม"):
			GameManager.dialog_triggered.emit("คุณป้าสมศรี", "เย็นนี้ฝนจะตกนะลูก! รีบเดินย้อนเข้าเสาวาปซ้ายสุดกลับไปเอาบัตรนักเรียนกับร่มที่บ้านก่อนนะจ๊ะ!", "")
		else:
			GameManager.dialog_triggered.emit("คุณป้าสมศรี", "เตรียมตัวพร้อมแล้ว! เดินไปที่ [ศาลาป้ายรอขึ้นรถเมล์] ทางขวาสุดได้เลยจ้ะเด็กๆ!", "")

func _interact_doctor() -> void:
	if not GameManager.village_doctor_visited:
		GameManager.village_doctor_visited = true
		GameManager.add_item("ยาวิตามินและยาหยอดตา")
		GameManager.complete_good_deed("q_village_doctor")
		GameManager.dialog_triggered.emit("คุณหมอประวิทย์ (คลินิกดอนโมง)", "สวัสดีจ้ะของขวัญและปีใหม่! มารับยาวิตามินบำรุงและยาหยอดตาให้คุณยายใช่ไหม? นี่จ้ะหมอจัดยาให้เรียบร้อยแล้ว อย่าลืมเตือนคุณยายให้ดื่มน้ำมากๆ ทานอาหารปรุงสุกสะอาด และพักผ่อนให้เพียงพอนะจ๊ะ! 🩺 ⭐", "")
	else:
		GameManager.dialog_triggered.emit("คุณหมอประวิทย์ (คลินิกดอนโมง)", "คลินิกหมอชุมชนดอนโมงยินดีดูแลสุขภาพและให้คำปรึกษากับทุกคนในหมู่บ้านจ้ะ! 💊", "")

func _interact_temple() -> void:
	if not GameManager.village_temple_cleaned:
		GameManager.village_temple_cleaned = true
		GameManager.complete_good_deed("q_village_temple")
		GameManager.dialog_triggered.emit("หลวงตาบุญชื่น (วัดมงคลนิมิต)", "เจริญพรโยมหนูทั้งสอง การมีจิตอาสาช่วยเหลือกวาดลานวัดและมีกิริยาอ่อนน้อมถ่อมตน เป็นบุญกุศลอันบริสุทธิ์ ขอให้เรียนหนังสือเก่งๆ สุขภาพแข็งแรงนะจ๊ะ 🙏 ⭐", "")
	else:
		GameManager.dialog_triggered.emit("หลวงตาบุญชื่น (วัดมงคลนิมิต)", "วัดมงคลนิมิตสะอาดร่มรื่น สบายใจจริงหนอโยม 🙏", "")

func _interact_post() -> void:
	if not GameManager.village_letter_sent:
		GameManager.village_letter_sent = true
		GameManager.complete_good_deed("q_village_post")
		GameManager.dialog_triggered.emit("พี่สมศักดิ์ (ไปรษณีย์ไทย ดอนโมง)", "หยอดจดหมายสำคัญลงตู้ไปรษณีย์สีแดงเรียบร้อยแล้วจ้ะ! พี่จะรีบส่งต่อให้ถึงปลายทางอย่างรวดเร็วและปลอดภัย ขอบใจหนูๆ มากนะจ๊ะ! 📮 ⭐", "")
	else:
		GameManager.dialog_triggered.emit("พี่สมศักดิ์ (ไปรษณีย์ไทย ดอนโมง)", "ไปรษณีย์ไทย สาขาดอนโมง ยินดีเชื่อมต่อทุกความผูกพัน ส่งถึงทุกที่ทั่วไทยจ้า! 📬", "")

func _check_bus_ready() -> void:
	if not portal_bus:
		return
	
	if GameManager.has_item("บัตรนักเรียน") and GameManager.has_item("ร่ม"):
		portal_bus.is_locked = false
	else:
		portal_bus.is_locked = true
		if not GameManager.auntie_errand_done:
			portal_bus.lock_message = "คุยกับคุณป้าสมศรีที่ศาลาพักใจก่อนนะจ๊ะ! (กด [M] ดูแผนที่หมู่บ้าน)"
		else:
			portal_bus.lock_message = "ลืมบัตรนักเรียนกับร่มไว้ที่บ้าน! เดินเข้าเสาวาปซ้ายสุดย้อนกลับไปเอาที่ [ฉากที่ 1 ในบ้าน] ก่อนนะ!"
