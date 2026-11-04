extends Node

## GameManager Autoload - Manages state, inventory, backtracking, and educational minigames
signal inventory_changed
signal stars_changed
signal dialog_triggered(speaker: String, text: String, portrait_path: String)
signal dialog_closed
signal purse_opened(required_amount: int, title: String, callback: Callable)
signal level_completed(level_num: int)
signal map_toggled
signal stamina_updated(player_id: int, current_stamina: float, max_stamina: float, is_exhausted: bool)
signal good_deed_updated(quest_id: String, points_gained: int, total_points: int, quest_title: String)
signal good_deeds_modal_toggled

var current_level: int = 1
var spawn_x: float = 120.0

var inventory: Array[String] = []
var etiquette_stars: int = 0
var money_baht: int = 40 # Starting pocket money

# --- Good Deeds & Merit System (ระบบสะสมความดี) ---
var good_deed_points: int = 0

var chore_table_done: bool = false
var chore_trash_done: bool = false
var auntie_errand_done: bool = false
var teacher_board_done: bool = false
var evening_chore_done: bool = false

# Village Interior Quests (ฉาก 2)
var shop_groceries_bought: bool = false
var police_safety_done: bool = false
var doctor_eyedrops_received: bool = false
var temple_hall_swept: bool = false

# School Interior Quests (ฉาก 8)
var library_books_sorted: bool = false
var infirmary_firstaid_done: bool = false
var coop_supplies_bought: bool = false

var good_deeds: Dictionary = {
	"q_home_table": {
		"id": "q_home_table",
		"title": "ช่วยแม่เก็บโต๊ะอาหารและกวาดบ้าน",
		"category": "🏡 งานบ้าน",
		"location": "ฉากที่ 1: ในบ้านตอนเช้า",
		"npc": "คุณแม่",
		"desc": "ช่วยคุณแม่เช็ดทำความสะอาดโต๊ะอาหาร และนำไม้กวาดมากวาดพื้นบ้านให้สะอาดเรียบร้อยก่อนไปโรงเรียน",
		"points": 15,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 15 แต้มความดี"
	},
	"q_home_trash": {
		"id": "q_home_trash",
		"title": "ช่วยพ่อแยกขยะและนำไปทิ้งหน้าบ้าน",
		"category": "🏡 งานบ้าน",
		"location": "ฉากที่ 1: ในบ้านตอนเช้า",
		"npc": "คุณพ่อ",
		"desc": "ช่วยคุณพ่อนำถุงขยะรีไซเคิลไปทิ้งลงถังขยะหน้าบ้าน เพื่อปลูกฝังนิสัยรักความสะอาด",
		"points": 15,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 15 แต้มความดี"
	},
	"q_auntie_errand": {
		"id": "q_auntie_errand",
		"title": "ช่วยคุณป้าซื้อของจากร้านชำ",
		"category": "🛒 ซื้อของ",
		"location": "ฉากที่ 2: ซอยหมู่บ้าน",
		"npc": "คุณป้าสมศรี",
		"desc": "คุณป้าขาเจ็บ ขอให้ช่วยเดินไปซื้อไข่ไก่สดและนมถั่วเหลืองจากร้านชำลุงสิทธิ์ พร้อมนำเงินทอนส่งคืนให้ครบถ้วน",
		"points": 20,
		"status": "not_started",
		"reward": "🪙 ค่าขนม 5 ฿ + 20 แต้มความดี"
	},
	"q_village_police": {
		"id": "q_village_police",
		"title": "ไปหาตำรวจ: แจ้งเรื่องแมวหลง & วินัยจราจร",
		"category": "👮 ไปหาตำรวจ & ชุมชน",
		"location": "ฉากที่ 2: ป้อมตำรวจ/เทศบาลดอนโมง",
		"npc": "ร.ต.อ. สมชาย",
		"desc": "ไปพบคุณตำรวจที่ป้อมเทศบาลตำบลดอนโมงเพื่อเรียนรู้วินัยการข้ามถนน และช่วยออกตามหาลูกแมวหลง 'เจ้าส้ม' ที่ตลาด",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_village_market": {
		"id": "q_village_market",
		"title": "ไปจ่ายตลาด: ซื้อผักสดที่ตลาดนัดคลองถม",
		"category": "🥬 ไปจ่ายตลาด",
		"location": "ฉากที่ 2: ตลาดนัดคลองถมดอนโมง",
		"npc": "ป้าบุญมี ตลาดสด",
		"desc": "ไปจ่ายตลาดซื้อผักกาดขาวและแตงกวาปลอดสารพิษให้คุณแม่ และช่วยสังเกตหาลูกแมวน้อยที่ซอกแผงตลาด",
		"points": 20,
		"status": "not_started",
		"reward": "🥦 ผักสดสุขภาพ + 20 แต้มความดี"
	},
	"q_village_doctor": {
		"id": "q_village_doctor",
		"title": "ไปหาหมอ: รับยาวิตามินให้คุณยายที่คลินิก",
		"category": "🩺 ไปหาหมอ & สุขภาพ",
		"location": "ฉากที่ 2: คลินิกหมอชุมชนดอนโมง",
		"npc": "คุณหมอประวิทย์",
		"desc": "ไปพบคุณหมอที่คลินิกชุมชนดอนโมงเพื่อรับยาวิตามินบำรุงและยาหยอดตาให้คุณยาย พร้อมรับฟังคำแนะนำการดูแลสุขภาพ",
		"points": 20,
		"status": "not_started",
		"reward": "💊 ยาบำรุงสุขภาพ + 20 แต้มความดี"
	},
	"q_village_temple": {
		"id": "q_village_temple",
		"title": "ทำบุญที่วัด: ไหว้พระ & กวาดลานวัดมงคลนิมิต",
		"category": "🙏 ทำบุญที่วัด & จิตอาสา",
		"location": "ฉากที่ 2: วัดมงคลนิมิต",
		"npc": "หลวงตาบุญชื่น",
		"desc": "แวะไหว้พระขอพรที่วัดมงคลนิมิต และหยิบไม้กวาดทางมะพร้าวมาช่วยเหลือกวาดใบไม้แห้งลานวัดให้สะอาดร่มรื่น",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_village_post": {
		"id": "q_village_post",
		"title": "ไปส่งจดหมาย: หยอดส่งจดหมายที่ไปรษณีย์ไทย",
		"category": "📮 ไปส่งจดหมาย",
		"location": "ฉากที่ 2: ไปรษณีย์ไทย สาขาดอนโมง",
		"npc": "พี่สมศักดิ์ บุรุษไปรษณีย์",
		"desc": "นำจดหมายสำคัญที่คุณยายฝากส่ง ไปหยอดลงตู้ไปรษณีย์สีแดงหน้าไปรษณีย์ไทย สาขาดอนโมง ให้ถึงมือผู้รับ",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_busstop_trash": {
		"id": "q_busstop_trash",
		"title": "ช่วยเก็บขยะหน้าศาลาป้ายรถเมล์",
		"category": "🤝 ช่วยเพื่อน & ชุมชน",
		"location": "ฉากศาลาป้ายรอขึ้นรถเมล์",
		"npc": "จุดคัดแยกขยะ 3 สี",
		"desc": "ช่วยเก็บขวดน้ำพลาสติกที่ตกหล่นอยู่หน้าศาลาป้ายรถเมล์ นำไปทิ้งลงถังขยะรีไซเคิลสีเหลืองเพื่อความสะอาดเรียบร้อย",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_busstop_water": {
		"id": "q_busstop_water",
		"title": "ซื้อน้ำเย็นให้คุณตาระหว่างรอรถเมล์",
		"category": "💖 กตัญญู & จิตอาสา",
		"location": "ฉากศาลาป้ายรอขึ้นรถเมล์",
		"npc": "คุณตาใจดี (ศาลารอรถ)",
		"desc": "อากาศเริ่มร้อน คุณตานั่งรอรถจนคอแห้ง เดินไปซื้อน้ำเก๊กฮวยเย็นชื่นใจจากซุ้มป้ามาลีมาให้คุณตาดื่มดับกระหาย",
		"points": 20,
		"status": "not_started",
		"reward": "🥤 น้ำใจชื่นใจ + 20 แต้มความดี"
	},
	"q_busstop_schedule": {
		"id": "q_busstop_schedule",
		"title": "ตรวจเช็คตารางเดินรถและค่าโดยสาร",
		"category": "🚌 วินัยจราจร & เดินทาง",
		"location": "ฉากศาลาป้ายรอขึ้นรถเมล์",
		"npc": "ป้ายตารางเดินรถสาย 514",
		"desc": "อ่านป้ายตารางเวลาเดินรถเมล์สาย 514 ตรวจสอบค่าโดยสารนักเรียน 8 บาท และเตรียมเหรียญให้พร้อมก่อนขึ้นรถ",
		"points": 15,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 15 แต้มความดี"
	},
	"q_bus_seat": {
		"id": "q_bus_seat",
		"title": "สละที่นั่งให้คุณยายบนรถเมล์",
		"category": "🤝 ช่วยเพื่อน & ชุมชน",
		"location": "ฉากที่ 3: รถเมล์สายหลัก",
		"npc": "คุณยายใจดี",
		"desc": "ลุกสละที่นั่งให้คุณยายสูงอายุที่ขึ้นรถมาพร้อมสัมภาระหนัก และจับห่วงยึดเหนี่ยวอย่างปลอดภัย",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_terminal_grandma": {
		"id": "q_terminal_grandma",
		"title": "ช่วยคุณยายชี้ทางไปขึ้นรถสองแถว",
		"category": "🤝 ช่วยเพื่อน & ชุมชน",
		"location": "ฉากที่ 4: สถานีขนส่งสองแถว",
		"npc": "คุณยายใจดี (สถานี)",
		"desc": "คุณยายต้องการไปหาหมอที่โรงพยาบาล ช่วยบอกและแนะนำคุณยายให้ขึ้นรถสองแถวสายสีเขียวอย่างถูกต้อง",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_school_wai": {
		"id": "q_school_wai",
		"title": "ไหว้ครูเวรและคุณลุง รปภ. หน้าประตูโรงเรียน",
		"category": "🙏 สัมมาคารวะ & มารยาทไทย",
		"location": "ฉากที่ 5: ประตูโรงเรียนชุมชนหนองเรือ",
		"npc": "ครูเวร & ลุง รปภ.",
		"desc": "ก่อนก้าวเข้าสู่รั้วโรงเรียน ยกมือไหว้คุณครูเวรประจำวันและคุณลุง รปภ. อย่างนอบน้อมสวยงามตามมารยาทไทย",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_school_pencil": {
		"id": "q_school_pencil",
		"title": "ช่วยเก็บกล่องดินสอให้น้อง ป.1",
		"category": "🤝 มีน้ำใจ & ช่วยเหลือผู้อื่น",
		"location": "ฉากที่ 5: ประตูโรงเรียนชุมชนหนองเรือ",
		"npc": "น้อง ป.1",
		"desc": "เห็นน้อง ป.1 ทำกล่องดินสอหล่นที่ทางม้าลาย ช่วยเก็บขึ้นมาส่งคืนน้องด้วยความเอื้อเฟื้อเผื่อแผ่",
		"points": 15,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 15 แต้มความดี"
	},
	"q_teacher_board": {
		"id": "q_teacher_board",
		"title": "ช่วยคุณครูลบกระดานและจัดสมุดการบ้าน",
		"category": "👩‍🏫 ช่วยครู",
		"location": "ฉากที่ 6: คาบเรียนหรรษา",
		"npc": "คุณครูประจำชั้น",
		"desc": "หลังจบคลาสตอบคำถามหรรษา ช่วยคุณครูลบกระดานดำให้สะอาด และจัดเรียงสมุดการบ้านบนโต๊ะครูให้เป็นระเบียบ",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_canteen_clean": {
		"id": "q_canteen_clean",
		"title": "ช่วยแม่ค้าเก็บถาดและคัดแยกขยะ 3 สี",
		"category": "🛒 ซื้อของ & จิตอาสา",
		"location": "ฉากที่ 7: อาคาร 13 โรงอาหาร",
		"npc": "ป้าแม่ค้าโรงอาหาร",
		"desc": "รับประทานอาหารครบ 5 หมู่เสร็จแล้ว ช่วยนำถาดไปคืนจุดรับ และแยกเศษอาหาร พลาสติก ลงถังขยะให้ถูกต้อง",
		"points": 15,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 15 แต้มความดี"
	},
	"q_first_aid_friend": {
		"id": "q_first_aid_friend",
		"title": "ช่วยปฐมพยาบาลน้องอนุบาลที่หกล้ม",
		"category": "🤝 ช่วยเพื่อน & ชุมชน",
		"location": "ฉากที่ 8: จุด 23 สนามเด็กเล่น",
		"npc": "น้องอนุบาล",
		"desc": "พบน้องอนุบาลหกล้มเข่าถลอก รีบวิ่งไปนำกล่องปฐมพยาบาลจากห้องพยาบาลมาทำแผลและปลอบโยน",
		"points": 25,
		"status": "not_started",
		"reward": "🎟️ คูปองสหกรณ์ + 25 แต้มความดี"
	},
	"q_nurse_help": {
		"id": "q_nurse_help",
		"title": "ช่วยครูพยาบาลจัดกล่องยาและสำลี",
		"category": "👩‍🏫 ช่วยครู",
		"location": "ฉากที่ 8: อาคาร 14 ห้องพยาบาล",
		"npc": "ครูพยาบาล",
		"desc": "ช่วยครูพยาบาลจัดเรียงขวดน้ำเกลือ สำลี และผ้าพันแผลลงตู้ยาประจำห้องพยาบาลให้หยิบใช้ง่าย",
		"points": 15,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 15 แต้มความดี"
	},
	"q_flower_garden": {
		"id": "q_flower_garden",
		"title": "ช่วยคุณครูดูแลแปลงดอกไม้โรงเรียน",
		"category": "👩‍🏫 ช่วยครู & จิตอาสา",
		"location": "ฉากที่ 8: จุด 17 สวนริมสระน้ำ",
		"npc": "ครูเกษตร",
		"desc": "นำตำราพฤกษศาสตร์ บัวรดน้ำ และปุ๋ยอินทรีย์ มาช่วยกันพรวนดินใส่ปุ๋ยรดน้ำจนดอกไม้บานสะพรั่งรอบโรงเรียน",
		"points": 25,
		"status": "not_started",
		"reward": "🌸 ดอกไม้บานสะพรั่ง + 25 แต้มความดี"
	},
	"q_return_wallet": {
		"id": "q_return_wallet",
		"title": "เก็บกระเป๋าสตางค์ส่งคืนเจ้าของ",
		"category": "🤝 ช่วยเพื่อน & ชุมชน",
		"location": "ฉากที่ 10: รถเมล์สายหลัก ขากลับ",
		"npc": "พี่ผู้โดยสาร",
		"desc": "เห็นกระเป๋าสตางค์หล่นบนรถขณะเลี้ยว นำส่งคืนพี่ผู้โดยสารด้วยความซื่อสัตย์สุจริต",
		"points": 25,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 25 แต้มความดี"
	},
	"q_share_umbrella": {
		"id": "q_share_umbrella",
		"title": "กางร่มแบ่งปันเพื่อนนักเรียนยามฝนตก",
		"category": "🤝 ช่วยเพื่อน & ชุมชน",
		"location": "ฉากที่ 11: ซอยบ้านยามเย็น",
		"npc": "เพื่อนนักเรียน",
		"desc": "ฝนตกลงมาตอนเย็น กางร่มที่เตรียมมาเพื่อเดินแบ่งปันพาเพื่อนนักเรียนกลับบ้านด้วยกันอย่างปลอดภัย",
		"points": 20,
		"status": "not_started",
		"reward": "⭐ ดาวมารยาท + 20 แต้มความดี"
	},
	"q_home_evening": {
		"id": "q_home_evening",
		"title": "ช่วยแม่ล้างจานและนวดหลังให้คุณพ่อ",
		"category": "🏡 งานบ้าน",
		"location": "ฉากที่ 12: บ้านแสนสุขยามค่ำคืน",
		"npc": "คุณพ่อคุณแม่",
		"desc": "หลังกลับถึงบ้าน ช่วยคุณแม่ล้างจานมื้อเย็นที่อ่าง และนวดไหล่ให้คุณพ่อเพื่อแสดงความกตัญญูก่อนเข้านอน",
		"points": 25,
		"status": "not_started",
		"reward": "💖 เหรียญกตัญญู + 25 แต้มความดี"
	}
}

# Level Specific States
var chair_moved: bool = false
var house_unlocked: bool = false

var auntie_talked: bool = false
var has_student_card: bool = false
var has_umbrella: bool = false

# Don Mong Village Exploration Quest States (Scene 2)
var village_police_visited: bool = false
var village_cat_found: bool = false
var village_cat_returned: bool = false
var village_veggies_bought: bool = false
var village_doctor_visited: bool = false
var village_temple_cleaned: bool = false
var village_letter_sent: bool = false

# Bus Stop Pavilion Quest States (Scene 2.5 / Bus Stop)
var busstop_trash_done: bool = false
var busstop_water_bought: bool = false
var busstop_water_given: bool = false
var busstop_schedule_checked: bool = false

var bus_fare_paid: bool = false
var grandma_seated: bool = false

var songthaew_correct: bool = false
var songthaew_bell_rung: bool = false

var guard_talked: bool = false
var classroom_unlocked: bool = false
var classroom_quiz_score: int = 0

var canteen_budget_spent: int = 0
var canteen_nutrition_ok: bool = false
var waste_sorted_ok: bool = false

# Nong Ruea Community School Exploration Quest States (Scenes 7-8)
var storage_unlocked: bool = false
var grandpa_shrine_paid: bool = false
var has_plant_book: bool = false
var injured_student_helped: bool = false
var flowers_fertilized: bool = false
var flowers_bloomed: bool = false

var bag_pushed: bool = false
var coin_10_found: bool = false

var wallet_returned: bool = false
var stranger_refused: bool = false

var umbrella_active: bool = false
var day_completed: bool = false

# Player selection mode for single-player fallback:
var active_player_solo: int = 0 # 0 = Khongkwan, 1 = Peemai

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func reset_all_state() -> void:
	current_level = 1
	spawn_x = 120.0
	inventory.clear()
	etiquette_stars = 0
	money_baht = 40
	good_deed_points = 0

	chore_table_done = false
	chore_trash_done = false
	auntie_errand_done = false
	teacher_board_done = false
	evening_chore_done = false

	shop_groceries_bought = false
	police_safety_done = false
	doctor_eyedrops_received = false
	temple_hall_swept = false

	library_books_sorted = false
	infirmary_firstaid_done = false
	coop_supplies_bought = false

	for q_id in good_deeds.keys():
		good_deeds[q_id]["status"] = "not_started"

	chair_moved = false
	house_unlocked = false

	auntie_talked = false
	has_student_card = false
	has_umbrella = false

	village_police_visited = false
	village_cat_found = false
	village_cat_returned = false
	village_veggies_bought = false
	village_doctor_visited = false
	village_temple_cleaned = false
	village_letter_sent = false

	busstop_trash_done = false
	busstop_water_bought = false
	busstop_water_given = false
	busstop_schedule_checked = false

	bus_fare_paid = false
	grandma_seated = false

	songthaew_correct = false
	songthaew_bell_rung = false

	guard_talked = false
	classroom_unlocked = false
	classroom_quiz_score = 0

	canteen_budget_spent = 0
	canteen_nutrition_ok = false
	waste_sorted_ok = false

	storage_unlocked = false
	grandpa_shrine_paid = false
	has_plant_book = false
	injured_student_helped = false
	flowers_fertilized = false
	flowers_bloomed = false

	bag_pushed = false
	coin_10_found = false

	wallet_returned = false
	stranger_refused = false

	umbrella_active = false
	day_completed = false
	active_player_solo = 0

	inventory_changed.emit()
	stars_changed.emit()

func add_item(item_name: String) -> void:
	if not inventory.has(item_name):
		inventory.append(item_name)
		inventory_changed.emit()
		print("[Inventory] Added item: ", item_name)
		spawn_floating_text(Vector2.ZERO, "🎒 ได้รับ: %s!" % item_name, Color(0.35, 1.0, 0.88), -105.0)
		spawn_star_burst(Vector2.ZERO, Color(0.35, 1.0, 0.88))

func has_item(item_name: String) -> bool:
	return inventory.has(item_name)

func remove_item(item_name: String) -> void:
	if inventory.has(item_name):
		inventory.erase(item_name)
		inventory_changed.emit()

func add_star() -> void:
	etiquette_stars += 1
	stars_changed.emit()
	print("[Etiquette] Earned courtesy star! Total: ", etiquette_stars)
	spawn_floating_text(Vector2.ZERO, "⭐ +1 ดาวมารยาท!", Color(1.0, 0.92, 0.28), -85.0)
	spawn_star_burst(Vector2.ZERO, Color(1.0, 0.90, 0.25))

# --- Good Deeds Management Methods ---
func start_good_deed(quest_id: String, show_dialog: bool = false) -> void:
	if good_deeds.has(quest_id):
		if good_deeds[quest_id]["status"] == "not_started":
			good_deeds[quest_id]["status"] = "in_progress"
			var q: Dictionary = good_deeds[quest_id]
			if show_dialog:
				dialog_triggered.emit("📜 ได้รับเควสความดี!", "【%s】\nเป้าหมาย: %s" % [q["title"], q["desc"]], "")
			good_deed_updated.emit(quest_id, 0, good_deed_points, q["title"])

func complete_good_deed(quest_id: String) -> void:
	if good_deeds.has(quest_id):
		if good_deeds[quest_id]["status"] != "completed":
			good_deeds[quest_id]["status"] = "completed"
			var q: Dictionary = good_deeds[quest_id]
			var pts: int = q["points"]
			good_deed_points += pts
			add_star()
			good_deed_updated.emit(quest_id, pts, good_deed_points, q["title"])
			spawn_floating_text(Vector2.ZERO, "💖 +%d แต้มความดี!" % pts, Color(1.0, 0.55, 0.82), -125.0)
			spawn_star_burst(Vector2.ZERO, Color(1.0, 0.55, 0.82))
			dialog_triggered.emit("🎉 สำเร็จเควสความดี!", "ได้รับ +%d แต้มความดี! ⭐ ได้รับดาวมารยาท!\nเควส: '%s'\nฉายาปัจจุบัน: %s" % [pts, q["title"], get_good_deed_title()], "")

func get_good_deed_title() -> String:
	if good_deed_points >= 300:
		return "👑 ทูตความดีตัวอย่าง"
	elif good_deed_points >= 220:
		return "🏆 สุดยอดคนดีศรีชุมชน"
	elif good_deed_points >= 150:
		return "💖 ยุวชนจิตอาสาดีเด่น"
	elif good_deed_points >= 80:
		return "🌟 หนูดีมีน้ำใจ"
	elif good_deed_points >= 30:
		return "🌱 ต้นกล้าแห่งความดี"
	else:
		return "🐣 ผู้เริ่มต้นสะสมความดี"

func get_next_title_target() -> int:
	if good_deed_points < 30:
		return 30
	elif good_deed_points < 80:
		return 80
	elif good_deed_points < 150:
		return 150
	elif good_deed_points < 220:
		return 220
	elif good_deed_points < 300:
		return 300
	else:
		return 340

func change_level(target_level: int, target_spawn_x: float = 120.0) -> void:
	current_level = target_level
	spawn_x = target_spawn_x
	var path: String
	if target_level == 25:
		path = "res://scenes/levels/level_2_bus_stop.tscn"
	elif target_level == 95:
		path = "res://scenes/levels/level_9_5_bus_stop.tscn"
	else:
		path = "res://scenes/levels/level_%d.tscn" % target_level
	print("[GameManager] Changing to scene: ", path, " spawn_x: ", spawn_x)
	get_tree().change_scene_to_file(path)

func pass_current_level() -> void:
	print("[Cheat] Passing current level: ", current_level)
	match current_level:
		1:
			chore_table_done = true
			chore_trash_done = true
			chair_moved = true
			add_item("กุญแจบ้าน")
			house_unlocked = true
		2:
			auntie_errand_done = true
			auntie_talked = true
			add_item("บัตรนักเรียน")
			add_item("ร่ม")
		25:
			busstop_trash_done = true
			busstop_water_bought = true
			busstop_water_given = true
			busstop_schedule_checked = true
		3:
			bus_fare_paid = true
			grandma_seated = true
		4:
			songthaew_correct = true
			songthaew_bell_rung = true
		5:
			guard_talked = true
			add_item("กุญแจห้องและสมุดเช็คชื่อ")
			classroom_unlocked = true
		6:
			teacher_board_done = true
			classroom_quiz_score = 3
		7:
			canteen_nutrition_ok = true
			waste_sorted_ok = true
			storage_unlocked = true
			add_item("บัวรดน้ำ")
		8:
			grandpa_shrine_paid = true
			injured_student_helped = true
			add_item("ตำราพฤกษศาสตร์")
			add_item("ปุ๋ยอินทรีย์")
			flowers_fertilized = true
			flowers_bloomed = true
		9:
			bag_pushed = true
			coin_10_found = true
		10:
			wallet_returned = true
			stranger_refused = true
		11:
			umbrella_active = true
		12:
			evening_chore_done = true
			day_completed = true
		13:
			day_completed = true
	
	# Unlock any exit portals in the active scene if available
	var root = get_tree().current_scene
	if root:
		if root.has_method("_update_portal_state"):
			root._update_portal_state()
		elif root.has_method("_update_portal"):
			root._update_portal()
		elif root.has_method("_check_portal_unlock"):
			root._check_portal_unlock()
		
		# Also unlock any MaplePortal node named Portal* or exit
		for child in root.get_children():
			if child is MaplePortal:
				child.is_locked = false

func change_scene_to_file(path: String, target_spawn_x: float = 120.0, level_num: int = -1) -> void:
	if level_num >= 0:
		current_level = level_num
	spawn_x = target_spawn_x
	print("[GameManager] Changing to scene file: ", path, " spawn_x: ", spawn_x, " level_num: ", current_level)
	get_tree().change_scene_to_file(path)

func get_hint() -> String:
	match current_level:
		1:
			if not chore_table_done:
				return "น้องปีใหม่: 'ก่อนไปโรงเรียน เราช่วยคุณแม่เก็บโต๊ะอาหารและกวาดบ้าน เพื่อสะสมแต้มความดีกันเถอะ!'"
			elif not chore_trash_done:
				return "พี่ของขวัญ: 'คุณพ่อกำลังยกถุงขยะอยู่ เราช่วยพ่อนำไปทิ้งที่ถังหน้าบ้านกันนะ!'"
			elif not has_item("กุญแจบ้าน"):
				if not chair_moved:
					return "น้องปีใหม่: 'กุญแจบ้านอยู่บนหลังตู้เย็นสูงจัง! เดี๋ยวปีใหม่ไปช่วยดันเก้าอี้ไม้มาให้พี่ของขวัญเหยียบปีนขึ้นไปหยิบนะ!'"
				else:
					return "พี่ของขวัญ: 'เก้าอี้พร้อมแล้ว! พี่ของขวัญกระโดดเหยียบเก้าอี้ขึ้นไปหยิบกุญแจบ้านบนหลังตู้เย็นได้เลย!'"
			elif not house_unlocked:
				return "พี่ของขวัญ: 'ได้กุญแจแล้ว รีบเดินไปที่ประตูหน้าบ้านแล้วกด [E] หรือ [Shift] เพื่อไขประตูเปิดออกไปข้างนอกกันเถอะ!'"
			else:
				return "น้องปีใหม่: 'ประตูเปิดแล้ว! เดินไปที่เสาแสงวาปสีฟ้าที่ประตูแล้วกด [W] หรือ [ลูกศรขึ้น] เพื่อออกไปซอยหมู่บ้านกัน!'"
		2:
			if not auntie_errand_done:
				return "น้องปีใหม่: 'คุณป้าสมศรีขาเจ็บ อยากให้ช่วยซื้อไข่ไก่กับนมถั่วเหลืองที่ร้านชำลุงสิทธิ์ เดินไปช่วยคุณป้าซื้อของกันเถอะ! กด [J] ดูสมุดความดีได้ด้วยนะ!'"
			elif not auntie_talked:
				return "น้องปีใหม่: 'เดินผ่านร้านค้า อย่าลืมกดทักทาย [สวัสดี] คุณลุงคุณป้าเพื่อรับดาวมารยาทดี แล้วไปคุยกับคุณป้าที่ป้ายรถเมล์กัน!'"
			elif not has_item("บัตรนักเรียน") or not has_item("ร่ม"):
				return "พี่ของขวัญ: 'คุณป้าบอกว่าเย็นนี้ฝนจะตก แล้วเราลืมบัตรนักเรียนกับร่มไว้ในบ้าน! ต้องเดินเข้าวาปย้อนกลับไป [ฉากที่ 1 ในบ้าน] กันเถอะ!'"
			else:
				return "พี่ของขวัญ: 'พวกเรามีทั้งบัตรนักเรียนและร่มพร้อมแล้ว! เดินเข้าวาปขวาสุดไปที่ [ศาลาป้ายรอขึ้นรถเมล์] กันเลย!'"
		25:
			if not busstop_trash_done:
				return "น้องปีใหม่: 'มีขวดน้ำพลาสติกตกอยู่หน้าศาลาป้ายรถเมล์ ช่วยกันเก็บไปทิ้งลงถังคัดแยกเพื่อสะสมความดีกันเถอะ!'"
			elif not busstop_water_given:
				return "พี่ของขวัญ: 'คุณตานั่งรอรถในศาลาท่าทางคอแห้ง เดินไปซื้อน้ำเก๊กฮวยเย็น 5 บาทที่ซุ้มป้ามาลีมาให้คุณตากันนะ!'"
			elif not busstop_schedule_checked:
				return "น้องปีใหม่: 'เดินไปดูป้ายตารางเวลาเดินรถเมล์สาย 514 เพื่อตรวจเช็คเวลาและค่าโดยสารนักเรียนกัน!'"
			else:
				return "พี่ของขวัญ: 'ทำเควสความดีและตรวจตารางรถเรียบร้อยแล้ว รถเมล์สาย 514 จอดเทียบท่าอยู่ข้างหน้า ขึ้นรถเมล์กันเลย!'"
		3:
			if not bus_fare_paid:
				return "พี่ของขวัญ: 'ค่ารถเมล์นักเรียนคนละ 8 บาท สองคนรวมเป็น 16 บาท! พี่มีแบงก์ 20 บาท เราต้องรอรับเงินทอน 4 บาทนะ!'"
			elif not grandma_seated:
				return "น้องปีใหม่: 'คุณยายถือของหนักขึ้นรถมาแต่ไม่มีที่นั่งเลย! พวกเรากดปุ่มลุกสละที่นั่งให้คุณยายเพื่อสะสมความดี แล้วไปยืนจับห่วงเหล็กกันเถอะ!'"
			else:
				return "พี่ของขวัญ: 'รถเมล์กำลังจะถึงสถานีขนส่งแล้ว เตรียมตัวเดินไปที่ประตูด้านหน้าเพื่อลงรถกัน!'"
		4:
			if not songthaew_correct:
				return "พี่ของขวัญ: 'พี่ต้องไปอ่านป้ายตารางเดินรถที่เสาสถานี รถสีแดงไปตลาด สีเขียวไปโรงพยาบาล รถสองแถวสีฟ้าผ่านโรงเรียนของเรา ขึ้นคันสีฟ้ากัน!'"
			elif not songthaew_bell_rung:
				return "น้องปีใหม่: 'บนรถสองแถว ต้องคอยมองหน้าต่างทางขวา พอเห็นป้ายโรงเรียนผ่านมา ให้รีบกดกระดิ่งกริ่งทันทีนะ!'"
			else:
				return "พี่ของขวัญ: 'กดกริ่งจอดเรียบร้อยแล้ว ก้าวลงจากรถอย่างระมัดระวัง แล้วเดินเข้าประตูโรงเรียนกันเลย!'"
		5:
			if not guard_talked and not has_item("กุญแจห้องและสมุดเช็คชื่อ"):
				return "พี่ของขวัญ: 'ขึ้นไปดูหน้าห้องเรียนชั้น 2 แล้วประตูล็อก! คุณครูลืมสมุดเช็คชื่อกับกุญแจไว้ที่ป้อมยามหน้าประตูโรงเรียน ย้อนลงไปขอลุง รปภ. กัน!'"
			elif has_item("กุญแจห้องและสมุดเช็คชื่อ") and not classroom_unlocked:
				return "น้องปีใหม่: 'ได้กุญแจจากลุง รปภ. แล้ว! รีบเดินขึ้นบันไดไปไขเปิดประตูห้องเรียนชั้น 2 กันเถอะ!'"
			else:
				return "พี่ของขวัญ: 'เข้าห้องเรียนกันเลย ประตูเปิดแล้ว!'"
		6:
			if not teacher_board_done:
				return "คุณครู: 'ตอบคำถามครบแล้ว ใครใจดีช่วยครูลบกระดานดำและจัดสมุดการบ้านบนโต๊ะหน่อยนะจ๊ะ เพื่อรับแต้มความดี!'"
			else:
				return "พี่ของขวัญ: 'ช่วยคุณครูเสร็จเรียบร้อยแล้ว ได้เวลาพักเที่ยง เดินเข้าเสาวาปไปโรงอาหารกันเลย!'"
		7:
			if not canteen_nutrition_ok:
				return "พี่ของขวัญ: 'พักเที่ยงที่ [อาคาร 13 โรงอาหาร] มีงบคนละ 40 บาท เลือกซื้ออาหารและผลไม้ให้ครบ 5 หมู่ และไม่เกินงบประมาณนะ!'"
			elif not waste_sorted_ok:
				return "น้องปีใหม่: 'ทานเสร็จแล้ว ต้องช่วยกันแยกขยะ เศษอาหาร พลาสติก และจานชาม ลงถัง 3 สี เพื่อทำเควสความดีและรับดาวมารยาท!'"
			elif not has_item("บัวรดน้ำ"):
				return "น้องปีใหม่: 'ให้น้องปีใหม่มุดช่องลมปลดล็อกประตู [อาคาร 20 ห้องเก็บพัสดุ] ข้างโรงอาหาร เพื่อหยิบ 'บัวรดน้ำ' ไปใช้ในแปลงเกษตรนะ!'"
			else:
				return "พี่ของขวัญ: 'ได้บัวรดน้ำเรียบร้อยแล้ว เดินเข้าวาปไปสำรวจโรงเรียนชุมชนหนองเรือกันเลย!'"
		8:
			if not grandpa_shrine_paid:
				return "น้องปีใหม่: 'เดินผ่าน [จุด 22 ศาลปู่-ย่า] อย่าลืมยกมือไหว้สิ่งศักดิ์สิทธิ์ประจำโรงเรียนเพื่อรับดาวมารยาทดีนะ! กด [M] ดูแผนที่ กด [J] ดูสมุดความดีได้เลย!'"
			elif not has_item("ตำราพฤกษศาสตร์"):
				return "พี่ของขวัญ: 'แปลงดอกไม้ต้องการการดูแลอย่างถูกวิธี! ไปค้นหา 'ตำราพฤกษศาสตร์' ที่ [อาคาร 4 ห้องสมุดและศูนย์ดิจิทัล] กัน!'"
			elif not injured_student_helped:
				return "น้องปีใหม่: 'มีน้องอนุบาลหกล้มร้องไห้อยู่ที่ [จุด 23 สนามเด็กเล่น]! รีบไปขอกล่องยาทำแผลที่ [อาคาร 14 ห้องพยาบาล] มาช่วยน้องรับแต้มความดีกัน!'"
			elif not has_item("ปุ๋ยอินทรีย์"):
				return "พี่ของขวัญ: 'น้องอนุบาลให้คูปองสหกรณ์ 10 บาทมาตอบแทน! นำไปซื้อ 'ถุงปุ๋ยอินทรีย์' ที่ [อาคาร 18 ร้านค้าสหกรณ์] กันเถอะ!'"
			elif not has_item("บัวรดน้ำ"):
				return "น้องปีใหม่: 'ลืมบัวรดน้ำไว้ที่ [อาคาร 20 ห้องเก็บพัสดุ] ย้อนเข้าวาปกลับไป [ฉากที่ 7 โรงอาหาร] เพื่อมุดช่องลมไปหยิบบัวรดน้ำกัน!'"
			elif not flowers_bloomed:
				return "พี่ของขวัญ & น้องปีใหม่: 'ของครบแล้ว! ทั้งบัวรดน้ำ ปุ๋ยอินทรีย์ และตำราพฤกษศาสตร์ รีบไปที่แปลงดอกไม้ริมสระน้ำ [จุด 17] ช่วยคุณครูรดน้ำใส่ปุ๋ยให้ดอกไม้บานสะพรั่งเลย!'"
			else:
				return "พี่ของขวัญ: 'ดอกไม้บานสะพรั่งสวยงามมาก ได้เวลาเลิกเรียน เดินไปที่ประตูโรงเรียน [จุด 24] เพื่อขึ้นรถสองแถวกลับบ้านกัน!'"
		9:
			if not coin_10_found:
				return "น้องปีใหม่: 'เหรียญ 10 บาทกลิ้งตกไปใต้เบาะรถสองแถว มีกระเป๋าใบใหญ่วางขวางอยู่ พี่ของขวัญช่วยดันกระเป๋าออก แล้วปีใหม่จะมุดเข้าไปเก็บให้นะ!'"
			else:
				return "พี่ของขวัญ: 'ได้เหรียญมาจ่ายค่ารถสองแถวเรียบร้อยแล้ว เดินลงรถไปที่ [ฉากที่ 9.5 ท่ารถต่อรถเมล์] กัน!'"
		95:
			return "น้องปีใหม่: 'ถึงท่ารถต่อรถเมล์แล้ว! ไปตรวจดูตารางเดินรถเมล์สาย 514 ขากลับ และเตรียมตัวขึ้นรถเมล์สายหลักกลับบ้านกัน!'"
		10:
			if not wallet_returned:
				return "น้องปีใหม่: 'พี่ผู้หญิงทำกระเป๋าสตางค์ตกตอนรถเลี้ยว! รีบเก็บแล้ววิ่งไปส่งคืนพี่เขาก่อนจะลงป้ายหน้า เพื่อสะสมแต้มความดีคนดีของสังคมนะ!'"
			elif not stranger_refused:
				return "พี่ของขวัญ: 'มีคนแปลกหน้ามาชวนคุยและยื่นขนมให้ พร้อมชวนลงที่อื่น! พวกเราต้องปฏิเสธอย่างสุภาพ แล้วเดินไปยืนใกล้คุณกระเป๋ารถเมล์นะ!'"
			else:
				return "น้องปีใหม่: 'ปลอดภัยแล้ว! รถเมล์ใกล้ถึงป้ายหน้าปากซอยหมู่บ้านเราแล้ว เตรียมลงรถกัน!'"
		11:
			if not umbrella_active:
				return "พี่ของขวัญ: 'ฝนตกลงมาแล้ว อากาศหนาวจัง! รีบกดใช้ [ร่ม] ที่เราพกมาจากบ้าน เพื่อกางร่มแบ่งปันพาเพื่อนร่วมทางกลับบ้านด้วยกันเถอะ!'"
			else:
				return "น้องปีใหม่: 'กางร่มอุ่นสบาย ไม่เปียกฝนแล้ว! เดินเข้าซอยตรงไปที่บ้านแสนสุขของเรากันเลย!'"
		12:
			if not evening_chore_done:
				return "น้องปีใหม่: 'ถึงบ้านแล้ว! รีบไปช่วยคุณแม่ล้างจานที่อ่าง และช่วยนวดไหล่ให้คุณพ่อ เพื่อทำเควสความดีกตัญญูก่อนนอนกันเถอะ!'"
			else:
				return "น้องปีใหม่: 'ความดีครบถ้วนแล้ว! ทบทวนบทเรียนวันนี้ ปิดสวิตช์ไฟ แล้วเข้านอนหลับฝันดีกันเถอะ!'"
		_:
			return "พี่ของขวัญ & น้องปีใหม่: 'พวกเราช่วยกันเดินทางไปโรงเรียนอย่างปลอดภัยและมีความสุข!'"

func style_prompt_label(lbl: Label, border_color: Color = Color(1.0, 0.84, 0.25, 0.95), font_color: Color = Color(1.0, 0.96, 0.88, 1.0)) -> void:
	if not lbl:
		return

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.09, 0.16, 0.92) # Deep obsidian navy
	sb.border_color = border_color
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0

	lbl.add_theme_stylebox_override("normal", sb)
	lbl.add_theme_color_override("font_color", font_color)
	lbl.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.98))
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	lbl.add_theme_constant_override("shadow_offset_x", 0)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Expand height so padding and outline fit comfortably without clipping
	var cur_h: float = lbl.offset_bottom - lbl.offset_top
	if cur_h < 28.0:
		var cy: float = (lbl.offset_top + lbl.offset_bottom) * 0.5
		lbl.offset_top = cy - 14.0
		lbl.offset_bottom = cy + 14.0

	var cur_w: float = lbl.offset_right - lbl.offset_left
	if cur_w < 170.0:
		var cx: float = (lbl.offset_left + lbl.offset_right) * 0.5
		lbl.offset_left = cx - 85.0
		lbl.offset_right = cx + 85.0

func get_primary_player_pos() -> Vector2:
	if not is_inside_tree() or not get_tree():
		return Vector2.ZERO
	var players := get_tree().get_nodes_in_group("players")
	for p in players:
		if p is Node2D and p.is_inside_tree():
			return (p as Node2D).global_position
	return Vector2.ZERO

func spawn_floating_text(world_pos: Vector2, text: String, color: Color = Color(1.0, 0.92, 0.25), y_offset: float = -90.0) -> void:
	if not is_inside_tree() or not get_tree() or not get_tree().current_scene:
		return
	var root := get_tree().current_scene
	if not (root is Node2D):
		return
	var pos := world_pos if world_pos != Vector2.ZERO else get_primary_player_pos()
	if pos == Vector2.ZERO:
		return

	var holder := Node2D.new()
	holder.global_position = pos + Vector2(0, y_offset)
	holder.z_index = 40

	var lbl := Label.new()
	lbl.text = text
	lbl.position = Vector2(-120, -14)
	lbl.custom_minimum_size = Vector2(240, 28)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.1, 0.98))
	lbl.add_theme_constant_override("outline_size", 5)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	lbl.add_theme_constant_override("shadow_offset_x", 0)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	holder.add_child(lbl)
	root.add_child(holder)

	holder.scale = Vector2(0.5, 0.5)
	var tw := holder.create_tween().set_parallel(true)
	tw.tween_property(holder, "scale", Vector2(1.08, 1.08), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(holder, "position:y", holder.position.y - 48.0, 1.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(holder, "modulate:a", 0.0, 0.45).set_delay(0.7)
	tw.chain().tween_callback(holder.queue_free)

func spawn_star_burst(world_pos: Vector2, color: Color = Color(1.0, 0.9, 0.3)) -> void:
	if not is_inside_tree() or not get_tree() or not get_tree().current_scene:
		return
	var root := get_tree().current_scene
	if not (root is Node2D):
		return
	var pos := world_pos if world_pos != Vector2.ZERO else get_primary_player_pos()
	if pos == Vector2.ZERO:
		return

	var particles := CPUParticles2D.new()
	particles.global_position = pos + Vector2(0, -45.0)
	particles.z_index = 38
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 16
	particles.lifetime = 0.75
	particles.explosiveness = 0.92
	particles.spread = 180.0
	particles.direction = Vector2(0, -1)
	particles.gravity = Vector2(0, 260)
	particles.initial_velocity_min = 65.0
	particles.initial_velocity_max = 145.0
	particles.scale_amount_min = 3.5
	particles.scale_amount_max = 6.5
	particles.color = color
	root.add_child(particles)

	var tw := particles.create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(particles.queue_free)

func spawn_dust_puff(world_pos: Vector2, count: int = 6) -> void:
	if not is_inside_tree() or not get_tree() or not get_tree().current_scene:
		return
	var root := get_tree().current_scene
	if not (root is Node2D):
		return

	var dust := CPUParticles2D.new()
	dust.global_position = world_pos
	dust.z_index = 15
	dust.emitting = true
	dust.one_shot = true
	dust.amount = count
	dust.lifetime = 0.38
	dust.explosiveness = 0.9
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(10, 2)
	dust.direction = Vector2(0, -1)
	dust.spread = 75.0
	dust.gravity = Vector2(0, -20)
	dust.initial_velocity_min = 18.0
	dust.initial_velocity_max = 42.0
	dust.scale_amount_min = 3.0
	dust.scale_amount_max = 5.5
	dust.color = Color(0.95, 0.95, 0.98, 0.65)
	root.add_child(dust)

	var tw := dust.create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(dust.queue_free)

func play_scene_entry_fade(parent_node: Node) -> void:
	if not parent_node or not parent_node.is_inside_tree():
		return
	var cl := CanvasLayer.new()
	cl.layer = 95
	var rect := ColorRect.new()
	rect.color = Color(0.05, 0.08, 0.14, 0.85)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(rect)
	parent_node.add_child(cl)

	var tw := rect.create_tween()
	tw.tween_property(rect, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(cl.queue_free)


