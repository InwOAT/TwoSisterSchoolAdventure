import urllib.request
import json
import time
import os
import shutil

COMFY_URL = "http://127.0.0.1:8188"
OUTPUT_DIR = r"E:\ComfyUI_windows_portable\ComfyUI\output"
DEST_BG_DIR = r"D:\HOME3\Mobile\Games\TwoSisterSchoolAdventure\assets\backgrounds"

SCENES = [
    ("bg_scene_1_home", "warm cozy colorful anime storybook living room in morning, clean vector 2d side-scrolling platformer background, wooden floor, pastel sunlight through window, cute refrigerator, dining table, maple story style, bright pastel colors, masterpiece, clean illustration"),
    ("bg_scene_2_village", "charming sunny thai village alley street, cute grocery shop with colorful snack bags, traditional thai bus stop sign under shady tree, 2d side-scrolling platformer background, bright pastel colors, maple story style, storybook art, masterpiece"),
    ("bg_scene_3_bus", "inside a cheerful city bus interior, rows of cute seats, handrails, large windows showing moving sunny cityscape, 2d side-scrolling platformer background, clean pastel colors, maple story style, cartoon anime illustration, masterpiece"),
    ("bg_scene_4_terminal", "lively city bus terminal station, platform parking with colorful songthaew minibuses, big schedule board with signs, 2d side-scrolling platformer background, bright sunny day, maple story style, masterpiece"),
    ("bg_scene_5_school_gate", "beautiful bright school entrance gate, modern elementary school building, playground with fountain and flowers, guard booth near gate, 2d side-scrolling platformer background, sunny morning, maple story style, masterpiece"),
    ("bg_scene_6_classroom", "cute cozy elementary classroom interior, large green blackboard with cute chalk drawings, neat wooden student desks, bright windows, 2d side-scrolling platformer background, maple story style, vibrant colors, masterpiece"),
    ("bg_scene_7_canteen", "bright bustling school canteen cafeteria, food counters with lunch trays and fruits, clean tables, recycling trash bins, 2d side-scrolling platformer background, maple story style, cheerful anime illustration, masterpiece"),
    ("bg_scene_8_garden", "peaceful school backyard garden, blooming colorful flowerbeds, vegetable patches, wooden greenhouse shed, library wall in background, 2d side-scrolling platformer background, maple story style, masterpiece"),
    ("bg_scene_9_songthaew_return", "interior of a thai songthaew pickup bus, wooden passenger benches on both sides, open back view of afternoon city, 2d side-scrolling platformer background, warm afternoon light, maple story style, masterpiece"),
    ("bg_scene_10_bus_return", "inside a city transit bus in the golden sunset evening, cozy interior lights, orange glow outside windows, 2d side-scrolling platformer background, maple story style, heartwarming storybook art, masterpiece"),
    ("bg_scene_11_rainy_village", "cozy village street in the evening during gentle rain, street lamps with warm yellow glow, wet asphalt reflections, raindrops, twilight blue atmosphere, 2d side-scrolling platformer background, maple story style, masterpiece"),
    ("bg_scene_12_home_night", "warm cozy bedroom and living room at night, gentle warm bedside lamp glow, soft bed, study desk with open homework book, starry night outside window, 2d side-scrolling platformer background, maple story style, sweet peaceful bedtime, masterpiece")
]

def queue_prompt(prefix, prompt_text, seed):
    workflow = {
        '3': {
            'class_type': 'KSampler',
            'inputs': {
                'cfg': 7.0,
                'denoise': 1.0,
                'latent_image': ['5', 0],
                'model': ['4', 0],
                'negative': ['7', 0],
                'positive': ['6', 0],
                'sampler_name': 'euler',
                'scheduler': 'normal',
                'seed': seed,
                'steps': 20
            }
        },
        '4': {
            'class_type': 'CheckpointLoaderSimple',
            'inputs': {'ckpt_name': 'v1-5-pruned-emaonly.safetensors'}
        },
        '5': {
            'class_type': 'EmptyLatentImage',
            'inputs': {'batch_size': 1, 'height': 512, 'width': 768}
        },
        '6': {
            'class_type': 'CLIPTextEncode',
            'inputs': {
                'clip': ['4', 1],
                'text': prompt_text
            }
        },
        '7': {
            'class_type': 'CLIPTextEncode',
            'inputs': {
                'clip': ['4', 1],
                'text': 'dark, ugly, dirty, blurry, lowres, photo, realistic, text, watermark'
            }
        },
        '8': {
            'class_type': 'VAEDecode',
            'inputs': {'samples': ['3', 0], 'vae': ['4', 2]}
        },
        '9': {
            'class_type': 'SaveImage',
            'inputs': {'filename_prefix': prefix, 'images': ['8', 0]}
        }
    }
    data = json.dumps({'prompt': workflow}).encode('utf-8')
    req = urllib.request.Request(f"{COMFY_URL}/prompt", data=data, headers={'Content-Type': 'application/json'})
    res = urllib.request.urlopen(req)
    return json.loads(res.read())['prompt_id']

def wait_for_prompt(prompt_id):
    for _ in range(60):
        time.sleep(1)
        try:
            req = urllib.request.Request(f"{COMFY_URL}/history/{prompt_id}")
            res = urllib.request.urlopen(req)
            hist = json.loads(res.read())
            if prompt_id in hist:
                return hist[prompt_id]['outputs']['9']['images'][0]['filename']
        except Exception:
            pass
    return None

print(f"Starting generation for {len(SCENES)} scenes...")
for i, (prefix, text) in enumerate(SCENES):
    dest_file = os.path.join(DEST_BG_DIR, f"{prefix}.png")
    if os.path.exists(dest_file):
        print(f"[{i+1}/{len(SCENES)}] {prefix} already exists, skipping.")
        continue
    print(f"[{i+1}/{len(SCENES)}] Generating {prefix}...")
    pid = queue_prompt(prefix, text, seed=1000 + i * 37)
    fn = wait_for_prompt(pid)
    if fn:
        src = os.path.join(OUTPUT_DIR, fn)
        if os.path.exists(src):
            shutil.copy2(src, dest_file)
            print(f"Saved: {dest_file}")
    else:
        print(f"Timed out waiting for {prefix}")

print("All backgrounds generation process finished!")
