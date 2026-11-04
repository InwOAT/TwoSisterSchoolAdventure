import os

SCENES_DIR = r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\scenes\levels"

def write_scene(filename, content):
    p = os.path.join(SCENES_DIR, filename)
    with open(p, "w", encoding="utf-8") as f:
        f.write(content.strip())
    print(f"Generated {filename}")

# Level 2: ซอยหมู่บ้านและป้ายรถเมล์
lvl_2 = """[gd_scene load_steps=10 format=3 uid="uid://lvl02village001"]

[ext_resource type="Script" path="res://scripts/level_2.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_2_village.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="Script" path="res://scripts/npc_character.gd" id="8_npc"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_wall"]
size = Vector2(40, 720)

[sub_resource type="CircleShape2D" id="CircleShape2D_npc"]
radius = 45.0

[node name="Level2" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="WallLeft" type="StaticBody2D" parent="."]
position = Vector2(20, 360)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="WallLeft"]
shape = SubResource("RectangleShape2D_wall")

[node name="WallRight" type="StaticBody2D" parent="."]
position = Vector2(1260, 360)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="WallRight"]
shape = SubResource("RectangleShape2D_wall")

[node name="PortalHome" parent="." instance=ExtResource("5_portal")]
position = Vector2(80, 640)
target_level = 1
target_spawn_x = 1150.0
portal_name = "ย้อนกลับเข้าบ้าน"

[node name="PortalBus" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 3
target_spawn_x = 100.0
portal_name = "ขึ้นรถเมล์สายหลัก"

[node name="AuntieNPC" type="Area2D" parent="."]
position = Vector2(900, 580)
collision_layer = 0
collision_mask = 2
script = ExtResource("8_npc")
npc_name = "คุณป้าร้านชำ"
dialog_lines = PackedStringArray("สวัสดีจ้ะเด็กๆ วันนี้พยากรณ์อากาศบอกว่าฝนจะตกตอนเย็นนะ แล้วพกบัตรนักเรียนกับร่มมาหรือยังจ๊ะ?")

[node name="CollisionShape2D" type="CollisionShape2D" parent="AuntieNPC"]
shape = SubResource("CircleShape2D_npc")

[node name="ColorRect" type="ColorRect" parent="AuntieNPC"]
offset_left = -25.0
offset_top = -50.0
offset_right = 25.0
offset_bottom = 50.0
color = Color(0.9, 0.6, 0.4, 1)

[node name="Label" type="Label" parent="AuntieNPC"]
offset_left = -60.0
offset_top = -75.0
offset_right = 60.0
offset_bottom = -55.0
theme_override_font_size = 12
text = "คุณป้าร้านชำ"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="AuntieNPC"]
visible = false
offset_left = -70.0
offset_top = -95.0
offset_right = 70.0
offset_bottom = -75.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E/Shift] ไหว้ทักทาย"
horizontal_alignment = 1

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_2.tscn", lvl_2)

# Level 3: บนรถเมล์สายหลัก ขาไป
lvl_3 = """[gd_scene load_steps=10 format=3 uid="uid://lvl03bus001"]

[ext_resource type="Script" path="res://scripts/level_3.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_3_bus.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="PackedScene" path="res://scenes/ui/smart_purse_modal.tscn" id="8_purse"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="CircleShape2D" id="CircleShape2D_area"]
radius = 45.0

[node name="Level3" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalExit" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 4
target_spawn_x = 100.0
portal_name = "ลงรถที่สถานีขนส่ง"

[node name="ConductorArea" type="Area2D" parent="."]
position = Vector2(400, 580)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="ConductorArea"]
shape = SubResource("CircleShape2D_area")

[node name="ColorRect" type="ColorRect" parent="ConductorArea"]
offset_left = -25.0
offset_top = -50.0
offset_right = 25.0
offset_bottom = 50.0
color = Color(0.2, 0.5, 0.8, 1)

[node name="Label" type="Label" parent="ConductorArea"]
offset_left = -60.0
offset_top = -75.0
offset_right = 60.0
offset_bottom = -55.0
theme_override_font_size = 12
text = "กระเป๋ารถเมล์"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="ConductorArea"]
visible = false
offset_left = -80.0
offset_top = -95.0
offset_right = 80.0
offset_bottom = -75.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E/Shift] จ่ายค่ารถ 16 บาท"
horizontal_alignment = 1

[node name="GrandmaArea" type="Area2D" parent="."]
position = Vector2(800, 580)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="GrandmaArea"]
shape = SubResource("CircleShape2D_area")

[node name="ColorRect" type="ColorRect" parent="GrandmaArea"]
offset_left = -25.0
offset_top = -45.0
offset_right = 25.0
offset_bottom = 45.0
color = Color(0.8, 0.6, 0.8, 1)

[node name="Label" type="Label" parent="GrandmaArea"]
offset_left = -60.0
offset_top = -70.0
offset_right = 60.0
offset_bottom = -50.0
theme_override_font_size = 12
text = "คุณยายถือของหนัก"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="GrandmaArea"]
visible = false
offset_left = -80.0
offset_top = -90.0
offset_right = 80.0
offset_bottom = -70.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E/Shift] สละที่นั่งให้คุณยาย"
horizontal_alignment = 1

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]

[node name="SmartPurseModal" parent="." instance=ExtResource("8_purse")]
"""
write_scene("level_3.tscn", lvl_3)

# Level 4: สถานีขนส่ง & รถสองแถว
lvl_4 = """[gd_scene load_steps=10 format=3 uid="uid://lvl04terminal001"]

[ext_resource type="Script" path="res://scripts/level_4.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_4_terminal.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="CircleShape2D" id="CircleShape2D_board"]
radius = 45.0

[node name="Level4" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalSchool" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 5
target_spawn_x = 100.0
portal_name = "ลงรถหน้าโรงเรียน"

[node name="InfoBoard" type="Area2D" parent="."]
position = Vector2(300, 580)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="InfoBoard"]
shape = SubResource("CircleShape2D_board")

[node name="ColorRect" type="ColorRect" parent="InfoBoard"]
offset_left = -30.0
offset_top = -50.0
offset_right = 30.0
offset_bottom = 50.0
color = Color(0.2, 0.6, 0.4, 1)

[node name="Label" type="Label" parent="InfoBoard"]
offset_left = -70.0
offset_top = -75.0
offset_right = 70.0
offset_bottom = -55.0
theme_override_font_size = 12
text = "ป้ายตารางเดินรถ"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="InfoBoard"]
visible = false
offset_left = -70.0
offset_top = -95.0
offset_right = 70.0
offset_bottom = -75.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E] อ่านตารางเดินรถ"
horizontal_alignment = 1

[node name="SongthaewContainer" type="HBoxContainer" parent="."]
offset_left = 500.0
offset_top = 540.0
offset_right = 950.0
offset_bottom = 630.0
theme_override_constants/separation = 20

[node name="BtnRed" type="Button" parent="SongthaewContainer"]
custom_minimum_size = Vector2(120, 60)
layout_mode = 2
theme_override_colors/font_color = Color(1, 0.4, 0.4, 1)
text = "🔴 สองแถวสีแดง\n(ไปตลาด)"

[node name="BtnGreen" type="Button" parent="SongthaewContainer"]
custom_minimum_size = Vector2(120, 60)
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 1, 0.4, 1)
text = "🟢 สองแถวสีเขียว\n(ไปโรงพยาบาล)"

[node name="BtnBlue" type="Button" parent="SongthaewContainer"]
custom_minimum_size = Vector2(130, 60)
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.7, 1, 1)
text = "🔵 สองแถวสีฟ้า\n(ผ่านโรงเรียน!)"

[node name="SongthaewBlue" type="Node2D" parent="."]
position = Vector2(980, 580)

[node name="BtnBell" type="Button" parent="SongthaewBlue"]
visible = false
offset_left = -60.0
offset_top = -120.0
offset_right = 60.0
offset_bottom = -70.0
theme_override_colors/font_color = Color(1, 1, 0.2, 1)
theme_override_font_size = 13
text = "🔔 กดกริ่งลงป้าย!"

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_4.tscn", lvl_4)

# Level 5: หน้าโรงเรียน & อาคารเรียน
lvl_5 = """[gd_scene load_steps=10 format=3 uid="uid://lvl05school001"]

[ext_resource type="Script" path="res://scripts/level_5.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_5_school_gate.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="Script" path="res://scripts/npc_character.gd" id="8_npc"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="CircleShape2D" id="CircleShape2D_guard"]
radius = 45.0

[node name="Level5" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalClassroom" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 6
target_spawn_x = 100.0
portal_name = "เข้าห้องเรียนชั้น 2"

[node name="GuardNPC" type="Area2D" parent="."]
position = Vector2(300, 580)
collision_layer = 0
collision_mask = 2
script = ExtResource("8_npc")
npc_name = "ลุง รปภ. หน้าโรงเรียน"
dialog_lines = PackedStringArray("สวัสดีจ้ะเด็กๆ! คุณครูลืมสมุดเช็คชื่อและกุญแจห้องไว้ที่ป้อมยามพอดี ลุงฝากเอาขึ้นไปเปิดห้องเรียนชั้น 2 ให้หน่อยนะจ๊ะ!")

[node name="CollisionShape2D" type="CollisionShape2D" parent="GuardNPC"]
shape = SubResource("CircleShape2D_guard")

[node name="ColorRect" type="ColorRect" parent="GuardNPC"]
offset_left = -25.0
offset_top = -50.0
offset_right = 25.0
offset_bottom = 50.0
color = Color(0.3, 0.4, 0.6, 1)

[node name="Label" type="Label" parent="GuardNPC"]
offset_left = -60.0
offset_top = -75.0
offset_right = 60.0
offset_bottom = -55.0
theme_override_font_size = 12
text = "ป้อมยามลุง รปภ."
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="GuardNPC"]
visible = false
offset_left = -80.0
offset_top = -95.0
offset_right = 80.0
offset_bottom = -75.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E/Shift] ขอกุญแจห้องเรียน"
horizontal_alignment = 1

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_5.tscn", lvl_5)

# Level 6: คาบเรียนหรรษา
lvl_6 = """[gd_scene load_steps=9 format=3 uid="uid://lvl06classroom001"]

[ext_resource type="Script" path="res://scripts/level_6.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_6_classroom.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[node name="Level6" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalCanteen" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 7
target_spawn_x = 100.0
portal_name = "ไปโรงอาหารพักเที่ยง"

[node name="Blackboard" type="Panel" parent="."]
offset_left = 280.0
offset_top = 80.0
offset_right = 1000.0
offset_bottom = 260.0

[node name="QuestionLabel" type="Label" parent="Blackboard"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 20.0
offset_top = 20.0
offset_right = -20.0
offset_bottom = -50.0
grow_horizontal = 2
grow_vertical = 2
theme_override_colors/font_color = Color(1, 1, 0.5, 1)
theme_override_font_size = 15
text = "คำถามคาบเรียนหรรษา..."
autowrap_mode = 3

[node name="ExplanationLabel" type="Label" parent="Blackboard"]
layout_mode = 1
anchors_preset = 12
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 20.0
offset_top = -45.0
offset_right = -20.0
offset_bottom = -15.0
grow_horizontal = 2
grow_vertical = 0
theme_override_colors/font_color = Color(0.4, 1, 0.6, 1)
theme_override_font_size = 13
text = "เลือกแท่นคำตอบ ก, ข, หรือ ค ด้านล่าง"

[node name="PlatformA" type="StaticBody2D" parent="."]
position = Vector2(400, 540)
collision_layer = 1
collision_mask = 6

[node name="ColorRect" type="ColorRect" parent="PlatformA"]
offset_left = -70.0
offset_top = -15.0
offset_right = 70.0
offset_bottom = 15.0
color = Color(0.8, 0.4, 0.4, 1)

[node name="Label" type="Label" parent="PlatformA"]
offset_left = -65.0
offset_top = -12.0
offset_right = 65.0
offset_bottom = 12.0
theme_override_font_size = 12
text = "ก. ช้อยส์ 1"
horizontal_alignment = 1

[node name="BtnChooseA" type="Button" parent="PlatformA"]
offset_left = -70.0
offset_top = 20.0
offset_right = 70.0
offset_bottom = 50.0
theme_override_font_size = 11
text = "เลือกข้อ ก"

[node name="PlatformB" type="StaticBody2D" parent="."]
position = Vector2(640, 540)
collision_layer = 1
collision_mask = 6

[node name="ColorRect" type="ColorRect" parent="PlatformB"]
offset_left = -70.0
offset_top = -15.0
offset_right = 70.0
offset_bottom = 15.0
color = Color(0.4, 0.8, 0.4, 1)

[node name="Label" type="Label" parent="PlatformB"]
offset_left = -65.0
offset_top = -12.0
offset_right = 65.0
offset_bottom = 12.0
theme_override_font_size = 12
text = "ข. ช้อยส์ 2"
horizontal_alignment = 1

[node name="BtnChooseB" type="Button" parent="PlatformB"]
offset_left = -70.0
offset_top = 20.0
offset_right = 70.0
offset_bottom = 50.0
theme_override_font_size = 11
text = "เลือกข้อ ข"

[node name="PlatformC" type="StaticBody2D" parent="."]
position = Vector2(880, 540)
collision_layer = 1
collision_mask = 6

[node name="ColorRect" type="ColorRect" parent="PlatformC"]
offset_left = -70.0
offset_top = -15.0
offset_right = 70.0
offset_bottom = 15.0
color = Color(0.4, 0.6, 0.9, 1)

[node name="Label" type="Label" parent="PlatformC"]
offset_left = -65.0
offset_top = -12.0
offset_right = 65.0
offset_bottom = 12.0
theme_override_font_size = 12
text = "ค. ช้อยส์ 3"
horizontal_alignment = 1

[node name="BtnChooseC" type="Button" parent="PlatformC"]
offset_left = -70.0
offset_top = 20.0
offset_right = 70.0
offset_bottom = 50.0
theme_override_font_size = 11
text = "เลือกข้อ ค"

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_6.tscn", lvl_6)

# Level 7: โรงอาหาร พักเที่ยง
lvl_7 = """[gd_scene load_steps=12 format=3 uid="uid://lvl07canteen001"]

[ext_resource type="Script" path="res://scripts/level_7.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_7_canteen.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="Script" path="res://scripts/interactable_item.gd" id="8_item"]
[ext_resource type="Texture2D" path="res://assets/items/item_watering_can.png" id="9_cantex"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="CircleShape2D" id="CircleShape2D_item"]
radius = 35.0

[node name="Level7" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalBackClassroom" parent="." instance=ExtResource("5_portal")]
position = Vector2(80, 640)
target_level = 6
target_spawn_x = 1100.0
portal_name = "ย้อนกลับห้องเรียน"

[node name="PortalGarden" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 8
target_spawn_x = 100.0
portal_name = "ออกไปแปลงเกษตร"

[node name="LunchCounter" type="Panel" parent="."]
offset_left = 320.0
offset_top = 480.0
offset_right = 580.0
offset_bottom = 630.0

[node name="Label" type="Label" parent="LunchCounter"]
layout_mode = 0
offset_left = 15.0
offset_top = 10.0
offset_right = 245.0
offset_bottom = 35.0
theme_override_font_size = 13
text = "🍱 เคาน์เตอร์อาหารกลางวัน (งบ 40 ฿)"

[node name="BtnHealthy" type="Button" parent="LunchCounter"]
layout_mode = 0
offset_left = 15.0
offset_top = 45.0
offset_right = 245.0
offset_bottom = 85.0
theme_override_colors/font_color = Color(0.4, 1, 0.4, 1)
theme_override_font_size = 11
text = "🥗 ข้าวผัดไข่ผักรวม + ส้ม (35 ฿)\n(สารอาหารครบ 5 หมู่!)"

[node name="BtnJunk" type="Button" parent="LunchCounter"]
layout_mode = 0
offset_left = 15.0
offset_top = 95.0
offset_right = 245.0
offset_bottom = 135.0
theme_override_colors/font_color = Color(1, 0.4, 0.4, 1)
theme_override_font_size = 11
text = "🍟 ขนมกรุบกรอบ + น้ำอัดลม (45 ฿)\n(เกินงบและไม่มีประโยชน์)"

[node name="RecycleStation" type="Panel" parent="."]
offset_left = 650.0
offset_top = 480.0
offset_right = 910.0
offset_bottom = 630.0

[node name="Label" type="Label" parent="RecycleStation"]
layout_mode = 0
offset_left = 15.0
offset_top = 10.0
offset_right = 245.0
offset_bottom = 35.0
theme_override_font_size = 13
text = "♻️ จุดคัดแยกขยะ 3 สี"

[node name="BtnSort" type="Button" parent="RecycleStation"]
layout_mode = 0
offset_left = 15.0
offset_top = 55.0
offset_right = 245.0
offset_bottom = 115.0
theme_override_font_size = 12
text = "🗑️ คัดแยกเศษอาหาร, พลาสติก,\nและขยะทั่วไปลงถังถูกต้อง"

[node name="StorageRoom" type="Node2D" parent="."]
position = Vector2(980, 580)

[node name="BtnPeemaiCrawl" type="Button" parent="StorageRoom"]
offset_left = -60.0
offset_top = -120.0
offset_right = 60.0
offset_bottom = -70.0
theme_override_colors/font_color = Color(0.4, 0.8, 1, 1)
theme_override_font_size = 11
text = "🚪 น้องปีใหม่มุดช่องลม\nปลดล็อกห้องเก็บของ"

[node name="ItemWateringCan" type="Area2D" parent="StorageRoom"]
visible = false
position = Vector2(0, -30)
collision_layer = 0
collision_mask = 2
script = ExtResource("8_item")
item_name = "บัวรดน้ำ"
pickup_message = "หยิบ 'บัวรดน้ำ' จากห้องเก็บของสำเร็จ! นำกลับไปรดน้ำที่แปลงเกษตร [ฉากที่ 8] กันเถอะ!"

[node name="CollisionShape2D" type="CollisionShape2D" parent="StorageRoom/ItemWateringCan"]
shape = SubResource("CircleShape2D_item")

[node name="Sprite2D" type="Sprite2D" parent="StorageRoom/ItemWateringCan"]
scale = Vector2(0.5, 0.5)
texture = ExtResource("9_cantex")

[node name="PromptLabel" type="Label" parent="StorageRoom/ItemWateringCan"]
visible = false
offset_left = -70.0
offset_top = -45.0
offset_right = 70.0
offset_bottom = -25.0
theme_override_font_size = 11
text = "[E] หยิบบัวรดน้ำ"
horizontal_alignment = 1

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_7.tscn", lvl_7)

# Level 8: สำรวจโรงเรียนตอนบ่าย & แปลงเกษตร
lvl_8 = """[gd_scene load_steps=9 format=3 uid="uid://lvl08garden001"]

[ext_resource type="Script" path="res://scripts/level_8.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_8_garden.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_flower"]
size = Vector2(160, 80)

[node name="Level8" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalBackCanteen" parent="." instance=ExtResource("5_portal")]
position = Vector2(80, 640)
target_level = 7
target_spawn_x = 1100.0
portal_name = "ย้อนกลับโรงอาหาร (เอาบัวรดน้ำ)"

[node name="PortalReturnBus" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 9
target_spawn_x = 100.0
portal_name = "ขึ้นรถสองแถวกลับบ้าน"

[node name="FlowerArea" type="Area2D" parent="."]
position = Vector2(650, 600)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="FlowerArea"]
shape = SubResource("RectangleShape2D_flower")

[node name="FlowerSprite" type="ColorRect" parent="FlowerArea"]
offset_left = -70.0
offset_top = -25.0
offset_right = 70.0
offset_bottom = 25.0
color = Color(0.8, 0.4, 0.6, 1)

[node name="Label" type="Label" parent="FlowerArea"]
offset_left = -80.0
offset_top = -45.0
offset_right = 80.0
offset_bottom = -25.0
theme_override_font_size = 12
text = "🌸 แปลงดอกไม้เหี่ยวเฉา"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="FlowerArea"]
visible = false
offset_left = -110.0
offset_top = -70.0
offset_right = 110.0
offset_bottom = -50.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[Q/Shift] รดน้ำแปลงดอกไม้"
horizontal_alignment = 1

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_8.tscn", lvl_8)

# Level 9: รถสองแถวขากลับ
lvl_9 = """[gd_scene load_steps=12 format=3 uid="uid://lvl09return001"]

[ext_resource type="Script" path="res://scripts/level_9.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_9_songthaew_return.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="Script" path="res://scripts/pushable_object.gd" id="8_bag"]
[ext_resource type="Script" path="res://scripts/interactable_item.gd" id="9_item"]
[ext_resource type="Texture2D" path="res://assets/items/item_coin_10.png" id="10_cointex"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_bag"]
size = Vector2(80, 70)

[sub_resource type="CircleShape2D" id="CircleShape2D_item"]
radius = 30.0

[sub_resource type="CircleShape2D" id="CircleShape2D_driver"]
radius = 45.0

[node name="Level9" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalTerminal" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 10
target_spawn_x = 100.0
portal_name = "ต่อรถเมล์สายหลักที่สถานี"

[node name="HeavyBag" type="CharacterBody2D" parent="."]
position = Vector2(550, 605)
collision_layer = 4
collision_mask = 3
script = ExtResource("8_bag")
object_name = "กระเป๋าใบใหญ่"

[node name="CollisionShape2D" type="CollisionShape2D" parent="HeavyBag"]
shape = SubResource("RectangleShape2D_bag")

[node name="ColorRect" type="ColorRect" parent="HeavyBag"]
offset_left = -40.0
offset_top = -35.0
offset_right = 40.0
offset_bottom = 35.0
color = Color(0.3, 0.4, 0.7, 1)

[node name="Label" type="Label" parent="HeavyBag"]
offset_left = -40.0
offset_top = -10.0
offset_right = 40.0
offset_bottom = 15.0
theme_override_font_size = 11
text = "กระเป๋าขวางอยู่"
horizontal_alignment = 1

[node name="CoinItem" type="Area2D" parent="."]
position = Vector2(620, 620)
collision_layer = 0
collision_mask = 2
script = ExtResource("9_item")
item_name = "เหรียญ 10 บาท"
pickup_message = "น้องปีใหม่มุดใต้เบาะเก็บ 'เหรียญ 10 บาท' ได้แล้ว!"
requires_crawling = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="CoinItem"]
shape = SubResource("CircleShape2D_item")

[node name="Sprite2D" type="Sprite2D" parent="CoinItem"]
scale = Vector2(0.4, 0.4)
texture = ExtResource("10_cointex")

[node name="PromptLabel" type="Label" parent="CoinItem"]
visible = false
offset_left = -70.0
offset_top = -45.0
offset_right = 70.0
offset_bottom = -25.0
theme_override_font_size = 11
text = "[Shift] มุดเก็บเหรียญ"
horizontal_alignment = 1

[node name="DriverArea" type="Area2D" parent="."]
position = Vector2(950, 580)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="DriverArea"]
shape = SubResource("CircleShape2D_driver")

[node name="ColorRect" type="ColorRect" parent="DriverArea"]
offset_left = -25.0
offset_top = -45.0
offset_right = 25.0
offset_bottom = 45.0
color = Color(0.8, 0.5, 0.2, 1)

[node name="Label" type="Label" parent="DriverArea"]
offset_left = -60.0
offset_top = -70.0
offset_right = 60.0
offset_bottom = -50.0
theme_override_font_size = 12
text = "คนขับสองแถว"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="DriverArea"]
visible = false
offset_left = -80.0
offset_top = -90.0
offset_right = 80.0
offset_bottom = -70.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E/Shift] จ่ายค่ารถ 10 บาท"
horizontal_alignment = 1

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_9.tscn", lvl_9)

# Level 10: รถเมล์สายหลัก ขากลับบ้าน
lvl_10 = """[gd_scene load_steps=12 format=3 uid="uid://lvl10busreturn001"]

[ext_resource type="Script" path="res://scripts/level_10.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_10_bus_return.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="Script" path="res://scripts/interactable_item.gd" id="8_item"]
[ext_resource type="Texture2D" path="res://assets/items/item_wallet.png" id="9_waltex"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="CircleShape2D" id="CircleShape2D_item"]
radius = 30.0

[sub_resource type="CircleShape2D" id="CircleShape2D_npc"]
radius = 45.0

[node name="Level10" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="PortalVillage" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 11
target_spawn_x = 100.0
portal_name = "ลงรถหน้าปากซอยบ้าน"

[node name="ItemWallet" type="Area2D" parent="."]
position = Vector2(450, 610)
collision_layer = 0
collision_mask = 2
script = ExtResource("8_item")
item_name = "กระเป๋าสตางค์"
pickup_message = "น้องปีใหม่ตาไวเห็น 'กระเป๋าสตางค์' ตกอยู่บนพื้นรถเมล์! รีบนำไปคืนพี่ผู้หญิงข้างหน้ากัน!"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ItemWallet"]
shape = SubResource("CircleShape2D_item")

[node name="Sprite2D" type="Sprite2D" parent="ItemWallet"]
scale = Vector2(0.45, 0.45)
texture = ExtResource("9_waltex")

[node name="PromptLabel" type="Label" parent="ItemWallet"]
visible = false
offset_left = -70.0
offset_top = -45.0
offset_right = 70.0
offset_bottom = -25.0
theme_override_font_size = 11
text = "[E/Shift] เก็บกระเป๋าเงิน"
horizontal_alignment = 1

[node name="PassengerWoman" type="Area2D" parent="."]
position = Vector2(620, 580)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="PassengerWoman"]
shape = SubResource("CircleShape2D_npc")

[node name="ColorRect" type="ColorRect" parent="PassengerWoman"]
offset_left = -25.0
offset_top = -45.0
offset_right = 25.0
offset_bottom = 45.0
color = Color(0.9, 0.5, 0.7, 1)

[node name="Label" type="Label" parent="PassengerWoman"]
offset_left = -60.0
offset_top = -70.0
offset_right = 60.0
offset_bottom = -50.0
theme_override_font_size = 12
text = "พี่ผู้โดยสาร"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="PassengerWoman"]
visible = false
offset_left = -80.0
offset_top = -90.0
offset_right = 80.0
offset_bottom = -70.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E/Shift] คืนกระเป๋าสตางค์"
horizontal_alignment = 1

[node name="StrangerMan" type="Area2D" parent="."]
position = Vector2(900, 580)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="StrangerMan"]
shape = SubResource("CircleShape2D_npc")

[node name="ColorRect" type="ColorRect" parent="StrangerMan"]
offset_left = -25.0
offset_top = -50.0
offset_right = 25.0
offset_bottom = 50.0
color = Color(0.5, 0.4, 0.3, 1)

[node name="Label" type="Label" parent="StrangerMan"]
offset_left = -60.0
offset_top = -75.0
offset_right = 60.0
offset_bottom = -55.0
theme_override_font_size = 12
text = "คนแปลกหน้า"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="StrangerMan"]
visible = false
offset_left = -80.0
offset_top = -95.0
offset_right = 80.0
offset_bottom = -75.0
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 11
text = "[E/Shift] คุยกับคนแปลกหน้า"
horizontal_alignment = 1

[node name="ChoiceContainer" type="HBoxContainer" parent="StrangerMan"]
visible = false
offset_left = -150.0
offset_top = -140.0
offset_right = 150.0
offset_bottom = -100.0
theme_override_constants/separation = 12

[node name="BtnRefuse" type="Button" parent="StrangerMan/ChoiceContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 1, 0.4, 1)
theme_override_font_size = 11
text = "✅ ปฏิเสธอย่างสุภาพ\n(ไม่รับของ/ไม่ตามไป)"

[node name="BtnAccept" type="Button" parent="StrangerMan/ChoiceContainer"]
layout_mode = 2
theme_override_colors/font_color = Color(1, 0.4, 0.4, 1)
theme_override_font_size = 11
text = "❌ รับขนมกิน\n(อันตราย!)"

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_10.tscn", lvl_10)

# Level 11: ซอยบ้านยามเย็น สายฝน
lvl_11 = """[gd_scene load_steps=9 format=3 uid="uid://lvl11rain001"]

[ext_resource type="Script" path="res://scripts/level_11.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_11_rainy_village.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="Texture2D" path="res://assets/items/item_umbrella.png" id="8_umbtex"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[node name="Level11" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="RainEffect" type="ColorRect" parent="."]
offset_right = 1280.0
offset_bottom = 720.0
mouse_filter = 2
color = Color(0.1, 0.2, 0.4, 0.2)

[node name="PortalSweetHome" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 12
target_spawn_x = 100.0
portal_name = "เข้าประตูบ้านแสนสุข"

[node name="UmbrellaVisual" type="Sprite2D" parent="."]
visible = false
scale = Vector2(0.8, 0.8)
texture = ExtResource("8_umbtex")

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("6_hud")]

[node name="DialogModal" parent="." instance=ExtResource("7_dlg")]
"""
write_scene("level_11.tscn", lvl_11)

# Level 12: ถึงบ้านแสนสุข เข้านอน
lvl_12 = """[gd_scene load_steps=9 format=3 uid="uid://lvl12home001"]

[ext_resource type="Script" path="res://scripts/level_12.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_12_home_night.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="5_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="6_dlg"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="CircleShape2D" id="CircleShape2D_parents"]
radius = 50.0

[sub_resource type="CircleShape2D" id="CircleShape2D_switch"]
radius = 35.0

[node name="Level12" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
position = Vector2(640, 360)
scale = Vector2(1.67, 1.41)
texture = ExtResource("2_bg")

[node name="Floor" type="StaticBody2D" parent="."]
position = Vector2(640, 640)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="Floor"]
shape = SubResource("WorldBoundaryShape2D_floor")

[node name="ParentsArea" type="Area2D" parent="."]
position = Vector2(400, 580)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="ParentsArea"]
shape = SubResource("CircleShape2D_parents")

[node name="ColorRect" type="ColorRect" parent="ParentsArea"]
offset_left = -35.0
offset_top = -50.0
offset_right = 35.0
offset_bottom = 50.0
color = Color(0.9, 0.7, 0.4, 1)

[node name="Label" type="Label" parent="ParentsArea"]
offset_left = -70.0
offset_top = -75.0
offset_right = 70.0
offset_bottom = -55.0
theme_override_font_size = 12
text = "คุณพ่อคุณแม่"
horizontal_alignment = 1

[node name="LightSwitchArea" type="Area2D" parent="."]
position = Vector2(900, 550)
collision_layer = 0
collision_mask = 2

[node name="CollisionShape2D" type="CollisionShape2D" parent="LightSwitchArea"]
shape = SubResource("CircleShape2D_switch")

[node name="ColorRect" type="ColorRect" parent="LightSwitchArea"]
offset_left = -15.0
offset_top = -20.0
offset_right = 15.0
offset_bottom = 20.0
color = Color(1, 1, 0.8, 1)

[node name="Label" type="Label" parent="LightSwitchArea"]
offset_left = -50.0
offset_top = -45.0
offset_right = 50.0
offset_bottom = -25.0
theme_override_font_size = 11
text = "สวิตช์ปิดไฟ"
horizontal_alignment = 1

[node name="PromptLabel" type="Label" parent="LightSwitchArea"]
visible = false
offset_left = -60.0
offset_top = -65.0
offset_right = 60.0
offset_bottom = -45.0
theme_override_colors/font_color = Color(1, 1, 0.3, 1)
theme_override_font_size = 11
text = "[E/Shift] ปิดไฟเข้านอน"
horizontal_alignment = 1

[node name="NightOverlay" type="ColorRect" parent="."]
offset_right = 1280.0
offset_bottom = 720.0
mouse_filter = 2
color = Color(0, 0, 0, 0)

[node name="Players" type="Node2D" parent="."]

[node name="PlayerKhongkwan" parent="Players" instance=ExtResource("3_p1")]
position = Vector2(180, 640)

[node name="PlayerPeemai" parent="Players" instance=ExtResource("4_p2")]
position = Vector2(120, 640)

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2(640, 360)

[node name="HUD" parent="." instance=ExtResource("5_hud")]

[node name="DialogModal" parent="." instance=ExtResource("6_dlg")]

[node name="CanvasLayer" type="CanvasLayer" parent="."]
layer = 20

[node name="RecapPanel" type="Panel" parent="CanvasLayer"]
visible = false
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -350.0
offset_top = -200.0
offset_right = 350.0
offset_bottom = 200.0
grow_horizontal = 2
grow_vertical = 2

[node name="VBox" type="VBoxContainer" parent="CanvasLayer/RecapPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 30.0
offset_top = 20.0
offset_right = -30.0
offset_bottom = -20.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 12

[node name="Title" type="Label" parent="CanvasLayer/RecapPanel/VBox"]
layout_mode = 2
theme_override_colors/font_color = Color(1, 0.85, 0.3, 1)
theme_override_font_size = 17
text = "📝 ทบทวนสิ่งที่เรียนรู้ในวันนี้ (Daily Recap)"
horizontal_alignment = 1

[node name="Q1" type="Label" parent="CanvasLayer/RecapPanel/VBox"]
layout_mode = 2
theme_override_font_size = 13
text = "1. วันนี้จ่ายค่ารถเมล์นักเรียน 2 คน รวมกี่บาท?  ->  [16 บาท]"

[node name="Q2" type="Label" parent="CanvasLayer/RecapPanel/VBox"]
layout_mode = 2
theme_override_font_size = 13
text = "2. เก็บสิ่งของคืนพี่ผู้โดยสารบนรถเมล์ได้คืออะไร?  ->  [กระเป๋าสตางค์]"

[node name="Q3" type="Label" parent="CanvasLayer/RecapPanel/VBox"]
layout_mode = 2
theme_override_font_size = 13
text = "3. เมื่อคนแปลกหน้ามาชวนคุยและให้ขนม ควรทำอย่างไร?  ->  [ปฏิเสธอย่างสุภาพ]"

[node name="BtnSubmitRecap" type="Button" parent="CanvasLayer/RecapPanel/VBox"]
custom_minimum_size = Vector2(160, 45)
layout_mode = 2
size_flags_horizontal = 4
text = "✅ บันทึกการบ้านเรียบร้อย"

[node name="VictoryPanel" type="Panel" parent="CanvasLayer"]
visible = false
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -380.0
offset_top = -220.0
offset_right = 380.0
offset_bottom = 220.0
grow_horizontal = 2
grow_vertical = 2

[node name="VBox" type="VBoxContainer" parent="CanvasLayer/VictoryPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 30.0
offset_top = 25.0
offset_right = -30.0
offset_bottom = -25.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 16

[node name="Title" type="Label" parent="CanvasLayer/VictoryPanel/VBox"]
layout_mode = 2
theme_override_colors/font_color = Color(1, 0.9, 0.2, 1)
theme_override_font_size = 22
text = "🌟 ภารกิจผจญภัยไปโรงเรียนสำเร็จสมบูรณ์! 🌟"
horizontal_alignment = 1

[node name="Subtitle" type="Label" parent="CanvasLayer/VictoryPanel/VBox"]
layout_mode = 2
theme_override_font_size = 15
text = "พี่ของขวัญและน้องปีใหม่เข้านอนอย่างอบอุ่นและปลอดภัย\nพร้อมความรู้ มารยาท และทักษะชีวิตที่ยอดเยี่ยม!"
horizontal_alignment = 1

[node name="StarsScoreLabel" type="Label" parent="CanvasLayer/VictoryPanel/VBox"]
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 1, 0.5, 1)
theme_override_font_size = 18
text = "⭐ ดาวมารยาทดีที่ได้รับทั้งหมด: 15 ดวง ⭐"
horizontal_alignment = 1

[node name="BtnRestart" type="Button" parent="CanvasLayer/VictoryPanel/VBox"]
custom_minimum_size = Vector2(180, 50)
layout_mode = 2
size_flags_horizontal = 4
theme_override_font_size = 15
text = "🔄 เล่นใหม่อีกครั้ง"
"""
write_scene("level_12.tscn", lvl_12)

print("All level scenes (1-12) generated successfully!")
