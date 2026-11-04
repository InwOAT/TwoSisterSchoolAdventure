extends BaseLevel

@onready var portal_door: MaplePortal = $PortalDoor
@onready var chair: PushableObject = $PushableChair
@onready var key_item: InteractableItem = $ItemKey
@onready var card_item: InteractableItem = $ItemCard
@onready var umbrella_item: InteractableItem = $ItemUmbrella

var table_cleaned: bool = false
var floor_swept: bool = false
var trash_bag_picked: bool = false

func _ready() -> void:
	level_number = 1
	super._ready()
	
	if portal_door:
		portal_door.target_level = 2
		portal_door.target_spawn_x = 100.0
		if GameManager.has_item("กุญแจบ้าน") or GameManager.house_unlocked:
			portal_door.is_locked = false
			GameManager.house_unlocked = true
		else:
			portal_door.is_locked = true
			portal_door.lock_message = "ประตูปิดล็อกอยู่! ดัน 'เก้าอี้ไม้ 3D' ไปชิดตู้เย็นเพื่อกระโดดขึ้นไปหยิบกุญแจบ้านบนหลังตู้เย็นมาไขก่อนนะ!"
		if portal_door.has_method("_update_prompt"):
			portal_door._update_prompt()

	# If Auntie already asked to backtrack for student card and umbrella
	if GameManager.auntie_talked:
		if card_item and not GameManager.has_item("บัตรนักเรียน"):
			card_item.visible = true
		if umbrella_item and not GameManager.has_item("ร่ม"):
			umbrella_item.visible = true
	else:
		if card_item: card_item.visible = false
		if umbrella_item: umbrella_item.visible = false

func _process(delta: float) -> void:
	super._process(delta)

	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")

	# Subtle floating animation for interactive home props
	var t := Time.get_ticks_msec() * 0.004
	var bag_node := get_node_or_null("TrashBagItem/Sprite2D") as Sprite2D
	if bag_node:
		bag_node.position.y = sin(t * 1.4) * 3.0

	# Check if key is collected and auto-unlock door
	if GameManager.has_item("กุญแจบ้าน"):
		if not GameManager.house_unlocked:
			GameManager.house_unlocked = true
			if portal_door:
				portal_door.is_locked = false
				if portal_door.has_method("_update_prompt"):
					portal_door._update_prompt()
			GameManager.dialog_triggered.emit("ระบบ", "🔑 ได้กุญแจแล้ว! ประตูหน้าบ้านปลดล็อกเรียบร้อยแล้วจ้า เดินไปที่ประตูแล้วกด [W / ↑] หรือ [E] ออกไปซอยหมู่บ้านกันเลย!", "")
		elif portal_door and portal_door.is_locked:
			portal_door.is_locked = false
			if portal_door.has_method("_update_prompt"):
				portal_door._update_prompt()

	# Chore 1: Dining Table (x: 530) & Broom (x: 345)
	if not GameManager.chore_table_done:
		if (abs(p1.global_position.x - 530.0) < 60.0 or abs(p2.global_position.x - 530.0) < 60.0) and interact_pressed:
			if not table_cleaned:
				table_cleaned = true
				var tbl_lbl := get_node_or_null("TableSpot/Label") as Label
				if tbl_lbl:
					tbl_lbl.text = "✅ โต๊ะสะอาดเอี่ยม!"
					tbl_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
				GameManager.dialog_triggered.emit("งานบ้าน", "🍽️ เช็ดโต๊ะอาหารและเก็บจานชามสะอาดเรียบร้อยแล้ว! ✨ (อย่าลืมไปหยิบไม้กวาดมากวาดพื้นด้วยนะ)", "")
				_check_chore_table()
		
		if (abs(p1.global_position.x - 345.0) < 55.0 or abs(p2.global_position.x - 345.0) < 55.0) and interact_pressed:
			if not floor_swept:
				floor_swept = true
				var brm_lbl := get_node_or_null("BroomSpot/Label") as Label
				if brm_lbl:
					brm_lbl.text = "✅ กวาดพื้นสะอาดแล้ว!"
					brm_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
				GameManager.dialog_triggered.emit("งานบ้าน", "🧹 กวาดพื้นบ้านด้วยไม้กวาดดอกหญ้าจนสะอาดเอี่ยม ไม่มีฝุ่นเลย!", "")
				_check_chore_table()

	# Chore 2: Trash Bag (x: 850) to Recycle Bin (x: 1105)
	if not GameManager.chore_trash_done:
		if not trash_bag_picked and (abs(p1.global_position.x - 850.0) < 55.0 or abs(p2.global_position.x - 850.0) < 55.0) and interact_pressed:
			trash_bag_picked = true
			var bag_root := get_node_or_null("TrashBagItem") as Node2D
			if bag_root:
				bag_root.visible = false
			GameManager.dialog_triggered.emit("งานบ้าน", "♻️ หยิบถุงขยะรีไซเคิลแล้ว! รีบนำไปทิ้งลงถังขยะรีไซเคิลสีเขียวหน้าประตูบ้าน (ขวามือ) นะ!", "")
		
		if trash_bag_picked and (abs(p1.global_position.x - 1105.0) < 60.0 or abs(p2.global_position.x - 1105.0) < 60.0) and interact_pressed:
			GameManager.chore_trash_done = true
			var bin_lbl := get_node_or_null("TrashBinSpot/Label") as Label
			if bin_lbl:
				bin_lbl.text = "✅ ทิ้งขยะรีไซเคิลแล้ว!"
				bin_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.55))
			GameManager.complete_good_deed("q_home_trash")

func _check_chore_table() -> void:
	if table_cleaned and floor_swept and not GameManager.chore_table_done:
		GameManager.chore_table_done = true
		GameManager.complete_good_deed("q_home_table")
