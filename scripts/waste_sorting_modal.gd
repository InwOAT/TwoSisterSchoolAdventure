extends CanvasLayer
class_name WasteSortingModal

signal sorting_completed

@onready var backdrop: ColorRect = $Backdrop
@onready var panel: Panel = $Panel
@onready var progress_badge: Label = $Panel/Margin/VBox/HeaderHBox/ProgressBadge
@onready var btn_close: Button = $Panel/Margin/VBox/HeaderHBox/BtnClose

# Item card
@onready var item_icon_lbl: Label = $Panel/Margin/VBox/ItemCard/ItemVBox/ItemTitle
@onready var item_desc_lbl: Label = $Panel/Margin/VBox/ItemCard/ItemVBox/ItemDesc

# 3 Bin buttons
@onready var btn_green: Button = $Panel/Margin/VBox/BinsGrid/BtnGreen
@onready var btn_yellow: Button = $Panel/Margin/VBox/BinsGrid/BtnYellow
@onready var btn_blue: Button = $Panel/Margin/VBox/BinsGrid/BtnBlue

# Explanation / Feedback
@onready var feedback_panel: PanelContainer = $Panel/Margin/VBox/ExplanationBox
@onready var feedback_label: Label = $Panel/Margin/VBox/ExplanationBox/Margin/FeedbackLabel
@onready var btn_next: Button = $Panel/Margin/VBox/Actions/BtnNext

const QUESTIONS: Array[Dictionary] = [
	{
		"item_title": "🍌 เศษอาหาร & เปลือกกล้วยน้ำว้า",
		"item_desc": "เศษข้าว ผัก และเปลือกผลไม้ที่ทานเหลือจากมื้ออาหารกลางวัน",
		"correct_bin": 0, # 0 = Green, 1 = Yellow, 2 = Blue
		"correct_name": "🟢 ถังสีเขียว - ขยะเปียก / เศษอาหาร",
		"exp_correct": "🎉 ถูกต้องยอดเยี่ยม! เศษอาหารและเปลือกผลไม้ เป็นขยะอินทรีย์ที่ย่อยสลายได้ตามธรรมชาติ ทางโรงเรียนจะนำไปหมักทำปุ๋ยอินทรีย์ชีวภาพรดน้ำต้นไม้ในแปลงเกษตรจ้ะ 🌱✨",
		"exp_wrong": "❌ ยังไม่ถูกต้องนะจ๊ะ!\n💡 เฉลย: \"เศษอาหาร & เปลือกผลไม้\" ต้องทิ้งลง 🟢 [ถังสีเขียว - ขยะเปียก]\nเพราะเป็นสารอินทรีย์ที่เน่าเสียและย่อยสลายได้ง่าย นำไปหมักเป็นปุ๋ยบำรุงดินได้ ไม่ควรทิ้งปนกับขยะแห้งหรือขวดรีไซเคิลจ้ะ"
	},
	{
		"item_title": "🧴 ขวดน้ำดื่มพลาสติกใส (PET) & กระป๋องอลูมิเนียม",
		"item_desc": "ขวดน้ำดื่มสะอาดที่ดื่มหมดแล้ว และกระป๋องเครื่องดื่ม",
		"correct_bin": 1, # Yellow
		"correct_name": "🟡 ถังสีเหลือง - ขยะรีไซเคิล",
		"exp_correct": "🎉 เก่งมากจ้ะ! ถูกต้องแล้ว! ขวดพลาสติกใส PET และกระป๋อง สามารถนำไปคัดแยก ล้างทำความสะอาด แล้วหลอมแปรรูป (Recycle) นำกลับมาใช้ใหม่ได้ ช่วยประหยัดทรัพยากรโลก ♻️🌟",
		"exp_wrong": "❌ ยังไม่ถูกต้องนะจ๊ะ!\n💡 เฉลย: \"ขวดพลาสติกใส & กระป๋อง\" ต้องทิ้งลง 🟡 [ถังสีเหลือง - ขยะรีไซเคิล]\nเพราะเป็นวัสดุที่สะอาด สามารถนำไปหลอมแปรรูปกลับมาใช้ใหม่ได้ ช่วยลดปริมาณขยะตกค้างในโรงเรียนจ้ะ"
	},
	{
		"item_title": "🍟 ซองขนมขบเคี้ยวฟอยล์ & หลอดดูดพลาสติก",
		"item_desc": "ซองขนมกรุบกรอบที่มีฟอยล์ด้านใน และหลอดดูดน้ำพลาสติกเปื้อนคราบน้ำหวาน",
		"correct_bin": 2, # Blue
		"correct_name": "🔵 ถังสีน้ำเงิน - ขยะทั่วไป",
		"exp_correct": "🎉 เก่งสุดๆ! ถูกต้องจ้ะ! ซองขนมฟอยล์เป็นพลาสติกผสมอะลูมิเนียมหลายชั้น และหลอดเปื้อน เป็นขยะที่รีไซเคิลไม่ได้และย่อยสลายยาก จึงต้องทิ้งลงถังขยะทั่วไปเพื่อนำไปกำจัดอย่างถูกสุขลักษณะ 🗑️👍",
		"exp_wrong": "❌ ยังไม่ถูกต้องนะจ๊ะ!\n💡 เฉลย: \"ซองขนมฟอยล์ & หลอดพลาสติกเปื้อน\" ต้องทิ้งลง 🔵 [ถังสีน้ำเงิน - ขยะทั่วไป]\nเพราะเป็นขยะที่รีไซเคิลไม่ได้และย่อยสลายยากมาก ต้องรวบรวมส่งไปกำจัดด้วยการฝังกลบหรือแปรรูปเป็นพลังงานเชื้อเพลิงอย่างถูกวิธีจ้ะ"
	}
]

const BIN_BASE_TEXTS: Array[String] = [
	"🟢 ถังสีเขียว\nขยะเปียก / เศษอาหาร\n(ย่อยสลายได้ง่าย / หมักปุ๋ย)\n[กด 1]",
	"🟡 ถังสีเหลือง\nขยะรีไซเคิล\n(ขวด/กระป๋อง/กระดาษสะอาด)\n[กด 2]",
	"🔵 ถังสีน้ำเงิน\nขยะทั่วไป\n(ซองฟอยล์/หลอด/ย่อยยาก)\n[กด 3]"
]

var current_idx: int = 0
var has_answered_current: bool = false
var is_all_completed: bool = false

var _style_green_default: StyleBox
var _style_yellow_default: StyleBox
var _style_blue_default: StyleBox
var _style_bin_correct: StyleBoxFlat
var _style_bin_wrong: StyleBoxFlat

func _ready() -> void:
	visible = false
	_style_green_default = btn_green.get_theme_stylebox("normal")
	_style_yellow_default = btn_yellow.get_theme_stylebox("normal")
	_style_blue_default = btn_blue.get_theme_stylebox("normal")
	_setup_button_styles()
	
	btn_green.pressed.connect(func(): _on_choose_bin(0))
	btn_yellow.pressed.connect(func(): _on_choose_bin(1))
	btn_blue.pressed.connect(func(): _on_choose_bin(2))
	
	btn_next.pressed.connect(_on_next_pressed)
	btn_close.pressed.connect(close_modal)

func _setup_button_styles() -> void:
	_style_bin_correct = StyleBoxFlat.new()
	_style_bin_correct.bg_color = Color(0.06, 0.38, 0.18, 0.98)
	_style_bin_correct.border_color = Color(0.2, 1.0, 0.5, 1.0)
	_style_bin_correct.set_border_width_all(4)
	_style_bin_correct.set_corner_radius_all(10)
	_style_bin_correct.shadow_color = Color(0.2, 1.0, 0.5, 0.4)
	_style_bin_correct.shadow_size = 8
	
	_style_bin_wrong = StyleBoxFlat.new()
	_style_bin_wrong.bg_color = Color(0.42, 0.1, 0.1, 0.98)
	_style_bin_wrong.border_color = Color(1.0, 0.28, 0.25, 1.0)
	_style_bin_wrong.set_border_width_all(4)
	_style_bin_wrong.set_corner_radius_all(10)
	_style_bin_wrong.shadow_color = Color(1.0, 0.25, 0.25, 0.4)
	_style_bin_wrong.shadow_size = 8

func open_modal() -> void:
	current_idx = 0
	has_answered_current = false
	is_all_completed = false
	_load_question(0)
	visible = true

func close_modal() -> void:
	if AudioManager:
		AudioManager.play_sfx("ui_click")
	visible = false

func _load_question(idx: int) -> void:
	if idx >= QUESTIONS.size():
		_finish_all_sorting()
		return
	
	current_idx = idx
	has_answered_current = false
	var q = QUESTIONS[idx]
	
	progress_badge.text = "ชิ้นที่ %d / %d" % [idx + 1, QUESTIONS.size()]
	item_icon_lbl.text = q["item_title"]
	item_desc_lbl.text = q["item_desc"]
	
	# Reset buttons to default styles, text and modulate
	_reset_bin_button(btn_green, _style_green_default, BIN_BASE_TEXTS[0])
	_reset_bin_button(btn_yellow, _style_yellow_default, BIN_BASE_TEXTS[1])
	_reset_bin_button(btn_blue, _style_blue_default, BIN_BASE_TEXTS[2])
	
	feedback_label.text = "💡 คำแนะนำ: พิจารณาประเภทวัสดุของขยะชิ้นนี้ แล้วกดเลือกถังขยะสีที่ถูกต้อง (หรือกดแป้นพิมพ์ [1], [2], [3])"
	feedback_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	
	btn_next.visible = false

func _reset_bin_button(btn: Button, def_style: StyleBox, base_text: String) -> void:
	btn.disabled = false
	btn.text = base_text
	btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if def_style:
		btn.add_theme_stylebox_override("normal", def_style)
		btn.add_theme_stylebox_override("disabled", def_style)
	else:
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("disabled")
	btn.remove_theme_stylebox_override("hover")
	btn.remove_theme_stylebox_override("pressed")

func _on_choose_bin(bin_idx: int) -> void:
	if has_answered_current or is_all_completed:
		return
	
	has_answered_current = true
	var q = QUESTIONS[current_idx]
	var correct_bin: int = q["correct_bin"]
	var is_correct: bool = (bin_idx == correct_bin)
	
	var chosen_btn := _get_bin_button(bin_idx)
	var correct_btn := _get_bin_button(correct_bin)
	
	# Dim all buttons initially
	btn_green.modulate = Color(0.5, 0.5, 0.5, 0.6)
	btn_yellow.modulate = Color(0.5, 0.5, 0.5, 0.6)
	btn_blue.modulate = Color(0.5, 0.5, 0.5, 0.6)
	
	btn_green.disabled = true
	btn_yellow.disabled = true
	btn_blue.disabled = true
	
	if is_correct:
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("recycle")
		
		chosen_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		chosen_btn.add_theme_stylebox_override("normal", _style_bin_correct)
		chosen_btn.add_theme_stylebox_override("disabled", _style_bin_correct)
		chosen_btn.text = BIN_BASE_TEXTS[bin_idx] + "\n[🎉 ถูกต้อง 100%!]"
		
		feedback_label.text = q["exp_correct"]
		feedback_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	else:
		if AudioManager:
			AudioManager.play_sfx("wrong")
		
		# Chosen wrong button
		chosen_btn.modulate = Color(1.0, 0.85, 0.85, 1.0)
		chosen_btn.add_theme_stylebox_override("normal", _style_bin_wrong)
		chosen_btn.add_theme_stylebox_override("disabled", _style_bin_wrong)
		chosen_btn.text = BIN_BASE_TEXTS[bin_idx] + "\n[❌ ทิ้งถังนี้ผิด]"
		
		# Correct button highlight
		correct_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		correct_btn.add_theme_stylebox_override("normal", _style_bin_correct)
		correct_btn.add_theme_stylebox_override("disabled", _style_bin_correct)
		correct_btn.text = BIN_BASE_TEXTS[correct_bin] + "\n[✅ เฉลย: ถังที่ถูกต้อง!]"
		
		feedback_label.text = q["exp_wrong"]
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	
	# Show Next button
	btn_next.visible = true
	if current_idx + 1 < QUESTIONS.size():
		btn_next.text = "➔ ไปทิ้งขยะชิ้นถัดไป (%d/%d) [กด Enter]" % [current_idx + 2, QUESTIONS.size()]
	else:
		btn_next.text = "✨ เสร็จสิ้นการคัดแยกขยะ 3 สี! [กด Enter]"

func _get_bin_button(idx: int) -> Button:
	match idx:
		0: return btn_green
		1: return btn_yellow
		_: return btn_blue

func _on_next_pressed() -> void:
	if not has_answered_current:
		return
	
	if current_idx + 1 < QUESTIONS.size():
		_load_question(current_idx + 1)
	else:
		_finish_all_sorting()

func _finish_all_sorting() -> void:
	is_all_completed = true
	visible = false
	
	if not GameManager.waste_sorted_ok:
		GameManager.waste_sorted_ok = true
		GameManager.complete_good_deed("q_canteen_clean")
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("sister_cheer")
			AudioManager.play_sfx("star")
	
	sorting_completed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	
	var key := event as InputEventKey
	if not has_answered_current:
		match key.keycode:
			KEY_1, KEY_KP_1, KEY_A:
				_on_choose_bin(0)
			KEY_2, KEY_KP_2, KEY_B:
				_on_choose_bin(1)
			KEY_3, KEY_KP_3, KEY_C:
				_on_choose_bin(2)
			KEY_ESCAPE:
				close_modal()
	else:
		match key.keycode:
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_on_next_pressed()
			KEY_ESCAPE:
				close_modal()
