extends BaseLevel

@onready var portal_garden: MaplePortal = $PortalGarden
@onready var portal_back: MaplePortal = $PortalBackClassroom

# Building 20 / Storage Room & Watering Can
@onready var item_watering_can: InteractableItem = get_node_or_null("Building20/ItemWateringCan")
@onready var door_panel: Panel = get_node_or_null("Building20/DoorPanel")
@onready var door_label: Label = get_node_or_null("Building20/DoorPanel/DoorLabel")
@onready var btn_peemai_crawl: Button = get_node_or_null("Building20/BtnPeemaiCrawl")

# UI Buttons (Mouse fallback)
@onready var btn_healthy: Button = get_node_or_null("LunchStallArea/BtnHealthy")
@onready var btn_junk: Button = get_node_or_null("LunchStallArea/BtnJunk")
@onready var btn_sort: Button = get_node_or_null("RecycleStation/BtnSort")

@onready var waste_sorting_modal: CanvasLayer = get_node_or_null("WasteSortingModal")

# In-World Interactive Zones
@onready var zone_lunch: Area2D = get_node_or_null("ZoneLunchStall")
@onready var zone_recycle: Area2D = get_node_or_null("ZoneRecycle")
@onready var zone_vent: Area2D = get_node_or_null("ZoneStorageVent")

# Floating Prompts
@onready var prompt_lunch: Label = get_node_or_null("ZoneLunchStall/PromptLabel")
@onready var prompt_recycle: Label = get_node_or_null("ZoneRecycle/PromptLabel")
@onready var prompt_vent: Label = get_node_or_null("ZoneStorageVent/PromptLabel")

# Quest Badges
@onready var badge_lunch: Label = get_node_or_null("ZoneLunchStall/QuestBadge")
@onready var badge_recycle: Label = get_node_or_null("ZoneRecycle/QuestBadge")
@onready var badge_vent: Label = get_node_or_null("ZoneStorageVent/QuestBadge")

# Vent Glowing Circle Marker
@onready var light_circle: Sprite2D = get_node_or_null("ZoneStorageVent/VentMarker/LightCircle")
@onready var vertical_beam: Sprite2D = get_node_or_null("ZoneStorageVent/VentMarker/VerticalBeam")

var near_lunch: bool = false
var near_recycle: bool = false
var near_vent: bool = false
var near_watering_can: bool = false

func _ready() -> void:
	level_number = 7
	super._ready()

	GameManager.start_good_deed("q_canteen_clean")

	if btn_healthy:
		btn_healthy.pressed.connect(buy_healthy_meal)
	if btn_junk:
		btn_junk.pressed.connect(buy_junk_food)
	if btn_sort:
		btn_sort.pressed.connect(sort_waste_bins)
	if waste_sorting_modal:
		waste_sorting_modal.sorting_completed.connect(_on_waste_sorting_completed)
	if btn_peemai_crawl:
		btn_peemai_crawl.pressed.connect(attempt_crawl_vent)

	if portal_back:
		portal_back.target_level = 6
		portal_back.target_spawn_x = 1100.0

	if portal_garden:
		portal_garden.target_level = 8
		portal_garden.target_spawn_x = 100.0
		_update_portal_state()

	# Storage room check for watering can (อาคาร 20)
	if item_watering_can:
		item_watering_can.visible = GameManager.storage_unlocked and not GameManager.has_item("บัวรดน้ำ")
		# Take manual control over pickup to enforce prerequisite quests!
		item_watering_can.set_process(false)
		item_watering_can.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_watering_can = true
				var p_lbl = item_watering_can.get_node_or_null("PromptLabel")
				if p_lbl:
					p_lbl.visible = true
		)
		item_watering_can.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_watering_can = false
				var p_lbl = item_watering_can.get_node_or_null("PromptLabel")
				if p_lbl:
					p_lbl.visible = false
		)

	# Wire up Area2D zones for in-world walk-up interactions
	if zone_lunch:
		zone_lunch.body_entered.connect(func(b): if b.is_in_group("players"): near_lunch = true; if prompt_lunch: prompt_lunch.visible = true)
		zone_lunch.body_exited.connect(func(b): if b.is_in_group("players"): near_lunch = false; if prompt_lunch: prompt_lunch.visible = false)

	if zone_recycle:
		zone_recycle.body_entered.connect(func(b): if b.is_in_group("players"): near_recycle = true; if prompt_recycle: prompt_recycle.visible = true)
		zone_recycle.body_exited.connect(func(b): if b.is_in_group("players"): near_recycle = false; if prompt_recycle: prompt_recycle.visible = false)

	if zone_vent:
		zone_vent.body_entered.connect(func(b): if b.is_in_group("players"): near_vent = true; if prompt_vent: prompt_vent.visible = true)
		zone_vent.body_exited.connect(func(b): if b.is_in_group("players"): near_vent = false; if prompt_vent: prompt_vent.visible = false)

	_update_badges()
	_update_door_visual()

	# Intro guidance upon entering Level 7
	if not GameManager.canteen_nutrition_ok:
		get_tree().create_timer(0.4).timeout.connect(func():
			GameManager.dialog_triggered.emit(
				"พี่ของขวัญ & น้องปีใหม่",
				"พักเที่ยงที่ [อาคาร 13 โรงอาหาร] แล้ว! พวกเราเดินไปเลือกซื้ออาหารกลางวัน 5 หมู่ที่เคาน์เตอร์ป้ามาลัย แล้วนำถาดไปคัดแยกขยะ 3 สีกันเถอะ! 🍱🥗",
				""
			)
		)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if near_lunch and not GameManager.canteen_nutrition_ok:
			if event.physical_keycode == KEY_1 or event.physical_keycode == KEY_A:
				buy_healthy_meal()
				get_viewport().set_input_as_handled()
			elif event.physical_keycode == KEY_2 or event.physical_keycode == KEY_B:
				buy_junk_food()
				get_viewport().set_input_as_handled()

func _get_level_width() -> float:
	return 1800.0

func _process(delta: float) -> void:
	super._process(delta)
	_update_portal_state()
	_update_badges()

	# Dynamic pulsing animation for vent glowing light circle and beam
	if light_circle:
		var pulse := 0.85 + sin(Time.get_ticks_msec() * 0.005) * 0.15
		light_circle.scale = Vector2(0.75 * pulse, 0.75 * pulse)
		if GameManager.storage_unlocked:
			light_circle.modulate = Color(0.18, 1.0, 0.85, 0.98) # เขียว-ฟ้าสดใส (Emerald Cyan)
		else:
			light_circle.modulate = Color(1.0, 0.55, 0.12, 0.95) # สีส้มอำพัน (Amber Orange)
	if vertical_beam:
		var beam_a := 0.65 + sin(Time.get_ticks_msec() * 0.004) * 0.25
		if GameManager.storage_unlocked:
			vertical_beam.modulate = Color(0.25, 1.0, 0.88, beam_a)
		else:
			vertical_beam.modulate = Color(1.0, 0.60, 0.18, beam_a)

	# Update watering can prompt dynamically based on quest status
	if is_instance_valid(item_watering_can) and item_watering_can.visible:
		var p_lbl = item_watering_can.get_node_or_null("PromptLabel")
		if p_lbl:
			if not (GameManager.canteen_nutrition_ok and GameManager.waste_sorted_ok):
				p_lbl.text = "🔒 ต้องทานอาหาร 5 หมู่ & คัดแยกขยะก่อน"
				p_lbl.modulate = Color(1.0, 0.45, 0.45)
			else:
				p_lbl.text = "[E / Shift] หยิบบัวรดน้ำ 🪴"
				p_lbl.modulate = Color(0.4, 1.0, 0.6)

	# Check in-world interaction key ([E], [Shift], gamepad button)
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_lunch:
			buy_healthy_meal()
		elif near_recycle:
			sort_waste_bins()
		elif near_watering_can:
			attempt_pickup_watering_can()
		elif near_vent:
			attempt_crawl_vent()

func _update_portal_state() -> void:
	if not portal_garden:
		return
	if GameManager.canteen_nutrition_ok and GameManager.waste_sorted_ok and GameManager.has_item("บัวรดน้ำ"):
		if portal_garden.is_locked:
			portal_garden.is_locked = false
			portal_garden.lock_message = ""
			portal_garden.portal_name = "ออกไปแปลงเกษตรและสวนโรงเรียน [เปิดแล้ว! ✨]"
	else:
		portal_garden.is_locked = true
		portal_garden.portal_name = "ออกไปแปลงเกษตรและสวนโรงเรียน [ประตูปิด]"
		if not GameManager.canteen_nutrition_ok:
			portal_garden.lock_message = "ต้องเลือกซื้ออาหารที่มีประโยชน์ครบ 5 หมู่ที่เคาน์เตอร์ป้ามาลัยก่อนนะจ๊ะ! 🍱"
		elif not GameManager.waste_sorted_ok:
			portal_garden.lock_message = "ทานอาหารเสร็จแล้ว ต้องนำถาดไปคืนและคัดแยกขยะ 3 สีลงถังให้เรียบร้อยก่อนนะจ๊ะ! ♻️"
		elif not GameManager.has_item("บัวรดน้ำ"):
			portal_garden.lock_message = "ต้องให้น้องปีใหม่มุดช่องลมไปเปิดห้องพัสดุ 20 และหยิบบัวรดน้ำก่อนนะจ๊ะ! 🪴"

func _update_badges() -> void:
	if badge_lunch:
		if GameManager.canteen_nutrition_ok:
			badge_lunch.text = "✅ ทานอาหาร 5 หมู่แล้ว"
			badge_lunch.modulate = Color(0.3, 1.0, 0.4)
			if prompt_lunch:
				prompt_lunch.text = "[E / Shift] คุยกับป้ามาลัย"
		else:
			badge_lunch.text = "💡 เควสอาหาร 5 หมู่ [!]"
			badge_lunch.modulate = Color(1.0, 0.9, 0.3)
			if prompt_lunch:
				prompt_lunch.text = "[E / Shift] ซื้ออาหารกลางวัน 5 หมู่ (35 ฿)"

	if badge_recycle:
		if GameManager.waste_sorted_ok:
			badge_recycle.text = "✅ คัดแยกขยะเรียบร้อย"
			badge_recycle.modulate = Color(0.3, 1.0, 0.4)
			if prompt_recycle:
				prompt_recycle.text = "[E / Shift] ตรวจดูถังขยะ 3 สี"
		else:
			badge_recycle.text = "💡 เควสคัดแยกขยะ [!]"
			badge_recycle.modulate = Color(1.0, 0.9, 0.3)
			if prompt_recycle:
				prompt_recycle.text = "[E / Shift] คัดแยกขยะ 3 สี & ส่งถาดอาหาร"

	if badge_vent:
		if GameManager.storage_unlocked:
			badge_vent.text = "✅ ห้องพัสดุ 20 ปลดล็อกแล้ว"
			badge_vent.modulate = Color(0.3, 1.0, 0.4)
			if prompt_vent:
				prompt_vent.text = "ห้องเก็บพัสดุเปิดแล้วจ้า"
		else:
			if GameManager.active_player_solo == 0:
				badge_vent.text = "💡 สลับเป็นปีใหม่ [Tab] เพื่อมุดช่องลม"
				badge_vent.modulate = Color(1.0, 0.85, 0.3)
				if prompt_vent:
					prompt_vent.text = "[Tab] สลับเป็นน้องปีใหม่ (P2) เพื่อมุดช่องลม"
			else:
				badge_vent.text = "🌟 น้องปีใหม่พร้อมมุดช่องลม!"
				badge_vent.modulate = Color(0.4, 0.95, 1.0)
				if prompt_vent:
					prompt_vent.text = "[E / Shift] ให้น้องปีใหม่มุดช่องลมเข้าห้อง 20 💨"

func _update_door_visual() -> void:
	if not door_label:
		return
	if GameManager.storage_unlocked:
		door_label.text = "🚪 ประตูพัสดุ\n[🔓 เปิดแล้ว]"
		door_label.modulate = Color(0.4, 1.0, 0.6)
	else:
		door_label.text = "🚪 ประตูพัสดุ\n[🔒 ล็อก]"
		door_label.modulate = Color(1.0, 0.85, 0.4)

func buy_healthy_meal() -> void:
	if not GameManager.canteen_nutrition_ok:
		var price := 35
		if GameManager.money_baht >= price:
			GameManager.money_baht -= price
		GameManager.canteen_nutrition_ok = true
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("coin")
			AudioManager.play_sfx("sister_cheer")
		GameManager.dialog_triggered.emit(
			"ป้ามาลัย แม่ครัวใจดี",
			"เลือกทานข้าวผัดไข่ผักรวมกับส้มสายน้ำผึ้ง สารอาหารครบ 5 หมู่ ในงบ 35 บาท เก่งมากจ้ะ! 🥗 ได้รับดาวมารยาทดี!\nทานเสร็จแล้วอย่าลืมนำถาดไปคืนและคัดแยกขยะ 3 สีที่ [จุด 1180] ทางขวานะเด็กๆ!",
			"res://assets/characters/npcs/npc_vendor.png"
		)
		_update_portal_state()
		_update_badges()
	else:
		GameManager.dialog_triggered.emit(
			"ป้ามาลัย แม่ครัวใจดี",
			"ทานอาหารกลางวันเรียบร้อยแล้ว อย่าลืมนำถาดไปคืนและคัดแยกขยะ 3 สีที่จุดคัดแยก [จุด 1180] ทางขวานะจ๊ะ! 🍱✨",
			"res://assets/characters/npcs/npc_vendor.png"
		)

func buy_junk_food() -> void:
	GameManager.dialog_triggered.emit(
		"ป้ามาลัย แม่ครัวใจดี",
		"ขนมกรุบกรอบและน้ำอัดลมไม่มีประโยชน์ต่อร่างกาย แถมเกินงบค่าขนมด้วยจ้ะ! เลือกทานอาหารที่มีประโยชน์ครบ 5 หมู่ดีกว่านะเด็กๆ! 🥗",
		"res://assets/characters/npcs/npc_vendor.png"
	)

func sort_waste_bins() -> void:
	if not GameManager.canteen_nutrition_ok:
		GameManager.dialog_triggered.emit(
			"ระบบคัดแยกขยะ",
			"ต้องไปเลือกซื้อและรับประทานอาหารกลางวัน 5 หมู่ที่เคาน์เตอร์ป้ามาลัยให้เรียบร้อยก่อนนะจ๊ะ จึงจะนำถาดและขยะมาคัดแยกได้! 🍱",
			""
		)
		return

	if not GameManager.waste_sorted_ok:
		if waste_sorting_modal:
			waste_sorting_modal.open_modal()
		else:
			GameManager.waste_sorted_ok = true
			GameManager.complete_good_deed("q_canteen_clean")
			_on_waste_sorting_completed()
	else:
		GameManager.dialog_triggered.emit(
			"ระบบคัดแยกขยะ",
			"ถังขยะคัดแยกสะอาดเรียบร้อย น่าชื่นชมมากจ้ะ! ประตูออกแปลงเกษตรและสวนโรงเรียนเปิดแล้ว ♻️✨",
			""
		)

func _on_waste_sorting_completed() -> void:
	_update_portal_state()
	_update_badges()
	GameManager.dialog_triggered.emit(
		"ระบบคัดแยกขยะ",
		"แยกขยะครบทั้ง 3 ชิ้นถูกต้อง 100%! ยอดเยี่ยมมากจ้ะ ♻️✨\nอย่าลืมไต่บันไดขึ้นชั้นลอย แล้วให้น้องปีใหม่มุดช่องลมไปเปิด [อาคาร 20 ห้องเก็บพัสดุ] เพื่อหยิบบัวรดน้ำก่อนไปด้วยนะ!",
		""
	)

func attempt_crawl_vent() -> void:
	if GameManager.storage_unlocked:
		GameManager.dialog_triggered.emit("น้องปีใหม่", "ห้องพัสดุ 20 เปิดแล้วจ้า! พี่ของขวัญรีบเดินเข้าไปหยิบบัวรดน้ำในห้องกันเถอะ! 🪴", "")
		return

	if GameManager.active_player_solo == 0:
		# Khongkwan is active -> Cannot crawl
		GameManager.dialog_triggered.emit(
			"พี่ของขวัญ (P1)",
			"ช่องลมแคบและอยู่สูง พี่ตัวโตมุดไม่เข้า... ต้องกดปุ่ม [Tab] สลับไปบังคับน้องปีใหม่ (P2) ที่ตัวเล็กกว่าเพื่อมุดเข้าไปนะจ๊ะ! 👧👶",
			""
		)
	else:
		# Peemai is active -> Crawls and unlocks!
		unlock_storage_by_peemai()

func unlock_storage_by_peemai() -> void:
	if not GameManager.storage_unlocked:
		GameManager.storage_unlocked = true
		if item_watering_can:
			item_watering_can.visible = not GameManager.has_item("บัวรดน้ำ")
		_update_door_visual()
		if AudioManager:
			AudioManager.play_sfx("sister_cheer")
		GameManager.dialog_triggered.emit(
			"น้องปีใหม่ (P2)",
			"ฮึบๆ! ปีใหม่ตัวเล็ก มุดผ่านช่องลมเข้ามาใน [อาคาร 20 ห้องเก็บพัสดุ] สำเร็จแล้ว! ปลดสลักประตูให้พี่ของขวัญเข้ามาแล้วจ้า! 🔓✨",
			""
		)
		_update_portal_state()
		_update_badges()
	else:
		if not GameManager.has_item("บัวรดน้ำ"):
			GameManager.dialog_triggered.emit(
				"น้องปีใหม่",
				"ประตูห้องเก็บพัสดุเปิดแล้ว! พี่ของขวัญรีบเดินเข้าไปหยิบ 'บัวรดน้ำ' ในห้องกันเถอะ! 🪴",
				""
			)
		else:
			GameManager.dialog_triggered.emit(
				"น้องปีใหม่",
				"พวกเราได้บัวรดน้ำแล้ว เดินไปแปลงเกษตรกันเลย! 🌸",
				""
			)

func attempt_pickup_watering_can() -> void:
	if GameManager.has_item("บัวรดน้ำ"):
		return

	# Requirement check: Must complete canteen nutrition + waste sorting first!
	if not (GameManager.canteen_nutrition_ok and GameManager.waste_sorted_ok):
		GameManager.dialog_triggered.emit(
			"ป้ามาลัย & คุณครู",
			"ยังหยิบบัวรดน้ำไม่ได้จ้ะเด็กๆ! ต้องทานอาหารกลางวัน 5 หมู่ และช่วยกันคัดแยกขยะ 3 สีลงถังก่อนนะ จึงจะไปเบิกบัวรดน้ำเพื่อไปช่วยงานแปลงเกษตรได้! 🍱♻️",
			"res://assets/characters/npcs/npc_vendor.png"
		)
		return

	# Quests complete! Pick up watering can
	GameManager.add_item("บัวรดน้ำ")
	GameManager.add_star()
	if AudioManager:
		AudioManager.play_sfx("pickup")
		AudioManager.play_sfx("sister_cheer")
	if item_watering_can:
		item_watering_can.visible = false
	GameManager.dialog_triggered.emit(
		"สองพี่น้อง",
		"🎉 ได้รับ 'บัวรดน้ำ' จากห้องพัสดุแล้ว! พร้อมนำไปช่วยรดน้ำแปลงดอกไม้และแปลงเกษตรโรงเรียนในฉากถัดไปแล้ว! 🪴🌸",
		""
	)
	_update_portal_state()
	_update_badges()

