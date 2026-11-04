extends BaseLevel

@onready var exit_portal: MaplePortal = $ExitPortal
@onready var librarian_area: Area2D = $LibrarianArea
@onready var prompt_librarian: Label = $LibrarianArea/PromptLabel
@onready var badge_librarian: Label = $LibrarianArea/QuestBadge
@onready var shelf_sort_area: Area2D = $ShelfSortArea
@onready var prompt_shelf: Label = $ShelfSortArea/PromptLabel
@onready var shelf_prop: Sprite2D = $ShelfProp

var near_librarian: bool = false
var near_shelf: bool = false

func _ready() -> void:
	level_number = 801
	super._ready()
	
	if exit_portal:
		exit_portal.target_scene_path = "res://scenes/levels/level_8.tscn"
		exit_portal.target_spawn_x = 650.0
		exit_portal.target_level = 8
		exit_portal.portal_name = "ออกไปลานเกษตรโรงเรียน"
		exit_portal.is_locked = false
	
	if librarian_area:
		librarian_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_librarian = true
				if prompt_librarian: prompt_librarian.visible = true
		)
		librarian_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_librarian = false
				if prompt_librarian: prompt_librarian.visible = false
		)
	
	if shelf_sort_area:
		shelf_sort_area.body_entered.connect(func(b):
			if b.is_in_group("players"):
				near_shelf = true
				if prompt_shelf: prompt_shelf.visible = true
		)
		shelf_sort_area.body_exited.connect(func(b):
			if b.is_in_group("players"):
				near_shelf = false
				if prompt_shelf: prompt_shelf.visible = false
		)
	
	_update_badges()
	
	await get_tree().create_timer(0.4).timeout
	if not GameManager.library_books_sorted:
		GameManager.dialog_triggered.emit(
			"ครูรัตนา (บรรณารักษ์ห้องสมุด)",
			"ชู่ว... สวัสดีจ้ะของขวัญและปีใหม่! ห้องสมุดโรงเรียนชุมชนหนองเรือยินดีต้อนรับจ้ะ ขอให้ใช้เสียงเบาๆ และเดินอย่างสำรวมนะจ๊ะ วันนี้หมวดเกษตรและพฤกษศาสตร์อยู่ที่ชั้นวางด้านในสุดจ้ะ! 📚 🤫",
			"res://assets/characters/npcs/npc_teacher.png"
		)

func _process(_delta: float) -> void:
	var interact_pressed := Input.is_action_just_pressed("p1_interact") or Input.is_action_just_pressed("p2_interact")
	if interact_pressed:
		if near_librarian:
			_interact_librarian()
		elif near_shelf:
			_interact_shelf()

func _interact_librarian() -> void:
	if not GameManager.library_books_sorted:
		GameManager.library_books_sorted = true
		if not GameManager.has_item("ตำราพฤกษศาสตร์"):
			GameManager.add_item("ตำราพฤกษศาสตร์")
		GameManager.add_star()
		GameManager.add_star()
		if AudioManager:
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("coin")
		GameManager.dialog_triggered.emit(
			"ครูรัตนา (บรรณารักษ์ห้องสมุด)",
			"ยอดเยี่ยมมากจ้ะ! หนูทั้งสองเข้าใจมารยาทในห้องสมุดเป็นอย่างดี: ไม่ส่งเสียงดัง ไม่นำอาหารเข้ามารับประทาน และจัดเก็บหนังสือเข้าที่ ครูให้ยืม 'ตำราพฤกษศาสตร์' เล่มนี้ไปดูแลแปลงเกษตรได้เลยนะจ๊ะ! 📚 🌱 ⭐⭐",
			"res://assets/characters/npcs/npc_teacher.png"
		)
	else:
		GameManager.dialog_triggered.emit(
			"ครูรัตนา (บรรณารักษ์ห้องสมุด)",
			"การอ่านหนังสือเปิดโลกทัศน์ให้กว้างไกล ตั้งใจศึกษาหาความรู้นะจ๊ะเด็กดี! 📖 ✨",
			"res://assets/characters/npcs/npc_teacher.png"
		)
	_update_badges()

func _interact_shelf() -> void:
	if not GameManager.has_item("ตำราพฤกษศาสตร์"):
		GameManager.add_item("ตำราพฤกษศาสตร์")
	GameManager.library_books_sorted = true
	GameManager.add_star()
	if AudioManager:
		AudioManager.play_sfx("correct")
	GameManager.dialog_triggered.emit(
		"ชั้นวางหนังสือหมวดวิทยาศาสตร์และเกษตรกรรม",
		"📗 สองพี่น้องจัดเรียงหนังสือหมวดพฤกษศาสตร์ตามระบบดิวอี้ (Dewey 580) อย่างเป็นระเบียบ! ได้รับ 'ตำราพฤกษศาสตร์' เล่มสำคัญสำหรับการฟื้นฟูแปลงดอกไม้! 🌸 ⭐",
		""
	)
	_update_badges()

func _update_badges() -> void:
	if badge_librarian:
		if GameManager.library_books_sorted:
			badge_librarian.text = "✅ จัดหนังสือและยืมตำราเรียบร้อย"
			badge_librarian.modulate = Color(0.35, 1.0, 0.55)
		else:
			badge_librarian.text = "💡 จัดหนังสือและยืมตำราพฤกษศาสตร์ [!]"
			badge_librarian.modulate = Color(1.0, 0.9, 0.3)
