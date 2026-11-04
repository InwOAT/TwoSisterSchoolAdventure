extends CanvasLayer
class_name DialogModal

@onready var panel: Panel = $Panel
@onready var portrait_tex: TextureRect = $Panel/HBox/PortraitFrame/PortraitTex
@onready var speaker_label: Label = $Panel/HBox/VBox/TopRow/SpeakerLabel
@onready var content_label: Label = $Panel/HBox/VBox/ContentLabel
@onready var btn_close: Button = $Panel/HBox/VBox/BtnClose

var opened_frame: int = -1
var _type_tween: Tween = null

func _ready() -> void:
	panel.visible = false
	GameManager.dialog_triggered.connect(_show_dialog)
	if btn_close:
		btn_close.pressed.connect(_on_close_pressed)

func _input(event: InputEvent) -> void:
	if not panel.visible:
		return
	# Prevent closing on the exact same frame the dialog was opened by [E / Space]
	if Engine.get_process_frames() <= opened_frame + 1:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("p1_interact") or event.is_action_pressed("p2_interact") or event.is_action_pressed("ui_cancel"):
		if content_label and content_label.visible_ratio < 0.95:
			if _type_tween and _type_tween.is_valid():
				_type_tween.kill()
			content_label.visible_ratio = 1.0
			get_viewport().set_input_as_handled()
			return
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func _show_dialog(speaker: String, text: String, portrait_path: String = "") -> void:
	opened_frame = Engine.get_process_frames()
	speaker_label.text = "💬 " + speaker
	content_label.text = text
	_update_portrait(speaker, text, portrait_path)
	panel.visible = true

	# Smooth typewriter reveal
	if _type_tween and _type_tween.is_valid():
		_type_tween.kill()
	content_label.visible_ratio = 0.0
	var dur := clampf(float(text.length()) * 0.011, 0.16, 0.68)
	_type_tween = create_tween()
	_type_tween.tween_property(content_label, "visible_ratio", 1.0, dur)

	# Subtle panel & portrait bounce
	if panel:
		panel.pivot_offset = panel.size * 0.5
		panel.scale = Vector2(0.95, 0.95)
		var p_tw := create_tween()
		p_tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if portrait_tex:
		portrait_tex.pivot_offset = portrait_tex.size * 0.5
		portrait_tex.scale = Vector2(0.84, 0.84)
		var pt_tw := create_tween()
		pt_tw.tween_property(portrait_tex, "scale", Vector2(1.0, 1.0), 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _update_portrait(speaker: String, text: String, portrait_path: String) -> void:
	if not portrait_tex:
		return
	var tex_path := portrait_path
	if tex_path == "":
		var combined := speaker + " " + text
		if "แม่" in speaker and not "แม่ค้า" in speaker:
			tex_path = "res://assets/characters/npcs/portrait_mom.png"
		elif "พ่อ" in speaker:
			tex_path = "res://assets/characters/npcs/portrait_dad.png"
		elif "ตำรวจ" in speaker:
			tex_path = "res://assets/characters/npcs/npc_police.png"
		elif "พยาบาล" in speaker:
			tex_path = "res://assets/characters/npcs/npc_nurse.png"
		elif "หมอ" in speaker:
			tex_path = "res://assets/characters/npcs/npc_doctor.png"
		elif "รปภ" in speaker or "ยาม" in speaker:
			tex_path = "res://assets/characters/npcs/npc_guard.png"
		elif "นายสถานี" in speaker:
			tex_path = "res://assets/characters/npcs/npc_station_master.png"
		elif "กระเป๋ารถเมล์" in speaker or "คนขับ" in speaker:
			tex_path = "res://assets/characters/npcs/portrait_conductor.png"
		elif "หลวงตา" in speaker or "พระ" in speaker:
			tex_path = "res://assets/characters/npcs/npc_monk.png"
		elif "คุณตา" in speaker or ("ตา" in speaker and not "สายตา" in speaker):
			tex_path = "res://assets/characters/npcs/npc_grandpa.png"
		elif "ยาย" in speaker:
			tex_path = "res://assets/characters/npcs/portrait_grandma.png"
		elif "ป้า" in speaker and not "แม่ค้า" in speaker:
			tex_path = "res://assets/characters/npcs/npc_auntie.png"
		elif "ครู" in speaker:
			tex_path = "res://assets/characters/npcs/npc_teacher.png"
		elif "อนุบาล" in speaker:
			tex_path = "res://assets/characters/npcs/npc_kindergarten.png"
		elif "ป.1" in speaker or "นักเรียน" in speaker or "เพื่อน" in speaker:
			tex_path = "res://assets/characters/npcs/npc_student.png"
		elif "แปลกหน้า" in speaker:
			tex_path = "res://assets/characters/npcs/npc_stranger.png"
		elif "แมว" in speaker or "เจ้าส้ม" in speaker:
			tex_path = "res://assets/characters/npcs/npc_cat.png"
		elif "ลุง" in speaker or "แม่ค้า" in speaker or "ไปรษณีย์" in speaker or "สหกรณ์" in speaker:
			tex_path = "res://assets/characters/npcs/npc_vendor.png"
		elif "ปีใหม่" in combined:
			if "ระวัง" in text or "ลืม" in text or "ตกใจ" in text or "แคบ" in text:
				tex_path = "res://assets/characters/peemai/portrait_worried.png"
			else:
				tex_path = "res://assets/characters/peemai/portrait_happy.png"
		else:
			if "ระวัง" in text or "ลืม" in text or "ล็อก" in text or "ยังไม่ได้" in text:
				tex_path = "res://assets/characters/khongkwan/portrait_worried.png"
			else:
				tex_path = "res://assets/characters/khongkwan/portrait_happy.png"

	if ResourceLoader.exists(tex_path):
		portrait_tex.texture = load(tex_path)

func _on_close_pressed() -> void:
	panel.visible = false
	GameManager.dialog_closed.emit()
	var vp := get_viewport()
	if vp:
		vp.gui_release_focus()
