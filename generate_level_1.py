import os

SCENES_DIR = r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\scenes\levels"
os.makedirs(SCENES_DIR, exist_ok=True)

# Generate Level 1: In Home Morning
level_1_tscn = """[gd_scene load_steps=10 format=3 uid="uid://lvl01home001"]

[ext_resource type="Script" path="res://scripts/level_1.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/backgrounds/bg_scene_1_home.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/player_khongkwan.tscn" id="3_p1"]
[ext_resource type="PackedScene" path="res://scenes/player_peemai.tscn" id="4_p2"]
[ext_resource type="PackedScene" path="res://scenes/portal.tscn" id="5_portal"]
[ext_resource type="PackedScene" path="res://scenes/ui/hud.tscn" id="6_hud"]
[ext_resource type="PackedScene" path="res://scenes/ui/dialog_modal.tscn" id="7_dlg"]
[ext_resource type="Script" path="res://scripts/pushable_object.gd" id="8_chair"]
[ext_resource type="Script" path="res://scripts/interactable_item.gd" id="9_item"]
[ext_resource type="Texture2D" path="res://assets/items/item_house_key.png" id="10_keytex"]
[ext_resource type="Texture2D" path="res://assets/items/item_student_card.png" id="11_cardtex"]
[ext_resource type="Texture2D" path="res://assets/items/item_umbrella.png" id="12_umbtex"]

[sub_resource type="WorldBoundaryShape2D" id="WorldBoundaryShape2D_floor"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_wall"]
size = Vector2(40, 720)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_chair"]
size = Vector2(70, 60)

[sub_resource type="CircleShape2D" id="CircleShape2D_item"]
radius = 35.0

[node name="Level1" type="Node2D"]
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

[node name="PortalDoor" parent="." instance=ExtResource("5_portal")]
position = Vector2(1180, 640)
target_level = 2
target_spawn_x = 100.0
portal_name = "ประตูหน้าบ้าน"

[node name="PushableChair" type="CharacterBody2D" parent="."]
position = Vector2(500, 610)
collision_layer = 4
collision_mask = 3
script = ExtResource("8_chair")
object_name = "เก้าอี้ไม้"

[node name="CollisionShape2D" type="CollisionShape2D" parent="PushableChair"]
shape = SubResource("RectangleShape2D_chair")

[node name="ColorRect" type="ColorRect" parent="PushableChair"]
offset_left = -35.0
offset_top = -30.0
offset_right = 35.0
offset_bottom = 30.0
color = Color(0.72, 0.45, 0.2, 1)

[node name="Label" type="Label" parent="PushableChair"]
offset_left = -40.0
offset_top = -45.0
offset_right = 40.0
offset_bottom = -25.0
theme_override_font_size = 11
text = "เก้าอี้ไม้ (ดันได้)"
horizontal_alignment = 1

[node name="FridgePlatform" type="StaticBody2D" parent="."]
position = Vector2(850, 480)
collision_layer = 1
collision_mask = 6

[node name="CollisionShape2D" type="CollisionShape2D" parent="FridgePlatform"]
shape = SubResource("RectangleShape2D_chair")

[node name="ColorRect" type="ColorRect" parent="FridgePlatform"]
offset_left = -40.0
offset_top = -60.0
offset_right = 40.0
offset_bottom = 60.0
color = Color(0.85, 0.9, 0.95, 1)

[node name="Label" type="Label" parent="FridgePlatform"]
offset_left = -40.0
offset_top = -10.0
offset_right = 40.0
offset_bottom = 15.0
theme_override_colors/font_color = Color(0.2, 0.3, 0.5, 1)
theme_override_font_size = 13
text = "ตู้เย็น"
horizontal_alignment = 1

[node name="ItemKey" type="Area2D" parent="."]
position = Vector2(850, 380)
collision_layer = 0
collision_mask = 2
script = ExtResource("9_item")
item_name = "กุญแจบ้าน"
pickup_message = "หยิบ 'กุญแจบ้าน' บนหลังตู้เย็นได้แล้ว! รีบนำไปไขประตูหน้าบ้านเลย!"
required_height_character = "player1"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ItemKey"]
shape = SubResource("CircleShape2D_item")

[node name="Sprite2D" type="Sprite2D" parent="ItemKey"]
scale = Vector2(0.5, 0.5)
texture = ExtResource("10_keytex")

[node name="PromptLabel" type="Label" parent="ItemKey"]
visible = false
offset_left = -70.0
offset_top = -50.0
offset_right = 70.0
offset_bottom = -30.0
theme_override_font_size = 12
text = "[E] เก็บกุญแจ"
horizontal_alignment = 1

[node name="ItemCard" type="Area2D" parent="."]
visible = false
position = Vector2(300, 610)
collision_layer = 0
collision_mask = 2
script = ExtResource("9_item")
item_name = "บัตรนักเรียน"
pickup_message = "น้องปีใหม่มุดใต้โซฟาหยิบ 'บัตรนักเรียน' สำเร็จแล้ว!"
requires_crawling = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="ItemCard"]
shape = SubResource("CircleShape2D_item")

[node name="Sprite2D" type="Sprite2D" parent="ItemCard"]
scale = Vector2(0.45, 0.45)
texture = ExtResource("11_cardtex")

[node name="PromptLabel" type="Label" parent="ItemCard"]
visible = false
offset_left = -80.0
offset_top = -45.0
offset_right = 80.0
offset_bottom = -25.0
theme_override_font_size = 11
text = "[Shift] มุดเก็บใต้โซฟา"
horizontal_alignment = 1

[node name="ItemUmbrella" type="Area2D" parent="."]
visible = false
position = Vector2(100, 570)
collision_layer = 0
collision_mask = 2
script = ExtResource("9_item")
item_name = "ร่ม"
pickup_message = "พี่ของขวัญหยิบ 'ร่มกันฝน' ที่ชั้นวางรองเท้าสำเร็จแล้ว!"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ItemUmbrella"]
shape = SubResource("CircleShape2D_item")

[node name="Sprite2D" type="Sprite2D" parent="ItemUmbrella"]
scale = Vector2(0.45, 0.45)
texture = ExtResource("12_umbtex")

[node name="PromptLabel" type="Label" parent="ItemUmbrella"]
visible = false
offset_left = -60.0
offset_top = -45.0
offset_right = 60.0
offset_bottom = -25.0
theme_override_font_size = 11
text = "[E] หยิบร่ม"
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

with open(os.path.join(SCENES_DIR, "level_1.tscn"), "w", encoding="utf-8") as f:
    f.write(level_1_tscn)

print("Generated level_1.tscn successfully.")
