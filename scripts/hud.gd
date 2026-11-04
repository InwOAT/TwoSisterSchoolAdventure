extends CanvasLayer
class_name GameHUD

@onready var title_label: Label = $LevelTitle if has_node("LevelTitle") else $TopBar/LevelTitle
@onready var stars_label: Label = find_child("StarsLabel", true, false)
@onready var money_label: Label = find_child("MoneyLabel", true, false)
@onready var good_deeds_label: Label = find_child("GoodDeedsLabel", true, false)
@onready var inventory_container: HBoxContainer = find_child("InventoryContainer", true, false)

@onready var btn_good_deeds: Button = find_child("BtnGoodDeeds", true, false)
@onready var btn_map: Button = find_child("BtnMap", true, false)
@onready var btn_consult: Button = find_child("BtnConsult", true, false)
@onready var btn_switch: Button = find_child("BtnSwitch", true, false)
@onready var player_indicator: Label = find_child("PlayerIndicator", true, false)

@onready var p1_stamina_bar: ProgressBar = $TopBar/StaminaContainer/P1StaminaRow/Bar
@onready var p1_stamina_status: Label = $TopBar/StaminaContainer/P1StaminaRow/Status
@onready var p2_stamina_bar: ProgressBar = $TopBar/StaminaContainer/P2StaminaRow/Bar
@onready var p2_stamina_status: Label = $TopBar/StaminaContainer/P2StaminaRow/Status

@onready var good_deed_toast: PanelContainer = $GoodDeedToast
@onready var toast_label: Label = $GoodDeedToast/HBox/ToastLabel

@onready var command_console: PanelContainer = find_child("CommandConsole", true, false)
@onready var cmd_input: LineEdit = find_child("CmdInput", true, false)
@onready var btn_send: Button = find_child("BtnSend", true, false)
@onready var btn_help: Button = find_child("BtnHelp", true, false)

@onready var quest_list_panel: PanelContainer = find_child("QuestListPanel", true, false)
@onready var quest_rows: VBoxContainer = find_child("QuestRows", true, false)
@onready var quest_progress_label: Label = find_child("Progress", true, false)

var toast_timer: float = 0.0
var quest_check_timer: float = 0.0
var _last_quest_sig: String = ""
var _prev_stars: int = -1
var _prev_money: int = -1
var _prev_deeds: int = -1
var _announced_req_complete_level: int = -1

func _ready() -> void:
	GameManager.inventory_changed.connect(_update_inventory)
	GameManager.stars_changed.connect(_update_stats)
	GameManager.stamina_updated.connect(_on_stamina_updated)
	GameManager.good_deed_updated.connect(_on_good_deed_updated)
	GameManager.dialog_triggered.connect(func(_s, _t, _p):
		if title_label: title_label.visible = false
		if quest_list_panel: quest_list_panel.visible = false
		if command_console: command_console.visible = false
	)
	GameManager.dialog_closed.connect(func():
		if title_label: title_label.visible = true
		if quest_list_panel: quest_list_panel.visible = true
		if command_console: command_console.visible = true
	)
	
	if btn_good_deeds:
		btn_good_deeds.pressed.connect(_on_good_deeds_pressed)
	if btn_map:
		btn_map.pressed.connect(_on_map_pressed)
	if btn_consult:
		btn_consult.pressed.connect(_on_consult_pressed)
	if btn_switch:
		btn_switch.pressed.connect(_on_switch_pressed)
	if player_indicator:
		player_indicator.gui_input.connect(_on_player_indicator_gui_input)
	
	# Command console setup
	if cmd_input:
		cmd_input.text_submitted.connect(_on_command_submitted)
	if btn_send and cmd_input:
		btn_send.pressed.connect(func(): _on_command_submitted(cmd_input.text))
	if btn_help:
		btn_help.pressed.connect(_show_command_help)
	
	_update_stats()
	_update_inventory()
	_update_level_title()
	_update_player_indicator()
	_update_quest_list(true)

func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0 and good_deed_toast:
			good_deed_toast.visible = false
	
	if GameManager.money_baht != _prev_money:
		_update_stats()
	
	quest_check_timer -= delta
	if quest_check_timer <= 0.0:
		quest_check_timer = 0.25
		_update_quest_list()

func _input(event: InputEvent) -> void:
	# Quick-focus command console with / or ` key
	if event is InputEventKey and event.pressed and not event.echo:
		if (event.physical_keycode == KEY_SLASH or event.physical_keycode == KEY_QUOTELEFT) and cmd_input:
			if not cmd_input.has_focus():
				cmd_input.grab_focus()
				get_viewport().set_input_as_handled()
				return
		elif event.physical_keycode == KEY_ESCAPE and cmd_input and cmd_input.has_focus():
			cmd_input.release_focus()
			get_viewport().set_input_as_handled()
			return

	# If typing inside command line, prevent game shortcut actions
	if cmd_input and cmd_input.has_focus():
		return

	if event.is_action_pressed("open_good_deeds"):
		_on_good_deeds_pressed()
	elif event.is_action_pressed("show_map"):
		_on_map_pressed()
	elif event.is_action_pressed("consult"):
		_on_consult_pressed()
	elif event.is_action_pressed("switch_player"):
		_on_switch_pressed()
	elif event.is_action_pressed("emote_1"):
		_trigger_emote("😊 ยิ้มแย้มแจ่มใส")
	elif event.is_action_pressed("emote_2"):
		_trigger_emote("🙏 สวัสดีค่ะ/ครับ")
		GameManager.add_star()
	elif event.is_action_pressed("emote_3"):
		_trigger_emote("❓ เอ๊ะ... ทำยังไงต่อนะ?")

func _trigger_emote(text: String) -> void:
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p.has_method("show_emote"):
			p.show_emote(text)

func _pop_control(ctrl: Control) -> void:
	if not ctrl or not ctrl.is_inside_tree():
		return
	ctrl.pivot_offset = ctrl.size * 0.5
	ctrl.scale = Vector2(1.28, 1.28)
	var tw := ctrl.create_tween()
	tw.tween_property(ctrl, "scale", Vector2(1.0, 1.0), 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _show_toast(msg: String, duration: float = 3.2) -> void:
	if not good_deed_toast or not toast_label:
		return
	toast_label.text = msg
	good_deed_toast.visible = true
	toast_timer = duration
	_pop_control(good_deed_toast)

func _update_stats() -> void:
	if stars_label:
		stars_label.text = "⭐ %d" % GameManager.etiquette_stars
		if _prev_stars >= 0 and GameManager.etiquette_stars != _prev_stars:
			_pop_control(stars_label)
		_prev_stars = GameManager.etiquette_stars
	if money_label:
		money_label.text = "🪙 %d ฿" % GameManager.money_baht
		if _prev_money >= 0 and GameManager.money_baht != _prev_money:
			_pop_control(money_label)
		_prev_money = GameManager.money_baht
	if good_deeds_label:
		good_deeds_label.text = "💖 %d" % GameManager.good_deed_points
		if _prev_deeds >= 0 and GameManager.good_deed_points != _prev_deeds:
			_pop_control(good_deeds_label)
		_prev_deeds = GameManager.good_deed_points

func _on_good_deed_updated(_quest_id: String, points_gained: int, _total_points: int, quest_title: String) -> void:
	_update_stats()
	_update_quest_list(true)
	if points_gained > 0:
		_show_toast("🎉 สำเร็จเควสความดี: %s (+%d แต้ม!) 🏆" % [quest_title, points_gained], 3.8)
	elif points_gained == 0:
		_show_toast("📜 ได้รับเควสความดี: %s" % quest_title, 2.5)

func _on_stamina_updated(player_id: int, current_stamina: float, max_stamina: float, is_exhausted: bool) -> void:
	var bar: ProgressBar = p1_stamina_bar if player_id == 0 else p2_stamina_bar
	var lbl: Label = p1_stamina_status if player_id == 0 else p2_stamina_status
	if not bar or not lbl:
		return
	
	bar.max_value = max_stamina
	bar.value = current_stamina
	
	var pct: int = int(round((current_stamina / max_stamina) * 100.0))
	if is_exhausted:
		lbl.text = "หอบ! 💦"
		lbl.modulate = Color(1.0, 0.3, 0.3)
		bar.modulate = Color(1.0, 0.2, 0.2)
	else:
		lbl.text = "%d%%" % pct
		lbl.modulate = Color(0.9, 0.9, 0.9)
		if pct < 25:
			bar.modulate = Color(1.0, 0.2, 0.2)
		elif pct < 55:
			bar.modulate = Color(1.0, 0.85, 0.2)
		else:
			if player_id == 0:
				bar.modulate = Color(0.3, 0.95, 0.4)
			else:
				bar.modulate = Color(0.3, 0.85, 1.0)

func _update_level_title() -> void:
	if not title_label:
		return
	var titles = {
		1: "ฉากที่ 1: ในบ้านตอนเช้า",
		2: "ฉากที่ 2: ซอยหมู่บ้านดอนโมง",
		25: "ฉากศาลาป้ายรอขึ้นรถเมล์",
		3: "ฉากที่ 3: บนรถเมล์สายหลัก (ขาไป)",
		4: "ฉากที่ 4: สถานีขนส่ง & รถสองแถว",
		5: "ฉากที่ 5: หน้าโรงเรียนชุมชนหนองเรือ",
		6: "ฉากที่ 6: คาบเรียนหรรษา (ห้องเรียน)",
		7: "ฉากที่ 7: โรงอาหาร & ห้องพัสดุ",
		8: "ฉากที่ 8: ผจญภัยสวนเกษตรโรงเรียน",
		9: "ฉากที่ 9: รถสองแถว (ขากลับ)",
		95: "ฉากที่ 9.5: ท่ารถ & ศาลาต่อรถเมล์ (ขากลับ)",
		10: "ฉากที่ 10: รถเมล์สายหลัก (ขากลับ)",
		11: "ฉากที่ 11: ซอยบ้านยามเย็น สายฝน",
		12: "ฉากที่ 12: บ้านแสนสุขยามค่ำคืน",
		13: "ฉากที่ 13: ห้องนอน & ฉากจบแสนอบอุ่น",
		201: "ฉากที่ 2: ร้านชำลุงสิทธิ์ & Lotus's",
		202: "ฉากที่ 2: ป้อมตำรวจเทศบาลดอนโมง",
		203: "ฉากที่ 2: คลินิกหมอชุมชนดอนโมง",
		204: "ฉากที่ 2: ศาลาการเปรียญวัดมงคลนิมิต",
		801: "ฉากที่ 8: อาคาร 14 ห้องสมุดโรงเรียน",
		802: "ฉากที่ 8: อาคาร 15 ห้องพยาบาล",
		803: "ฉากที่ 8: อาคาร 16 ร้านสหกรณ์โรงเรียน",
		804: "ฉากที่ 8: ศาลปู่-ย่า ประจำโรงเรียน",
		805: "ฉากที่ 8: เรือนเพาะชำ & แปลงดอกไม้"
	}
	title_label.text = "📍 " + titles.get(GameManager.current_level, "การผจญภัยไปโรงเรียน")
	_update_quest_list(true)

func _update_quest_list(force: bool = false) -> void:
	if not quest_list_panel or not quest_rows:
		return
	
	var quests := _get_current_level_quests()
	if quests.is_empty():
		quest_list_panel.visible = false
		return
	
	# Generate signature to avoid rebuilding if nothing changed
	var sig := "%d|" % GameManager.current_level
	var completed_count := 0
	var required_count := 0
	var completed_required := 0
	for q in quests:
		sig += "%s:%s:%s|" % [q["id"], str(q["completed"]), str(q.get("required", false))]
		if q["completed"]:
			completed_count += 1
		if q.get("required", false):
			required_count += 1
			if q["completed"]:
				completed_required += 1
	
	if not force and sig == _last_quest_sig:
		return
	var was_initial := (_last_quest_sig == "") or not _last_quest_sig.begins_with("%d|" % GameManager.current_level)
	_last_quest_sig = sig
	
	if required_count > 0 and completed_required == required_count:
		if not was_initial and _announced_req_complete_level != GameManager.current_level:
			_announced_req_complete_level = GameManager.current_level
			_show_toast("✨ ภารกิจหลักครบแล้ว! ประตูทางออกเปิดแล้วจ้า! ✨", 3.8)
			_pop_control(quest_list_panel)
			if AudioManager:
				AudioManager.play_sfx("bloom", 1.05)
			GameManager.spawn_star_burst(Vector2.ZERO, Color(0.25, 1.0, 0.85))
		elif was_initial:
			_announced_req_complete_level = GameManager.current_level
	elif _announced_req_complete_level == GameManager.current_level:
		_announced_req_complete_level = -1
	
	# Update Header Progress Indicator
	if quest_progress_label:
		if required_count > 0:
			if completed_required == required_count:
				if completed_count == quests.size():
					quest_progress_label.text = "(✅ ครบทุกเควส)"
				else:
					quest_progress_label.text = "(✨ เควสบังคับครบ %d/%d)" % [completed_required, required_count]
				quest_progress_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
			else:
				quest_progress_label.text = "(เควสบังคับ %d/%d)" % [completed_required, required_count]
				quest_progress_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		else:
			if completed_count == quests.size() and quests.size() > 0:
				quest_progress_label.text = "(✅ ครบแล้ว)"
				quest_progress_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
			else:
				quest_progress_label.text = "(%d/%d)" % [completed_count, quests.size()]
				quest_progress_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	
	# Clear previous items
	for child in quest_rows.get_children():
		quest_rows.remove_child(child)
		child.queue_free()
	
	# Populate rows
	for q in quests:
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 6)
		
		var is_req: bool = q.get("required", false)
		
		# 1) Visual Quest Icon Box (Item texture or Emoji)
		var icon_box := PanelContainer.new()
		icon_box.custom_minimum_size = Vector2(24, 24)
		var icon_style := StyleBoxFlat.new()
		icon_style.set_corner_radius_all(5)
		if is_req:
			icon_style.bg_color = Color(0.25, 0.18, 0.08, 0.9)
			icon_style.border_color = Color(1.0, 0.82, 0.28, 0.9)
			icon_style.set_border_width_all(1)
		else:
			icon_style.bg_color = Color(0.1, 0.16, 0.26, 0.85)
			icon_style.border_color = Color(0.4, 0.7, 0.95, 0.65)
			icon_style.set_border_width_all(1)
		icon_box.add_theme_stylebox_override("panel", icon_style)
		
		var icon_tex_path: String = q.get("icon_tex", "")
		if icon_tex_path != "" and ResourceLoader.exists(icon_tex_path):
			var tex_rect := TextureRect.new()
			tex_rect.custom_minimum_size = Vector2(18, 18)
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.texture = load(icon_tex_path)
			tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			icon_box.add_child(tex_rect)
		else:
			var emoji_lbl := Label.new()
			emoji_lbl.text = q.get("icon", "🎯" if is_req else "⭐")
			emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			emoji_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			emoji_lbl.add_theme_font_size_override("font_size", 12)
			icon_box.add_child(emoji_lbl)
		row.add_child(icon_box)
		
		# 2) Quest Category Badge: [🎯 หลัก] vs [💖 เสริม]
		var type_badge := Label.new()
		type_badge.add_theme_font_size_override("font_size", 10)
		type_badge.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
		type_badge.add_theme_constant_override("shadow_offset_x", 1)
		type_badge.add_theme_constant_override("shadow_offset_y", 1)
		if is_req:
			type_badge.text = "🎯 [หลัก]"
			type_badge.add_theme_color_override("font_color", Color(1.0, 0.78, 0.28))
		else:
			type_badge.text = "💖 [เสริม]"
			type_badge.add_theme_color_override("font_color", Color(0.65, 0.88, 1.0))
		row.add_child(type_badge)
		
		# 3) Quest Title
		var title_lbl := Label.new()
		title_lbl.text = q["title"]
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_lbl.add_theme_font_size_override("font_size", 11)
		title_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		title_lbl.add_theme_constant_override("shadow_offset_x", 1)
		title_lbl.add_theme_constant_override("shadow_offset_y", 1)
		if q["completed"]:
			title_lbl.add_theme_color_override("font_color", Color(0.7, 0.88, 0.78, 0.9))
		else:
			title_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0, 1.0))
		row.add_child(title_lbl)
		
		# 4) Status Tag at the back
		var status_lbl := Label.new()
		status_lbl.add_theme_font_size_override("font_size", 11)
		status_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		status_lbl.add_theme_constant_override("shadow_offset_x", 1)
		status_lbl.add_theme_constant_override("shadow_offset_y", 1)
		if q["completed"]:
			status_lbl.text = "[✅ เสร็จแล้ว]"
			status_lbl.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		else:
			status_lbl.text = "[⏳ ยังไม่ทำ]"
			status_lbl.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
		row.add_child(status_lbl)
		
		quest_rows.add_child(row)
	
	quest_list_panel.visible = true

func _get_current_level_quests() -> Array[Dictionary]:
	var level := GameManager.current_level
	var list: Array[Dictionary] = []
	
	match level:
		1:
			list.append({
				"id": "q_home_table",
				"title": "ช่วยแม่เก็บโต๊ะอาหารและกวาดบ้าน",
				"required": true,
				"completed": GameManager.chore_table_done or GameManager.good_deeds.get("q_home_table", {}).get("status") == "completed",
				"icon": "🍽️",
				"icon_tex": ""
			})
			list.append({
				"id": "q_home_trash",
				"title": "ช่วยพ่อแยกขยะและนำไปทิ้ง",
				"required": false,
				"completed": GameManager.chore_trash_done or GameManager.good_deeds.get("q_home_trash", {}).get("status") == "completed",
				"icon": "♻️",
				"icon_tex": "res://assets/items/item_plastic_bottle.png"
			})
			list.append({
				"id": "q_home_door",
				"title": "ดันเก้าอี้หยิบกุญแจเปิดประตูบ้าน",
				"required": true,
				"completed": GameManager.house_unlocked,
				"icon": "🔑",
				"icon_tex": "res://assets/items/item_house_key.png"
			})
		2:
			list.append({
				"id": "q_auntie_errand",
				"title": "ช่วยคุณป้าสมศรีซื้อของร้านชำ",
				"required": true,
				"completed": GameManager.auntie_errand_done or GameManager.good_deeds.get("q_auntie_errand", {}).get("status") == "completed",
				"icon": "🥚",
				"icon_tex": "res://assets/items/item_eggs_milk.png"
			})
			list.append({
				"id": "q_village_police",
				"title": "แจ้งตำรวจ: แมวหลง & วินัยจราจร",
				"required": true,
				"completed": GameManager.village_police_visited or GameManager.good_deeds.get("q_village_police", {}).get("status") == "completed",
				"icon": "🐱",
				"icon_tex": "res://assets/items/item_orange_cat.png"
			})
			list.append({
				"id": "q_village_market",
				"title": "จ่ายตลาด: ซื้อผักสดปลอดสารพิษ",
				"required": false,
				"completed": GameManager.village_veggies_bought or GameManager.good_deeds.get("q_village_market", {}).get("status") == "completed",
				"icon": "🥬",
				"icon_tex": "res://assets/items/item_vegetables.png"
			})
			list.append({
				"id": "q_village_doctor",
				"title": "ไปหาหมอ: รับยาวิตามินให้ยาย",
				"required": false,
				"completed": GameManager.village_doctor_visited or GameManager.good_deeds.get("q_village_doctor", {}).get("status") == "completed",
				"icon": "💊",
				"icon_tex": "res://assets/items/item_vitamins.png"
			})
			list.append({
				"id": "q_village_temple",
				"title": "ทำบุญที่วัด: ไหว้พระ & กวาดลานวัด",
				"required": false,
				"completed": GameManager.village_temple_cleaned or GameManager.good_deeds.get("q_village_temple", {}).get("status") == "completed",
				"icon": "🛕",
				"icon_tex": ""
			})
			list.append({
				"id": "q_village_post",
				"title": "ส่งจดหมาย: หยอดตู้ไปรษณีย์ไทย",
				"required": false,
				"completed": GameManager.village_letter_sent or GameManager.good_deeds.get("q_village_post", {}).get("status") == "completed",
				"icon": "📮",
				"icon_tex": ""
			})
		25:
			list.append({
				"id": "q_busstop_water",
				"title": "ซื้อน้ำเก๊กฮวยเย็นให้คุณตา",
				"required": true,
				"completed": GameManager.busstop_water_given or GameManager.good_deeds.get("q_busstop_water", {}).get("status") == "completed",
				"icon": "🥤",
				"icon_tex": "res://assets/items/item_drink.png"
			})
			list.append({
				"id": "q_busstop_schedule",
				"title": "ตรวจเช็คตารางเดินรถสาย 514",
				"required": true,
				"completed": GameManager.busstop_schedule_checked or GameManager.good_deeds.get("q_busstop_schedule", {}).get("status") == "completed",
				"icon": "🚏",
				"icon_tex": ""
			})
			list.append({
				"id": "q_busstop_trash",
				"title": "ช่วยเก็บขวดน้ำทิ้งถังรีไซเคิล",
				"required": false,
				"completed": GameManager.busstop_trash_done or GameManager.good_deeds.get("q_busstop_trash", {}).get("status") == "completed",
				"icon": "♻️",
				"icon_tex": "res://assets/items/item_plastic_bottle.png"
			})
		3:
			list.append({
				"id": "q_bus_fare",
				"title": "จ่ายค่าโดยสารรถเมล์ 16 บาท",
				"required": true,
				"completed": GameManager.bus_fare_paid,
				"icon": "🎫",
				"icon_tex": "res://assets/items/item_coupon.png"
			})
			list.append({
				"id": "q_bus_seat",
				"title": "สละที่นั่งให้คุณยายบนรถเมล์",
				"required": true,
				"completed": GameManager.grandma_seated or GameManager.good_deeds.get("q_bus_seat", {}).get("status") == "completed",
				"icon": "💺",
				"icon_tex": ""
			})
		4:
			list.append({
				"id": "q_terminal_grandma",
				"title": "ช่วยคุณยายชี้ทางไปขึ้นรถสองแถว",
				"required": true,
				"completed": GameManager.good_deeds.get("q_terminal_grandma", {}).get("status") == "completed",
				"icon": "👵",
				"icon_tex": ""
			})
			list.append({
				"id": "q_terminal_bus",
				"title": "เลือกรถสองแถวสีฟ้าไปโรงเรียน",
				"required": true,
				"completed": GameManager.songthaew_correct,
				"icon": "🚐",
				"icon_tex": ""
			})
		5:
			list.append({
				"id": "q_school_wai",
				"title": "ไหว้ครูเวรและขอกุญแจจากลุง รปภ.",
				"required": true,
				"completed": GameManager.guard_talked or GameManager.good_deeds.get("q_school_wai", {}).get("status") == "completed",
				"icon": "👮",
				"icon_tex": "res://assets/items/item_classroom_key.png"
			})
			list.append({
				"id": "q_school_door",
				"title": "ไขกุญแจเปิดประตูอาคารเรียน",
				"required": true,
				"completed": GameManager.classroom_unlocked,
				"icon": "🔑",
				"icon_tex": "res://assets/items/item_classroom_key.png"
			})
			list.append({
				"id": "q_school_pencil",
				"title": "ช่วยเก็บกล่องดินสอให้น้อง ป.1",
				"required": false,
				"completed": GameManager.good_deeds.get("q_school_pencil", {}).get("status") == "completed",
				"icon": "✏️",
				"icon_tex": "res://assets/items/pencil_box_item.png"
			})
		6:
			list.append({
				"id": "q_classroom_quiz",
				"title": "ตอบคำถามคาบเรียนหรรษา 3 ข้อ",
				"required": true,
				"completed": GameManager.classroom_quiz_score >= 3,
				"icon": "📝",
				"icon_tex": ""
			})
			list.append({
				"id": "q_teacher_board",
				"title": "ช่วยคุณครูลบกระดานและจัดโต๊ะ",
				"required": false,
				"completed": GameManager.teacher_board_done or GameManager.good_deeds.get("q_teacher_board", {}).get("status") == "completed",
				"icon": "🧹",
				"icon_tex": ""
			})
		7:
			list.append({
				"id": "q_canteen_nutrition",
				"title": "ซื้ออาหารกลางวันครบ 5 หมู่",
				"required": true,
				"completed": GameManager.canteen_nutrition_ok,
				"icon": "🍱",
				"icon_tex": ""
			})
			list.append({
				"id": "q_canteen_storage",
				"title": "ขึ้นบันไดมุดช่องลมหยิบบัวรดน้ำ",
				"required": true,
				"completed": GameManager.has_item("บัวรดน้ำ") or GameManager.storage_unlocked,
				"icon": "🚿",
				"icon_tex": "res://assets/items/item_watering_can.png"
			})
			list.append({
				"id": "q_canteen_clean",
				"title": "เก็บจานข้าวและคัดแยกขยะ 3 สี",
				"required": false,
				"completed": GameManager.waste_sorted_ok or GameManager.good_deeds.get("q_canteen_clean", {}).get("status") == "completed",
				"icon": "🍽️",
				"icon_tex": ""
			})
		8:
			list.append({
				"id": "q_flower_garden",
				"title": "นำตำรา ปุ๋ย และบัวรดน้ำดูแลแปลงดอกไม้",
				"required": true,
				"completed": GameManager.flowers_bloomed or GameManager.good_deeds.get("q_flower_garden", {}).get("status") == "completed",
				"icon": "🌸",
				"icon_tex": "res://assets/items/item_watering_can.png"
			})
			list.append({
				"id": "q_first_aid_friend",
				"title": "ปฐมพยาบาลน้องอนุบาลที่หกล้ม",
				"required": false,
				"completed": GameManager.injured_student_helped or GameManager.good_deeds.get("q_first_aid_friend", {}).get("status") == "completed",
				"icon": "🩹",
				"icon_tex": "res://assets/items/item_first_aid.png"
			})
			list.append({
				"id": "q_nurse_help",
				"title": "ช่วยครูพยาบาลจัดกล่องยา",
				"required": false,
				"completed": GameManager.good_deeds.get("q_nurse_help", {}).get("status") == "completed",
				"icon": "💊",
				"icon_tex": "res://assets/items/item_first_aid.png"
			})
		9:
			list.append({
				"id": "q_bag_push",
				"title": "ช่วยกันดันกระเป๋าเดินทางหาเหรียญ",
				"required": true,
				"completed": GameManager.bag_pushed,
				"icon": "🧳",
				"icon_tex": "res://assets/items/item_school_bag.png"
			})
			list.append({
				"id": "q_coin_find",
				"title": "เก็บเหรียญ 10 บาทจ่ายค่ารถสองแถว",
				"required": true,
				"completed": GameManager.coin_10_found,
				"icon": "🪙",
				"icon_tex": "res://assets/items/item_coin_10.png"
			})
		10:
			list.append({
				"id": "q_return_wallet",
				"title": "เก็บกระเป๋าสตางค์ส่งคืนผู้โดยสาร",
				"required": true,
				"completed": GameManager.wallet_returned or GameManager.good_deeds.get("q_return_wallet", {}).get("status") == "completed",
				"icon": "👛",
				"icon_tex": "res://assets/items/item_wallet.png"
			})
			list.append({
				"id": "q_refuse_stranger",
				"title": "ปฏิเสธรับขนมจากคนแปลกหน้า",
				"required": true,
				"completed": GameManager.stranger_refused,
				"icon": "🛡️",
				"icon_tex": ""
			})
		11:
			list.append({
				"id": "q_share_umbrella",
				"title": "กางร่มแบ่งปันพาเพื่อนกลับบ้าน",
				"required": true,
				"completed": GameManager.umbrella_active or GameManager.good_deeds.get("q_share_umbrella", {}).get("status") == "completed",
				"icon": "☂️",
				"icon_tex": "res://assets/items/item_umbrella.png"
			})
		12:
			list.append({
				"id": "q_home_evening",
				"title": "ช่วยแม่ล้างจานและนวดหลังให้คุณพ่อ",
				"required": true,
				"completed": GameManager.evening_chore_done or GameManager.good_deeds.get("q_home_evening", {}).get("status") == "completed",
				"icon": "🧼",
				"icon_tex": ""
			})
			list.append({
				"id": "q_home_shoes",
				"title": "จัดเก็บรองเท้าและวางกระเป๋าเข้าที่",
				"required": true,
				"completed": GameManager.day_completed,
				"icon": "👞",
				"icon_tex": "res://assets/items/item_school_bag.png"
			})
		13:
			var lvl13 = get_tree().current_scene if get_tree() and get_tree().current_scene and get_tree().current_scene.name == "Level13" else null
			list.append({
				"id": "q_bedroom_homework",
				"title": "ทำการบ้านครบ 3 วิชา (คณิต, ไทย, สุขศึกษา)",
				"required": true,
				"completed": lvl13.homework_completed if lvl13 and "homework_completed" in lvl13 else false,
				"icon": "📚",
				"icon_tex": "res://assets/items/item_plant_book.png"
			})
			list.append({
				"id": "q_parents_cheer",
				"title": "รับฟังคำชมและกำลังใจจากพ่อแม่",
				"required": true,
				"completed": lvl13.parents_arrived if lvl13 and "parents_arrived" in lvl13 else false,
				"icon": "🌟",
				"icon_tex": ""
			})
		201: # Shop
			list.append({
				"id": "q_shop_items",
				"title": "เลือกหยิบไข่ไก่สดและนมถั่วเหลืองให้ป้าสมศรี",
				"required": true,
				"completed": GameManager.shop_groceries_bought,
				"icon": "🥚",
				"icon_tex": "res://assets/items/item_eggs_milk.png"
			})
			list.append({
				"id": "q_shop_change",
				"title": "ตรวจนับเงินทอน 5 บาทและกล่าวขอบคุณลุงสิทธิ์",
				"required": false,
				"completed": GameManager.shop_groceries_bought,
				"icon": "🪙",
				"icon_tex": "res://assets/items/item_coin_10.png"
			})
		202: # Police
			list.append({
				"id": "q_police_safety",
				"title": "เรียนรู้วินัยจราจรและข้ามทางม้าลายกับคุณตำรวจ",
				"required": true,
				"completed": GameManager.police_safety_done,
				"icon": "🚦",
				"icon_tex": ""
			})
			list.append({
				"id": "q_police_cat",
				"title": "แจ้งข้อมูลลูกแมวเจ้าส้มที่ป้ายประกาศชุมชน",
				"required": false,
				"completed": GameManager.police_safety_done,
				"icon": "🐱",
				"icon_tex": "res://assets/items/item_orange_cat.png"
			})
		203: # Clinic
			list.append({
				"id": "q_clinic_vision",
				"title": "ตรวจสายตาและตอบคำถามการถนอมดวงตากับคุณหมอ",
				"required": true,
				"completed": GameManager.doctor_eyedrops_received,
				"icon": "👁️",
				"icon_tex": ""
			})
			list.append({
				"id": "q_clinic_medicine",
				"title": "รับยาวิตามินบำรุงสายตาไปให้คุณยาย",
				"required": true,
				"completed": GameManager.doctor_eyedrops_received,
				"icon": "💊",
				"icon_tex": "res://assets/items/item_vitamins.png"
			})
		204: # Temple
			list.append({
				"id": "q_temple_respect",
				"title": "กราบพระประธานและรับฟังโอวาทธรรมจากหลวงตา",
				"required": true,
				"completed": GameManager.temple_hall_swept,
				"icon": "🛕",
				"icon_tex": ""
			})
			list.append({
				"id": "q_temple_sweep",
				"title": "หยิบไม้กวาดช่วยกวาดลานศาลาวัดมงคลนิมิต",
				"required": false,
				"completed": GameManager.temple_hall_swept,
				"icon": "🧹",
				"icon_tex": ""
			})
		801: # Library
			list.append({
				"id": "q_lib_etiquette",
				"title": "เรียนรู้มารยาทการใช้ห้องสมุดและอ่านหนังสือเงียบๆ",
				"required": true,
				"completed": GameManager.library_books_sorted,
				"icon": "📖",
				"icon_tex": "res://assets/items/item_plant_book.png"
			})
			list.append({
				"id": "q_lib_books",
				"title": "ช่วยจัดเรียงหนังสือเข้าหมวดหมู่บนชั้นวาง",
				"required": false,
				"completed": GameManager.library_books_sorted,
				"icon": "📚",
				"icon_tex": "res://assets/items/item_plant_book.png"
			})
		802: # Infirmary
			list.append({
				"id": "q_infirmary_firstaid",
				"title": "เรียนรู้วิธีปฐมพยาบาลเบื้องต้น (ล้างแผล & ทายา)",
				"required": true,
				"completed": GameManager.infirmary_firstaid_done,
				"icon": "🩹",
				"icon_tex": "res://assets/items/item_first_aid.png"
			})
			list.append({
				"id": "q_infirmary_health",
				"title": "ตรวจวัดส่วนสูงและชั่งน้ำหนักบันทึกสุขภาพ",
				"required": false,
				"completed": GameManager.infirmary_firstaid_done,
				"icon": "🩺",
				"icon_tex": ""
			})
		803: # Coop
			list.append({
				"id": "q_coop_buy",
				"title": "ซื้ออุปกรณ์การเรียน (ไม้บรรทัด, ยางลบ, ดินสอ) ในงบ 15 บาท",
				"required": true,
				"completed": GameManager.coop_supplies_bought,
				"icon": "✏️",
				"icon_tex": "res://assets/items/pencil_box_item.png"
			})
			list.append({
				"id": "q_coop_polite",
				"title": "ตรวจนับเงินค่าอุปกรณ์และกล่าวขอบคุณพี่สหกรณ์",
				"required": false,
				"completed": GameManager.coop_supplies_bought,
				"icon": "🪙",
				"icon_tex": "res://assets/items/item_coin_10.png"
			})
		_:
			for q_id in GameManager.good_deeds.keys():
				var q: Dictionary = GameManager.good_deeds[q_id]
				var loc: String = q.get("location", "")
				if ("ฉากที่ %d" % level) in loc or ("ฉาก %d" % level) in loc:
					list.append({
						"id": q_id,
						"title": q.get("title", ""),
						"required": true,
						"completed": q.get("status") == "completed",
						"icon": "⭐",
						"icon_tex": ""
					})
	
	return list

const ITEM_DATA: Dictionary = {
	"กุญแจบ้าน": { "icon": "res://assets/items/item_house_key.png", "emoji": "🔑" },
	"ร่ม": { "icon": "res://assets/items/item_umbrella.png", "emoji": "☂️" },
	"บัตรนักเรียน": { "icon": "res://assets/items/item_student_card.png", "emoji": "🪪" },
	"ลูกแมวเจ้าส้ม": { "icon": "res://assets/items/item_orange_cat.png", "emoji": "🐱" },
	"ผักกาดขาวและแตงกวา": { "icon": "res://assets/items/item_vegetables.png", "emoji": "🥬" },
	"ไข่ไก่และนมถั่วเหลือง": { "icon": "res://assets/items/item_eggs_milk.png", "emoji": "🥛" },
	"ยาวิตามินและยาหยอดตา": { "icon": "res://assets/items/item_vitamins.png", "emoji": "💊" },
	"ขวดน้ำพลาสติก": { "icon": "res://assets/items/item_plastic_bottle.png", "emoji": "🧴" },
	"น้ำเก๊กฮวยเย็นชื่นใจ": { "icon": "res://assets/items/item_drink.png", "emoji": "🥤" },
	"กุญแจห้องและสมุดเช็คชื่อ": { "icon": "res://assets/items/item_classroom_key.png", "emoji": "🗝️" },
	"กล่องดินสอสี": { "icon": "res://assets/items/pencil_box_item.png", "emoji": "✏️" },
	"บัวรดน้ำ": { "icon": "res://assets/items/item_watering_can.png", "emoji": "🪴" },
	"ตำราพฤกษศาสตร์": { "icon": "res://assets/items/item_plant_book.png", "emoji": "📖" },
	"กล่องปฐมพยาบาล": { "icon": "res://assets/items/item_first_aid.png", "emoji": "🩹" },
	"คูปองสหกรณ์": { "icon": "res://assets/items/item_coupon.png", "emoji": "🎟️" },
	"ปุ๋ยอินทรีย์": { "icon": "res://assets/items/item_fertilizer.png", "emoji": "🌱" },
	"เหรียญ 10 บาท": { "icon": "res://assets/items/item_coin_10.png", "emoji": "🪙" },
	"กระเป๋าสตางค์": { "icon": "res://assets/items/item_wallet.png", "emoji": "👛" },
	"กระเป๋านักเรียน": { "icon": "res://assets/items/item_school_bag.png", "emoji": "🎒" }
}

func _update_inventory() -> void:
	if not inventory_container:
		return
	for c in inventory_container.get_children():
		c.queue_free()
	
	for item in GameManager.inventory:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(36, 36)
		panel.tooltip_text = "🎒 " + item
		
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.18, 0.30, 0.95)
		sb.border_color = Color(1.0, 0.85, 0.35, 0.9)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(8)
		sb.shadow_color = Color(0, 0, 0, 0.35)
		sb.shadow_size = 3
		sb.content_margin_left = 4
		sb.content_margin_right = 4
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		panel.add_theme_stylebox_override("panel", sb)

		var data: Dictionary = ITEM_DATA.get(item, { "icon": "", "emoji": "🎒" })
		var icon_path: String = data.get("icon", "")
		if icon_path != "" and ResourceLoader.exists(icon_path):
			var tex_rect := TextureRect.new()
			tex_rect.texture = load(icon_path)
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(28, 28)
			panel.add_child(tex_rect)
		else:
			var lbl := Label.new()
			lbl.text = data.get("emoji", "🎒")
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 18)
			panel.add_child(lbl)

		inventory_container.add_child(panel)

func _update_player_indicator() -> void:
	if player_indicator:
		if GameManager.active_player_solo == 0:
			player_indicator.text = "👧"
			player_indicator.modulate = Color(1.0, 0.78, 0.88)
			player_indicator.tooltip_text = "พี่ของขวัญ (P1) - คลิกหรือกด [Tab] เพื่อสลับ"
		else:
			player_indicator.text = "👶"
			player_indicator.modulate = Color(0.65, 0.9, 1.0)
			player_indicator.tooltip_text = "น้องปีใหม่ (P2) - คลิกหรือกด [Tab] เพื่อสลับ"

func _on_player_indicator_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_switch_pressed()

func _on_good_deeds_pressed() -> void:
	GameManager.good_deeds_modal_toggled.emit()

func _on_map_pressed() -> void:
	GameManager.map_toggled.emit()

func _on_switch_pressed() -> void:
	GameManager.active_player_solo = 1 - GameManager.active_player_solo
	_update_player_indicator()
	var mode_name := "พี่ของขวัญ" if GameManager.active_player_solo == 0 else "น้องปีใหม่"
	GameManager.dialog_triggered.emit("ระบบ", "สลับไปควบคุม: " + mode_name + " (อีกคนจะเดินตามช่วยเหลืออย่างน่ารัก!)", "")

func _on_consult_pressed() -> void:
	var hint := GameManager.get_hint()
	GameManager.dialog_triggered.emit("💡 ปรึกษากัน (Hint)", hint, "")

# --- Command Console & Cheat Handler ---
func _on_command_submitted(raw_text: String) -> void:
	var text := raw_text.strip_edges()
	if cmd_input:
		cmd_input.clear()
		cmd_input.release_focus()
	
	if text == "":
		return
	
	print("[CommandConsole] Executing: ", text)
	var parts := text.split(" ", false)
	if parts.is_empty():
		return
	var cmd := parts[0].to_lower()
	
	if cmd in ["@map", "/map", "@warp", "/warp", "@goto", "/goto"]:
		if parts.size() < 2:
			_show_toast("⚠️ กรุณาระบุเลขแมพ เช่น @map 1 หรือ @map 7")
			return
		var map_arg := parts[1].strip_edges().to_lower()
		var target_lvl := 0
		if map_arg in ["2.5", "25", "bus_stop", "stop"]:
			target_lvl = 25
		elif map_arg.is_valid_int():
			target_lvl = map_arg.to_int()
		elif map_arg in ["home", "house"]:
			target_lvl = 1
		elif map_arg in ["village", "donmong"]:
			target_lvl = 2
		elif map_arg in ["bus", "mainbus"]:
			target_lvl = 3
		elif map_arg in ["terminal", "songthaew"]:
			target_lvl = 4
		elif map_arg in ["school", "entrance", "gate"]:
			target_lvl = 5
		elif map_arg in ["quiz", "classroom", "class"]:
			target_lvl = 6
		elif map_arg in ["canteen", "lunch", "food"]:
			target_lvl = 7
		elif map_arg in ["explore", "garden", "grounds"]:
			target_lvl = 8
		elif map_arg in ["return_songthaew", "songthaew_return"]:
			target_lvl = 9
		elif map_arg in ["return_bus", "bus_return"]:
			target_lvl = 10
		elif map_arg in ["rain", "rainy"]:
			target_lvl = 11
		elif map_arg in ["bedtime", "night"]:
			target_lvl = 12
		
		if target_lvl > 0 and (target_lvl <= 12 or target_lvl == 25):
			if AudioManager:
				AudioManager.play_sfx("portal")
			_show_toast("🚀 วาปไปยังฉากที่ %s สำเร็จ!" % map_arg)
			GameManager.change_level(target_lvl)
		else:
			_show_toast("⚠️ ไม่พบฉาก '%s' (ใช้เลข 1 - 12 หรือ 2.5)" % map_arg)
	
	elif cmd in ["@pass", "/pass", "@clear", "/clear", "@unlock", "/unlock"]:
		GameManager.pass_current_level()
		if AudioManager:
			AudioManager.play_sfx("sister_cheer")
		_show_toast("✨ [สูตรสำเร็จ] ปลดล็อกเควสและเปิดประตูฉากปัจจุบันแล้ว!")
	
	elif cmd in ["@money", "/money"]:
		var amt := 50
		if parts.size() >= 2 and parts[1].is_valid_int():
			amt = parts[1].to_int()
		GameManager.money_baht += amt
		if AudioManager:
			AudioManager.play_sfx("coin")
		_update_stats()
		_show_toast("🪙 ได้รับเงินค่าขนม +%d บาท (รวม %d ฿)" % [amt, GameManager.money_baht])
	
	elif cmd in ["@star", "/star", "@stars"]:
		var amt := 5
		if parts.size() >= 2 and parts[1].is_valid_int():
			amt = parts[1].to_int()
		GameManager.etiquette_stars += amt
		GameManager.stars_changed.emit()
		if AudioManager:
			AudioManager.play_sfx("star")
		_update_stats()
		_show_toast("⭐ ได้รับดาวมารยาท +%d ดวง (รวม %d ดวง)" % [amt, GameManager.etiquette_stars])
	
	elif cmd in ["@item", "/item"]:
		if parts.size() < 2:
			_show_toast("⚠️ กรุณาระบุชื่อไอเทม เช่น @item บัวรดน้ำ")
			return
		var item_name := text.substr(cmd.length()).strip_edges()
		GameManager.add_item(item_name)
		if AudioManager:
			AudioManager.play_sfx("pickup")
		_show_toast("🎒 ได้รับไอเทม: %s เข้ากระเป๋าแล้ว!" % item_name)
	
	elif cmd in ["@heal", "/heal", "@hp"]:
		GameManager.stamina_updated.emit(0, 100.0, 100.0, false)
		GameManager.stamina_updated.emit(1, 100.0, 100.0, false)
		if AudioManager:
			AudioManager.play_sfx("sister_cheer")
		_show_toast("⚡ ฟื้นฟู Stamina ของพี่น้องทั้งสองคนเต็ม 100%!")
	
	elif cmd in ["@help", "/help", "@?", "/?"]:
		_show_command_help()
	
	else:
		_show_toast("❓ ไม่รู้จักคำสั่ง '%s' (กด ? หรือพิมพ์ @help เพื่อดูวิธีใช้)" % cmd)

func _show_command_help() -> void:
	var help_text := "🎮 คอนโซลคำสั่ง & สูตรลัด (Cheat Console):\n" \
		+ "• @map 1 ถึง @map 12 : วาปไปยังฉากที่ต้องการทันที (เช่น @map 1, @map 7)\n" \
		+ "• @map 2.5 : วาปไปศาลาป้ายรอขึ้นรถเมล์\n" \
		+ "• @pass : ปลดล็อกเควสและเปิดประตูผ่านฉากปัจจุบันทันที\n" \
		+ "• @money <จำนวน> : เพิ่มเงินค่าขนม (เช่น @money 50)\n" \
		+ "• @star <จำนวน> : เพิ่มดาวมารยาท (เช่น @star 10)\n" \
		+ "• @item <ชื่อไอเทม> : เสกไอเทมใส่กระเป๋า (เช่น @item บัวรดน้ำ)\n" \
		+ "• @heal : เติม Stamina เต็ม 100%\n" \
		+ "💡 กดปุ่ม [/] เพื่อเปิดช่องพิมพ์ด่วนได้ตลอดเวลา!"
	GameManager.dialog_triggered.emit("ระบบสูตรเกม & วาปฉาก", help_text, "")
