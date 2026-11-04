extends CanvasLayer
class_name SmartPurseModal

@onready var backdrop: ColorRect = $Backdrop
@onready var panel: Panel = $Panel
@onready var target_badge: Label = $Panel/Margin/VBox/HeaderHBox/TargetBadge
@onready var title_label: Label = $Panel/Margin/VBox/QuestCard/HBox/VBoxText/TitleLabel
@onready var subtitle_label: Label = $Panel/Margin/VBox/QuestCard/HBox/VBoxText/SubTitleLabel
@onready var current_label: Label = $Panel/Margin/VBox/TrayPanel/VBoxTray/TrayHeader/CurrentLabel
@onready var status_badge: Label = $Panel/Margin/VBox/TrayPanel/VBoxTray/TrayHeader/StatusBadge
@onready var tray_items: HBoxContainer = $Panel/Margin/VBox/TrayPanel/VBoxTray/TrayScroll/TrayItems
@onready var empty_placeholder: Label = $Panel/Margin/VBox/TrayPanel/VBoxTray/TrayScroll/TrayItems/EmptyPlaceholder
@onready var feedback_label: Label = $Panel/Margin/VBox/ExplanationBox/FeedbackLabel

@onready var btn_c1: Button = $Panel/Margin/VBox/CoinsGrid/BtnCoin1
@onready var btn_c2: Button = $Panel/Margin/VBox/CoinsGrid/BtnCoin2
@onready var btn_c5: Button = $Panel/Margin/VBox/CoinsGrid/BtnCoin5
@onready var btn_c10: Button = $Panel/Margin/VBox/CoinsGrid/BtnCoin10
@onready var btn_n20: Button = $Panel/Margin/VBox/CoinsGrid/BtnNote20

@onready var btn_undo: Button = $Panel/Margin/VBox/TrayPanel/VBoxTray/TrayHeader/BtnUndo
@onready var btn_reset: Button = $Panel/Margin/VBox/TrayPanel/VBoxTray/TrayHeader/BtnReset
@onready var btn_confirm: Button = $Panel/Margin/VBox/Actions/BtnConfirm
@onready var btn_cancel: Button = $Panel/Margin/VBox/Actions/BtnCancel
@onready var btn_close: Button = $Panel/Margin/VBox/HeaderHBox/BtnClose

var target_amount: int = 16
var current_sum: int = 0
var coins_tray: Array[int] = []
var on_success_callback: Callable

func _ready() -> void:
	visible = false
	GameManager.purse_opened.connect(_open_purse)

	btn_c1.pressed.connect(func(): _add_money(1))
	btn_c2.pressed.connect(func(): _add_money(2))
	btn_c5.pressed.connect(func(): _add_money(5))
	btn_c10.pressed.connect(func(): _add_money(10))
	btn_n20.pressed.connect(func(): _add_money(20))

	btn_undo.pressed.connect(_undo_money)
	btn_reset.pressed.connect(_reset_money)
	btn_confirm.pressed.connect(_on_confirm)
	btn_cancel.pressed.connect(_close_purse)
	btn_close.pressed.connect(_close_purse)

func _open_purse(target: int, title_text: String, callback: Callable) -> void:
	target_amount = target
	current_sum = 0
	coins_tray.clear()
	on_success_callback = callback
	
	title_label.text = "ภารกิจ: " + title_text
	target_badge.text = "🎯 ยอดที่ต้องจ่าย: %d บาท" % target_amount
	subtitle_label.text = "เลือกเหรียญรวมให้ได้ %d บาท หรือจ่ายธนบัตร 20 บาทเพื่อรอรับเงินทอนจ้ะ!" % target_amount
	
	_update_ui()
	visible = true

func _close_purse() -> void:
	if AudioManager:
		AudioManager.play_sfx("ui_click")
	visible = false

func _add_money(val: int) -> void:
	if AudioManager:
		AudioManager.play_sfx("coin", randf_range(0.95, 1.08))
	coins_tray.append(val)
	current_sum += val
	_update_ui()

func _undo_money() -> void:
	if coins_tray.is_empty():
		return
	if AudioManager:
		AudioManager.play_sfx("ui_click")
	var removed: int = coins_tray.pop_back()
	current_sum -= removed
	_update_ui()

func _reset_money() -> void:
	if AudioManager:
		AudioManager.play_sfx("ui_click")
	coins_tray.clear()
	current_sum = 0
	feedback_label.text = "💡 ล้างถาดเงินเรียบร้อยแล้ว เริ่มหยอดใหม่ได้เลยจ้า"
	feedback_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	_update_ui()

func _update_ui() -> void:
	current_label.text = "%d บาท" % current_sum

	# Refresh visual coin chips in tray
	for c in tray_items.get_children():
		if c != empty_placeholder:
			c.queue_free()

	if coins_tray.is_empty():
		empty_placeholder.visible = true
		status_badge.text = "(ยังไม่ได้ใส่เงิน)"
		status_badge.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		current_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		feedback_label.text = "💡 คำแนะนำ: เลือกเหรียญหรือธนบัตรใส่ถาดให้ได้ %d บาท หรือจ่ายธนบัตร 20 บาท (กดปุ่มลัด [1], [2], [5], [0], [N] ได้)" % target_amount
		feedback_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.75))
		btn_confirm.modulate = Color(0.85, 0.85, 0.85)
		return

	empty_placeholder.visible = false

	# Add chip badges into tray
	for val in coins_tray:
		var chip := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(1)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4

		var chip_label := Label.new()
		chip_label.add_theme_font_size_override("font_size", 12)

		if val == 20:
			sb.bg_color = Color(0.12, 0.42, 0.28, 0.95)
			sb.border_color = Color(0.45, 0.95, 0.65, 1.0)
			chip_label.text = "💵 20 บ."
			chip_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.92))
		elif val == 10:
			sb.bg_color = Color(0.42, 0.34, 0.12, 0.98)
			sb.border_color = Color(1.0, 0.9, 0.42, 1.0)
			chip_label.text = "🪙 10 บ."
			chip_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
		elif val == 5:
			sb.bg_color = Color(0.25, 0.34, 0.45, 0.95)
			sb.border_color = Color(0.65, 0.85, 1.0, 0.95)
			chip_label.text = "🪙 5 บ."
			chip_label.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0))
		elif val == 2:
			sb.bg_color = Color(0.38, 0.3, 0.14, 0.95)
			sb.border_color = Color(0.95, 0.82, 0.35, 0.95)
			chip_label.text = "🪙 2 บ."
			chip_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75))
		else:
			sb.bg_color = Color(0.2, 0.28, 0.36, 0.95)
			sb.border_color = Color(0.7, 0.82, 0.92, 0.9)
			chip_label.text = "🪙 1 บ."
			chip_label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0))

		chip.add_theme_stylebox_override("panel", sb)
		chip.add_child(chip_label)
		tray_items.add_child(chip)

	# State validation
	if current_sum == target_amount:
		current_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
		status_badge.text = "🎉 พอดีเป๊ะ! (16 บาท)"
		status_badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
		feedback_label.text = "🎉 ยอดเงินครบ 16 บาทพอดีเป๊ะ! กดปุ่ม [ยืนยันจ่ายเงิน] เพื่อชำระค่าโดยสารได้เลยจ้า"
		feedback_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
		btn_confirm.modulate = Color(1.15, 1.15, 1.15)
	elif target_amount == 16 and current_sum == 20:
		current_label.add_theme_color_override("font_color", Color(0.45, 0.95, 1.0))
		status_badge.text = "💵 ธนบัตร 20 บาท (รอรับเงินทอน 4 บาท)"
		status_badge.add_theme_color_override("font_color", Color(0.45, 0.95, 1.0))
		feedback_label.text = "💡 จ่ายด้วยธนบัตร 20 บาท รับเงินทอน 4 บาท ถูกต้องและฉลาดมากจ้า! กด [ยืนยันจ่ายเงิน] ได้เลย"
		feedback_label.add_theme_color_override("font_color", Color(0.45, 0.95, 1.0))
		btn_confirm.modulate = Color(1.15, 1.15, 1.15)
	elif current_sum < target_amount:
		var diff: int = target_amount - current_sum
		current_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		status_badge.text = "⏳ ยังขาดอีก %d บาท" % diff
		status_badge.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		feedback_label.text = "⏳ ยังขาดอีก %d บาทนะจ๊ะ (ต้องการ %d บาท ตอนนี้มี %d บาท)" % [diff, target_amount, current_sum]
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_confirm.modulate = Color(0.85, 0.85, 0.85)
	else:
		var excess: int = current_sum - target_amount
		current_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
		status_badge.text = "⚠️ เงินเกินมา %d บาท" % excess
		status_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
		feedback_label.text = "⚠️ เงินเกินเป้าหมาย %d บาทนะจ๊ะ (ต้องการ %d บาท ตอนนี้ใส่มา %d บาท) กด [ลบเหรียญล่าสุด] เพื่อปรับยอดนะ" % [excess, target_amount, current_sum]
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
		btn_confirm.modulate = Color(0.85, 0.85, 0.85)

func _on_confirm() -> void:
	if current_sum == target_amount or (target_amount == 16 and current_sum == 20):
		if AudioManager:
			AudioManager.play_sfx("correct")
		visible = false
		if on_success_callback.is_valid():
			on_success_callback.call()
	elif current_sum < target_amount:
		if AudioManager:
			AudioManager.play_sfx("wrong")
		var diff: int = target_amount - current_sum
		feedback_label.text = "ยังขาดอีก %d บาทนะจ๊ะ กรุณาเลือกเหรียญเพิ่มให้ครบ %d บาทก่อนนะ!" % [diff, target_amount]
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		if AudioManager:
			AudioManager.play_sfx("wrong")
		var excess: int = current_sum - target_amount
		feedback_label.text = "เงินเกินมา %d บาทนะจ๊ะ (ต้องการ %d บาท) กรุณากด [ลบเหรียญล่าสุด] จ้า!" % [excess, target_amount]
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return

	var key := event as InputEventKey
	match key.keycode:
		KEY_1, KEY_KP_1:
			_add_money(1)
		KEY_2, KEY_KP_2:
			_add_money(2)
		KEY_5, KEY_KP_5:
			_add_money(5)
		KEY_0, KEY_KP_0:
			_add_money(10)
		KEY_N, KEY_4, KEY_KP_4, KEY_T:
			_add_money(20)
		KEY_BACKSPACE, KEY_Z:
			_undo_money()
		KEY_R:
			_reset_money()
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			_on_confirm()
		KEY_ESCAPE:
			_close_purse()
