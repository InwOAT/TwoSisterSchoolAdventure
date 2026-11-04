import bpy
import os
import math

# Output folders
BASE_DIR = r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\assets\environment"
SONGTHAEW_DIR = os.path.join(BASE_DIR, "songthaew_3d")
BEDROOM_DIR = os.path.join(BASE_DIR, "bedroom_3d")

os.makedirs(SONGTHAEW_DIR, exist_ok=True)
os.makedirs(BEDROOM_DIR, exist_ok=True)

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    # Set render engine to CYCLES or EEVEE
    scene = bpy.context.scene
    scene.render.engine = 'BLENDER_EEVEE_NEXT' if hasattr(bpy.types, 'RenderSettings') and 'BLENDER_EEVEE_NEXT' in [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties['engine'].enum_items] else 'BLENDER_EEVEE'
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'

    # Add key light
    light_data = bpy.data.lights.new(name="KeyLight", type='SUN')
    light_data.energy = 3.5
    light_data.color = (1.0, 0.95, 0.88)
    light_obj = bpy.data.objects.new(name="KeyLight", object_data=light_data)
    light_obj.rotation_euler = (math.radians(45), math.radians(25), math.radians(45))
    bpy.context.collection.objects.link(light_obj)

    # Add fill light
    fill_data = bpy.data.lights.new(name="FillLight", type='SUN')
    fill_data.energy = 1.8
    fill_data.color = (0.75, 0.88, 1.0)
    fill_obj = bpy.data.objects.new(name="FillLight", object_data=fill_data)
    fill_obj.rotation_euler = (math.radians(50), math.radians(-40), math.radians(-30))
    bpy.context.collection.objects.link(fill_obj)

def setup_camera(location, target, ortho_scale, res_x=512, res_y=512):
    cam_data = bpy.data.cameras.new("OrthoCam")
    cam_data.type = 'ORTHO'
    cam_data.ortho_scale = ortho_scale
    cam_obj = bpy.data.objects.new("OrthoCam", cam_data)
    cam_obj.location = location
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj
    bpy.context.scene.render.resolution_x = res_x
    bpy.context.scene.render.resolution_y = res_y

    # Aim camera at target
    dx = target[0] - location[0]
    dy = target[1] - location[1]
    dz = target[2] - location[2]
    dist = math.sqrt(dx*dx + dy*dy + dz*dz)
    cam_obj.rotation_euler = (math.acos(dz/dist) if dist > 0 else 0, 0, math.atan2(dy, dx) + math.pi/2)

def create_mat(name, color, roughness=0.4, metallic=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = (*color, 1.0)
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
    return mat

# --- 1. Songthaew Bench ---
def render_songthaew_bench():
    reset_scene()
    setup_camera((0, -8, 2.8), (0, 0, 0.6), ortho_scale=4.5, res_x=600, res_y=300)

    mat_cushion = create_mat("Cushion", (0.18, 0.38, 0.65), roughness=0.5)
    mat_wood = create_mat("Wood", (0.72, 0.45, 0.22), roughness=0.35)
    mat_metal = create_mat("Metal", (0.85, 0.88, 0.92), roughness=0.15, metallic=0.9)

    # Seat cushion
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.65))
    seat = bpy.context.active_object
    seat.scale = (3.6, 0.7, 0.16)
    seat.data.materials.append(mat_cushion)

    # Wooden backrest
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.38, 1.2))
    back = bpy.context.active_object
    back.scale = (3.6, 0.12, 0.7)
    back.data.materials.append(mat_wood)

    # Metal frame legs
    for x in [-1.5, 0.0, 1.5]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.6, location=(x, -0.25, 0.3))
        leg1 = bpy.context.active_object
        leg1.data.materials.append(mat_metal)
        bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.6, location=(x, 0.25, 0.3))
        leg2 = bpy.context.active_object
        leg2.data.materials.append(mat_metal)

    out_file = os.path.join(SONGTHAEW_DIR, "prop_songthaew_bench.png")
    bpy.context.scene.render.filepath = out_file
    bpy.ops.render.render(write_still=True)
    print("Rendered:", out_file)

# --- 2. Songthaew Grab Rail with Bell ---
def render_songthaew_rail():
    reset_scene()
    setup_camera((0, -6, 1.8), (0, 0, 1.5), ortho_scale=4.2, res_x=600, res_y=200)

    mat_chrome = create_mat("Chrome", (0.9, 0.92, 0.95), roughness=0.1, metallic=0.95)
    mat_bell = create_mat("BellRed", (0.9, 0.15, 0.15), roughness=0.3)
    mat_white = create_mat("WhiteButton", (0.95, 0.95, 0.95), roughness=0.2)

    # Horizontal handrail
    bpy.ops.mesh.primitive_cylinder_add(radius=0.045, depth=4.0, location=(0, 0, 1.7))
    bar = bpy.context.active_object
    bar.rotation_euler = (0, math.radians(90), 0)
    bar.data.materials.append(mat_chrome)

    # Ceiling mounting brackets
    for x in [-1.6, 0, 1.6]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.45, location=(x, 0, 1.9))
        bk = bpy.context.active_object
        bk.data.materials.append(mat_chrome)

    # Stop buzzer bells
    for x in [-0.8, 0.8]:
        bpy.ops.mesh.primitive_cube_add(size=0.18, location=(x, 0, 1.58))
        box = bpy.context.active_object
        box.data.materials.append(mat_bell)
        bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.06, location=(x, -0.09, 1.58))
        btn = bpy.context.active_object
        btn.rotation_euler = (math.radians(90), 0, 0)
        btn.data.materials.append(mat_white)

    out_file = os.path.join(SONGTHAEW_DIR, "prop_songthaew_rail.png")
    bpy.context.scene.render.filepath = out_file
    bpy.ops.render.render(write_still=True)
    print("Rendered:", out_file)

# --- 3. Bedroom Study Desk ---
def render_study_desk():
    reset_scene()
    setup_camera((0, -7, 2.5), (0, 0, 0.9), ortho_scale=3.8, res_x=450, res_y=400)

    mat_desk = create_mat("DeskWood", (0.85, 0.65, 0.42), roughness=0.3)
    mat_metal = create_mat("DeskLegs", (0.92, 0.92, 0.92), roughness=0.2)
    mat_lamp = create_mat("LampGreen", (0.15, 0.72, 0.65), roughness=0.3)
    mat_book = create_mat("BookCover", (0.88, 0.32, 0.45), roughness=0.4)

    # Desktop
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.9))
    top = bpy.context.active_object
    top.scale = (2.2, 1.1, 0.08)
    top.data.materials.append(mat_desk)

    # Drawers on right
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.7, 0, 0.5))
    drawers = bpy.context.active_object
    drawers.scale = (0.6, 1.0, 0.75)
    drawers.data.materials.append(mat_desk)

    # Left legs
    for y in [-0.4, 0.4]:
        bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.88, location=(-0.95, y, 0.44))
        leg = bpy.context.active_object
        leg.data.materials.append(mat_metal)

    # Desk Lamp on left
    bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.04, location=(-0.7, 0.2, 0.96))
    lamp_base = bpy.context.active_object
    lamp_base.data.materials.append(mat_lamp)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.02, depth=0.4, location=(-0.7, 0.2, 1.18))
    lamp_pole = bpy.context.active_object
    lamp_pole.data.materials.append(mat_metal)
    bpy.ops.mesh.primitive_cone_add(radius1=0.15, radius2=0.05, depth=0.18, location=(-0.65, 0.15, 1.38))
    lamp_shade = bpy.context.active_object
    lamp_shade.rotation_euler = (math.radians(30), math.radians(-30), 0)
    lamp_shade.data.materials.append(mat_lamp)

    # Open Notebook on desk
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.05, 0.96))
    book = bpy.context.active_object
    book.scale = (0.65, 0.45, 0.03)
    book.data.materials.append(mat_book)

    out_file = os.path.join(BEDROOM_DIR, "prop_study_desk.png")
    bpy.context.scene.render.filepath = out_file
    bpy.ops.render.render(write_still=True)
    print("Rendered:", out_file)

# --- 4. Bedroom Twin Bed ---
def render_twin_bed():
    reset_scene()
    setup_camera((0, -8, 2.5), (0, 0, 0.7), ortho_scale=4.2, res_x=500, res_y=350)

    mat_frame = create_mat("BedFrame", (0.92, 0.78, 0.65), roughness=0.35)
    mat_blanket = create_mat("Blanket", (0.95, 0.68, 0.78), roughness=0.6) # cute pastel pink
    mat_pillow = create_mat("Pillow", (0.98, 0.98, 0.95), roughness=0.5)

    # Mattress / blanket
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.55))
    mattress = bpy.context.active_object
    mattress.scale = (1.6, 2.6, 0.4)
    mattress.data.materials.append(mat_blanket)

    # Wooden headboard
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 1.35, 0.95))
    head = bpy.context.active_object
    head.scale = (1.7, 0.12, 1.1)
    head.data.materials.append(mat_frame)

    # Pillow
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.85, 0.82))
    pil = bpy.context.active_object
    pil.scale = (0.9, 0.5, 0.16)
    pil.data.materials.append(mat_pillow)

    out_file = os.path.join(BEDROOM_DIR, "prop_twin_bed.png")
    bpy.context.scene.render.filepath = out_file
    bpy.ops.render.render(write_still=True)
    print("Rendered:", out_file)

# Execute renders
print("Starting Blender 3D Prop generation...")
render_songthaew_bench()
render_songthaew_rail()
render_study_desk()
render_twin_bed()
print("All 3D Props rendered successfully!")
