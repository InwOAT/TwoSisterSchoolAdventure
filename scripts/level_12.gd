extends BaseLevel

@onready var portal_bedroom: MaplePortal = $PortalBedroom
@onready var shoe_area: Area2D = $ShoeRackArea
@onready var dad_area: Area2D = $DadArea
@onready var mom_area: Area2D = $MomArea

var near_shoes: bool = false
var near_dad: bool = false
var near_mom: bool = false

var wash_dishes_done: bool = false
var dad_massage_done: bool = false
var shoes_stored: bool = false

func _ready() -> void:
	level_number = 12
	super._ready()

	GameManager.start_good_deed("q_home_evening")

	if shoe_area:
		if GameManager and shoe_area.has_node("PromptLabel"):
			GameManager.style_prompt_label(shoe_area.get_node("PromptLabel"))
		shoe_area.body_entered.connect(func(b): if b.is_in_group("players"): near_shoes = true; $ShoeRackArea/PromptLabel.visible = true)
		shoe_area.body_exited.connect(func(b): if b.is_in_group("players"): near_shoes = false; $ShoeRackArea/PromptLabel.visible = false)

	if dad_area:
		if GameManager and dad_area.has_node("PromptLabel"):
			GameManager.style_prompt_label(dad_area.get_node("PromptLabel"))
		dad_area.body_entered.connect(func(b): if b.is_in_group("players"): near_dad = true; $DadArea/PromptLabel.visible = true)
		dad_area.body_exited.connect(func(b): if b.is_in_group("players"): near_dad = false; $DadArea/PromptLabel.visible = false)

	if mom_area:
		if GameManager and mom_area.has_node("PromptLabel"):
			GameManager.style_prompt_label(mom_area.get_node("PromptLabel"))
		mom_area.body_entered.connect(func(b): if b.is_in_group("players"): near_mom = true; $MomArea/PromptLabel.visible = true)
		mom_area.body_exited.connect(func(b): if b.is_in_group("players"): near_mom = false; $MomArea/PromptLabel.visible = false)

	if portal_bedroom:
		portal_bedroom.target_level = 13
		portal_bedroom.target_spawn_x = 120.0
		_update_portal()

func _process(delta: float) -> void:
	super._process(delta)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	# 1. Shoes & Bags at Shoe Rack (x = 180)
	if near_shoes and interact_pressed:
		if not shoes_stored:
			shoes_stored = true
			if AudioManager:
				AudioManager.play_sfx("footstep")
			var lbl := get_node_or_null("ShoeRackArea/Label") as Label
			if lbl:
				lbl.text = "✅ จัดเก็บรองเท้าเรียบร้อย!"
				lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
			GameManager.dialog_triggered.emit("จัดของเข้าที่", "👟 ถอดรองเท้าจัดเรียงเข้าชั้นวาง และวางกระเป๋านักเรียนเรียบร้อย บ้านน่าอยู่เป็นระเบียบมากจ้ะ!", "")
			_check_chores()
		else:
			GameManager.dialog_triggered.emit("ชั้นวางรองเท้า", "รองเท้าและกระเป๋าจัดเก็บเข้าที่เรียบร้อยแล้วจ้า!", "")

	# 2. Massage Dad on Sofa (x = 410)
	if near_dad and interact_pressed:
		if not dad_massage_done:
			dad_massage_done = true
			GameManager.add_star()
			var lbl := get_node_or_null("DadArea/Label") as Label
			if lbl:
				lbl.text = "✅ นวดหลังให้พ่อแล้ว!"
				lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
			GameManager.dialog_triggered.emit("คุณพ่อ", "💆 ชื่นใจจังเลยลูก! สองพี่น้องมาช่วยบีบนวดไหล่ให้พ่อ พ่อหายเหนื่อยจากการทำงานเป็นปลิดทิ้งเลย กตัญญูและน่ารักมากจ้ะ ❤️ ⭐ ได้รับดาวมารยาท!", "res://assets/characters/npcs/portrait_dad.png")
			_check_chores()
		else:
			GameManager.dialog_triggered.emit("คุณพ่อ", "ขอบใจลูกทั้งสองคนมากนะจ๊ะ ไปช่วยคุณแม่หรือเตรียมตัวขึ้นไปทำการบ้านบนห้องนอนนะ!", "res://assets/characters/npcs/portrait_dad.png")

	# 3. Wash Dishes with Mom at Dining Table/Sink (x = 580)
	if near_mom and interact_pressed:
		if not wash_dishes_done:
			wash_dishes_done = true
			var lbl := get_node_or_null("MomArea/Label") as Label
			if lbl:
				lbl.text = "✅ ล้างจานสะอาดเอี่ยม!"
				lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
			GameManager.dialog_triggered.emit("คุณแม่", "🍽️ ขอบใจจ้ะของขวัญกับปีใหม่! ช่วยแม่เช็ดโต๊ะ ล้างจานชามมื้อเย็นจนสะอาดเอี่ยมคว่ำลงตะแกรงเรียบร้อย เป็นเด็กดีมีน้ำใจมากจ้ะ!", "res://assets/characters/npcs/portrait_mom.png")
			_check_chores()
		else:
			GameManager.dialog_triggered.emit("คุณแม่", "จานชามสะอาดหมดแล้วจ้ะ ขึ้นไปทำการบ้านที่ห้องนอนได้เลยนะจ๊ะ!", "res://assets/characters/npcs/portrait_mom.png")

func _check_chores() -> void:
	if wash_dishes_done and dad_massage_done:
		if not GameManager.evening_chore_done:
			GameManager.evening_chore_done = true
			GameManager.complete_good_deed("q_home_evening")

	_update_portal()

func _update_portal() -> void:
	if not portal_bedroom:
		return
	if wash_dishes_done and dad_massage_done and shoes_stored:
		portal_bedroom.is_locked = false
	else:
		portal_bedroom.is_locked = true
		portal_bedroom.lock_message = "ต้องทำเควสในบ้านให้ครบก่อน (จัดเก็บรองเท้า, นวดหลังให้คุณพ่อ, ช่วยคุณแม่ล้างจาน) แล้วค่อยขึ้นห้องนอนนะจ๊ะ! 🏠💖"
