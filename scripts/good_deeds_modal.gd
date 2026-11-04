extends CanvasLayer
class_name GoodDeedsModal

@onready var panel: Panel = $Panel
@onready var points_label: Label = $Panel/VBox/SummaryPanel/HBox/PointsLabel
@onready var title_badge: Label = $Panel/VBox/SummaryPanel/HBox/TitleBadge
@onready var progress_bar: ProgressBar = $Panel/VBox/SummaryPanel/HBox/ProgressContainer/ProgressBar
@onready var progress_label: Label = $Panel/VBox/SummaryPanel/HBox/ProgressContainer/ProgressLabel

@onready var quest_container: VBoxContainer = $Panel/VBox/Scroll/QuestListContainer
@onready var btn_close: Button = $Panel/VBox/Header/BtnClose

# Category Buttons
@onready var btn_all: Button = $Panel/VBox/FilterBar/BtnAll
@onready var btn_family: Button = $Panel/VBox/FilterBar/BtnFamily
@onready var btn_errand: Button = $Panel/VBox/FilterBar/BtnErrand
@onready var btn_teacher: Button = $Panel/VBox/FilterBar/BtnTeacher
@onready var btn_friend: Button = $Panel/VBox/FilterBar/BtnFriend

var current_filter: String = "ทั้งหมด"

func _ready() -> void:
	panel.visible = false
	GameManager.good_deeds_modal_toggled.connect(toggle_modal)
	GameManager.good_deed_updated.connect(_on_good_deed_updated)
	
	if btn_close:
		btn_close.pressed.connect(func():
			panel.visible = false
			if get_viewport(): get_viewport().gui_release_focus()
		)
	
	if btn_all: btn_all.pressed.connect(func(): _set_filter("ทั้งหมด"))
	if btn_family: btn_family.pressed.connect(func(): _set_filter("🏡 งานบ้าน"))
	if btn_errand: btn_errand.pressed.connect(func(): _set_filter("🛒 ซื้อของ"))
	if btn_teacher: btn_teacher.pressed.connect(func(): _set_filter("👩‍🏫 ช่วยครู"))
	if btn_friend: btn_friend.pressed.connect(func(): _set_filter("🤝 ช่วยเพื่อน"))

	_refresh_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_good_deeds"):
		toggle_modal()
	elif panel.visible and event.is_action_pressed("ui_cancel"):
		panel.visible = false
		if get_viewport(): get_viewport().gui_release_focus()

func toggle_modal() -> void:
	panel.visible = not panel.visible
	if panel.visible:
		_refresh_ui()

func _set_filter(category: String) -> void:
	current_filter = category
	_refresh_ui()

func _on_good_deed_updated(_quest_id: String, _points_gained: int, _total_points: int, _title: String) -> void:
	if panel.visible:
		_refresh_ui()

func _refresh_ui() -> void:
	if not points_label:
		return
	
	var total_pts := GameManager.good_deed_points
	var current_title := GameManager.get_good_deed_title()
	var next_target := GameManager.get_next_title_target()
	
	points_label.text = "💖 แต้มความดี: %d แต้ม" % total_pts
	title_badge.text = "🎖️ ฉายา: " + current_title
	
	if progress_bar:
		progress_bar.max_value = next_target
		progress_bar.value = total_pts
	if progress_label:
		progress_label.text = "%d / %d แต้มสู่ระดับถัดไป" % [total_pts, next_target]
	
	_populate_quests()

func _populate_quests() -> void:
	if not quest_container:
		return
	
	for child in quest_container.get_children():
		child.queue_free()
	
	for q_id in GameManager.good_deeds.keys():
		var q: Dictionary = GameManager.good_deeds[q_id]
		var cat: String = q.get("category", "")
		
		if current_filter != "ทั้งหมด" and not cat.begins_with(current_filter) and not current_filter in cat:
			continue
		
		var card := _create_quest_card(q)
		quest_container.add_child(card)

func _create_quest_card(q: Dictionary) -> PanelContainer:
	var panel_card := PanelContainer.new()
	panel_card.custom_minimum_size = Vector2(0, 72)
	
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	
	var is_completed: bool = (str(q.get("status", "")) == "completed")
	var is_in_progress: bool = (str(q.get("status", "")) == "in_progress")
	
	if is_completed:
		style.bg_color = Color(0.12, 0.28, 0.16, 0.9)
		style.border_color = Color(0.3, 0.8, 0.4, 1.0)
	elif is_in_progress:
		style.bg_color = Color(0.28, 0.22, 0.1, 0.9)
		style.border_color = Color(0.9, 0.7, 0.2, 1.0)
	else:
		style.bg_color = Color(0.15, 0.15, 0.18, 0.85)
		style.border_color = Color(0.35, 0.35, 0.4, 0.6)
	
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	panel_card.add_theme_stylebox_override("panel", style)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	panel_card.add_child(hbox)

	# Status Indicator
	var status_label := Label.new()
	status_label.custom_minimum_size = Vector2(100, 0)
	if is_completed:
		status_label.text = "✅ สำเร็จแล้ว"
		status_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	elif is_in_progress:
		status_label.text = "⏳ กำลังทำ"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		status_label.text = "🔒 รอรับเควส"
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	status_label.add_theme_font_size_override("font_size", 13)
	hbox.add_child(status_label)

	# Quest Details VBox
	var vbox_details := VBoxContainer.new()
	vbox_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_details.add_theme_constant_override("separation", 3)
	hbox.add_child(vbox_details)
	
	var title_lbl := Label.new()
	title_lbl.text = q.get("title", "") + " (" + q.get("category", "") + ")"
	title_lbl.add_theme_font_size_override("font_size", 14)
	if is_completed:
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	else:
		title_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox_details.add_child(title_lbl)
	
	var desc_lbl := Label.new()
	desc_lbl.text = q.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.8, 0.85))
	vbox_details.add_child(desc_lbl)
	
	var loc_lbl := Label.new()
	loc_lbl.text = "📍 " + q.get("location", "") + " | ผู้ว่าจ้าง: " + q.get("npc", "")
	loc_lbl.add_theme_font_size_override("font_size", 10)
	loc_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox_details.add_child(loc_lbl)
	
	# Reward Label
	var reward_lbl := Label.new()
	reward_lbl.custom_minimum_size = Vector2(160, 0)
	reward_lbl.text = "🎁 " + q.get("reward", "")
	reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	reward_lbl.add_theme_font_size_override("font_size", 11)
	reward_lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	hbox.add_child(reward_lbl)
	
	return panel_card
