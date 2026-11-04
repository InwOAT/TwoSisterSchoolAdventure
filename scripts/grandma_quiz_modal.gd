extends CanvasLayer
class_name GrandmaQuizModal

signal quiz_completed

@onready var backdrop: ColorRect = $Backdrop
@onready var panel: Panel = $Panel
@onready var feedback_label: Label = $Panel/Margin/VBox/ExplanationBox/FeedbackLabel

@onready var btn_a: Button = $Panel/Margin/VBox/ChoicesGrid/BtnChoiceA
@onready var btn_b: Button = $Panel/Margin/VBox/ChoicesGrid/BtnChoiceB
@onready var btn_c: Button = $Panel/Margin/VBox/ChoicesGrid/BtnChoiceC

@onready var btn_close: Button = $Panel/Margin/VBox/HeaderHBox/BtnClose
@onready var btn_close_bottom: Button = $Panel/Margin/VBox/Actions/BtnCloseBottom

var is_completed: bool = false

func _ready() -> void:
	visible = false
	btn_a.pressed.connect(func(): _on_choose(0))
	btn_b.pressed.connect(func(): _on_choose(1))
	btn_c.pressed.connect(func(): _on_choose(2))

	btn_close.pressed.connect(close_quiz)
	btn_close_bottom.pressed.connect(close_quiz)

func open_quiz() -> void:
	is_completed = false
	btn_a.disabled = false
	btn_b.disabled = false
	btn_c.disabled = false
	btn_close_bottom.text = "✕ ปิดหน้าต่าง [Esc]"
	feedback_label.text = "💡 คำแนะนำ: เลือกคำตอบที่ถูกต้องเพื่อบอกทางคุณยายขึ้นรถไปโรงพยาบาลได้อย่างปลอดภัย"
	feedback_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.75))
	visible = true

func close_quiz() -> void:
	if AudioManager:
		AudioManager.play_sfx("ui_click")
	visible = false

func _on_choose(idx: int) -> void:
	if is_completed:
		return

	if idx == 1:
		# CORRECT ANSWER: Green bus to hospital!
		is_completed = true
		btn_a.disabled = true
		btn_c.disabled = true
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("sister_cheer")

		GameManager.complete_good_deed("q_terminal_grandma")
		GameManager.add_star()

		feedback_label.text = "🎉 ถูกต้องแล้วจ้า! รถสองแถวสีเขียวชานชาลา 2 ไปโรงพยาบาลชุมชนหนองเรือ คุณยายขอบใจหนูๆ มากนะจ๊ะ! 💖 ⭐ (+1 ดาวความดี)"
		feedback_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
		btn_close_bottom.text = "✅ สำเร็จเรียบร้อย [กด Enter หรือคลิกเพื่อปิด]"

		quiz_completed.emit()
	elif idx == 0:
		# Wrong: Red bus to market
		if AudioManager:
			AudioManager.play_sfx("wrong")
		feedback_label.text = "❌ ยังไม่ใช่จ้า! รถสีแดงชานชาลา 1 ไปตลาดสดเทศบาล คุณยายต้องการไปหาหมอที่โรงพยาบาลจ้ะ ลองดูใหม่อีกทีนะ!"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.45))
	elif idx == 2:
		# Wrong: Blue bus to school
		if AudioManager:
			AudioManager.play_sfx("wrong")
		feedback_label.text = "❌ ยังไม่ใช่จ้า! รถสีฟ้าชานชาลา 3 คันนี้ไปโรงเรียนของพวกเราจ้ะ คุณยายต้องไปโรงพยาบาลชุมชน ลองดูใหม่อีกทีนะ!"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.45))

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return

	var key := event as InputEventKey
	match key.keycode:
		KEY_1, KEY_KP_1, KEY_A:
			_on_choose(0)
		KEY_2, KEY_KP_2, KEY_B:
			_on_choose(1)
		KEY_3, KEY_KP_3, KEY_C:
			_on_choose(2)
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			if is_completed:
				close_quiz()
		KEY_ESCAPE:
			close_quiz()
