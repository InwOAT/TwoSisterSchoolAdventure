extends CanvasLayer
class_name MapModal

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/HBox/MapContainer/Title
@onready var map_texture: TextureRect = $Panel/HBox/MapContainer/MapTexture
@onready var legend_label: Label = $Panel/HBox/MapContainer/Legend
@onready var quest_header: Label = $Panel/HBox/QuestInfoContainer/QuestHeader
@onready var quest_list_label: Label = $Panel/HBox/QuestInfoContainer/QuestListLabel
@onready var btn_close: Button = $Panel/HBox/QuestInfoContainer/BtnClose

@onready var btn_tab_village: Button = $Panel/HBox/MapContainer/TabContainer/BtnTabVillage
@onready var btn_tab_school: Button = $Panel/HBox/MapContainer/TabContainer/BtnTabSchool

var tex_school: Texture2D = preload("res://assets/ui/school_map.png")
var tex_village: Texture2D = preload("res://assets/ui/village_map.png")

var current_tab: String = "village" # "village" or "school"

func _ready() -> void:
	panel.visible = false
	GameManager.map_toggled.connect(toggle_map)
	if btn_close:
		btn_close.pressed.connect(func():
			panel.visible = false
			if get_viewport(): get_viewport().gui_release_focus()
		)
	
	if btn_tab_village:
		btn_tab_village.pressed.connect(func(): switch_tab("village"))
	if btn_tab_school:
		btn_tab_school.pressed.connect(func(): switch_tab("school"))
	
	_update_view()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_map"):
		toggle_map()
	elif panel.visible and event.is_action_pressed("ui_cancel"):
		panel.visible = false
		if get_viewport(): get_viewport().gui_release_focus()

func toggle_map() -> void:
	panel.visible = not panel.visible
	if panel.visible:
		# Auto select tab based on current level
		if GameManager.current_level in [5, 6, 7, 8]:
			current_tab = "school"
		else:
			current_tab = "village"
		_update_view()

func switch_tab(tab_name: String) -> void:
	current_tab = tab_name
	_update_view()

func _update_view() -> void:
	if not title_label or not map_texture:
		return
	
	if current_tab == "village":
		title_label.text = "🗺️ แผนที่หมู่บ้านตำบลดอนโมง (Don Mong Village Map)"
		map_texture.texture = tex_village
		legend_label.text = "จุดสำคัญ: [1] ป้อมตำรวจ/เทศบาล | [2] ตลาดคลองถม | [3] Lotus's & ร้านชำ | [4] คลินิกหมอ | [5] วัดมงคลนิมิต | [6] ไปรษณีย์"
		quest_header.text = "📋 บันทึกเควสหมู่บ้านตำบลดอนโมง (Village Quests)"
		_update_village_quests()
	else:
		title_label.text = "🗺️ แผนผังโรงเรียนชุมชนหนองเรือ (School Map)"
		map_texture.texture = tex_school
		legend_label.text = "จุดสำคัญ: [4] ห้องสมุด | [13] โรงอาหาร | [14] พยาบาล | [18] สหกรณ์ | [20] ห้องพัสดุ | [22] ศาลปู่ย่า | [23] สนามเด็กเล่น"
		quest_header.text = "📋 บันทึกเควสสำรวจโรงเรียน (School Quests)"
		_update_school_quests()

func _update_village_quests() -> void:
	var q_police = "✅" if GameManager.village_cat_returned else "⏳"
	var q_market = "✅" if GameManager.village_veggies_bought else "⏳"
	var q_shop = "✅" if GameManager.auntie_errand_done else "⏳"
	var q_doctor = "✅" if GameManager.village_doctor_visited else "⏳"
	var q_post = "✅" if GameManager.village_letter_sent else "⏳"
	var q_temple = "✅" if GameManager.village_temple_cleaned else "⏳"
	var q_bus = "✅" if (GameManager.has_item("บัตรนักเรียน") and GameManager.has_item("ร่ม")) else "⏳"
	
	var text = "ภารกิจและการผจญภัยในหมู่บ้านดอนโมง:\n\n"
	text += "%s 1. [ป้อมตำรวจ/เทศบาล] ไปหาตำรวจ: แจ้งเรื่องแมวหลง & วินัยจราจร\n\n" % q_police
	text += "%s 2. [ตลาดนัดคลองถม] ไปจ่ายตลาด: ซื้อผักกาดขาวและแตงกวาให้คุณแม่\n\n" % q_market
	text += "%s 3. [Lotus's & ร้านชำ] ไปซื้อของ: ซื้อนมถั่วเหลืองและไข่ไก่ให้ป้าสมศรี\n\n" % q_shop
	text += "%s 4. [คลินิกหมอดอนโมง] ไปหาหมอ: รับยาวิตามินบำรุงให้คุณยาย\n\n" % q_doctor
	text += "%s 5. [วัดมงคลนิมิต] ทำบุญที่วัด: ไหว้พระและช่วยกวาดลานวัด\n\n" % q_temple
	text += "%s 6. [ไปรษณีย์ไทยดอนโมง] ไปส่งจดหมาย: หยอดส่งจดหมายสำคัญลงตู้แดง\n\n" % q_post
	text += "%s 7. [ป้ายรถเมล์สายหลัก] พกบัตรนักเรียน+ร่ม ขึ้นรถเมล์เดินทางไปโรงเรียน!\n" % q_bus
	
	quest_list_label.text = text

func _update_school_quests() -> void:
	var q_shrine = "✅" if GameManager.grandpa_shrine_paid else "⏳"
	var q1 = "✅" if GameManager.has_item("บัวรดน้ำ") else "⏳"
	var q2 = "✅" if GameManager.has_item("ตำราพฤกษศาสตร์") else "⏳"
	var q3 = "✅" if GameManager.injured_student_helped else "⏳"
	var q4 = "✅" if GameManager.has_item("ปุ๋ยอินทรีย์") else "⏳"
	var q5 = "✅" if GameManager.flowers_bloomed else "⏳"
	
	var text = "ภารกิจสำรวจโรงเรียนชุมชนหนองเรือ:\n\n"
	text += "%s 0. [จุด 22 ศาลปู่-ย่า] ไหว้ขอพรสิ่งศักดิ์สิทธิ์ประจำโรงเรียน\n\n" % q_shrine
	text += "%s 1. [อาคาร 20 ห้องเก็บพัสดุ] น้องปีใหม่มุดช่องลมปลดล็อกเอา 'บัวรดน้ำ'\n\n" % q1
	text += "%s 2. [อาคาร 4 ห้องสมุด] พี่ของขวัญค้นคว้า 'ตำราพฤกษศาสตร์'\n\n" % q2
	text += "%s 3. [จุด 23 สนามเด็กเล่น & 14 พยาบาล] นำยามาช่วยเพื่อนหกล้ม (รับคูปอง 10 ฿)\n\n" % q3
	text += "%s 4. [อาคาร 18 ร้านค้าสหกรณ์] นำคูปองไปซื้อ 'ถุงปุ๋ยอินทรีย์'\n\n" % q4
	text += "%s 5. [จุด 17 สวนริมสระน้ำ] รดน้ำและพรวนดินใส่ปุ๋ยจนแปลงดอกไม้บานสะพรั่ง!\n" % q5
	
	quest_list_label.text = text
