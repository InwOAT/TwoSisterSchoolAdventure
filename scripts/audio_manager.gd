extends Node

## AudioManager Autoload - Manages dynamic BGM and SFX across all levels and quests
var bgm_player_1: AudioStreamPlayer
var bgm_player_2: AudioStreamPlayer
var active_bgm_player: int = 1

var sfx_pool: Array[AudioStreamPlayer] = []
var pool_size: int = 8
var current_sfx_idx: int = 0

var current_bgm_track: String = ""
var bgm_volume_db: float = -3.0
var sfx_volume_db: float = 0.0
var is_muted: bool = false

# Preloaded Sound Effects
var sfx_streams: Dictionary = {}

# Preloaded Background Musics & Scene Ambiences
var bgm_streams: Dictionary = {}

func _init_audio_streams() -> void:
	sfx_streams = {
		"jump": load("res://assets/audio/sfx/sfx_jump.wav"),
		"land": load("res://assets/audio/sfx/sfx_land.wav"),
		"star": load("res://assets/audio/sfx/sfx_star.wav"),
		"merit": load("res://assets/audio/sfx/sfx_merit.wav"),
		"pickup": load("res://assets/audio/sfx/sfx_pickup.wav"),
		"portal": load("res://assets/audio/sfx/sfx_portal.wav"),
		"push": load("res://assets/audio/sfx/sfx_push.wav"),
		"correct": load("res://assets/audio/sfx/sfx_correct.wav"),
		"wrong": load("res://assets/audio/sfx/sfx_wrong.wav"),
		"bus_bell": load("res://assets/audio/sfx/sfx_bus_bell.wav"),
		"coin": load("res://assets/audio/sfx/sfx_coin.wav"),
		"recycle": load("res://assets/audio/sfx/sfx_recycle.wav"),
		"bloom": load("res://assets/audio/sfx/sfx_bloom.wav"),
		"umbrella": load("res://assets/audio/sfx/sfx_umbrella.wav"),
		"switch": load("res://assets/audio/sfx/sfx_switch.wav"),
		"dialog_blip": load("res://assets/audio/sfx/sfx_dialog_blip.wav"),
		"victory": load("res://assets/audio/sfx/sfx_victory.wav"),
		"game_start": load("res://assets/audio/sfx/sfx_game_start.wav"),
		"ui_click": load("res://assets/audio/sfx/sfx_ui_click.wav"),
		"ui_hover": load("res://assets/audio/sfx/sfx_ui_hover.wav"),
		"sister_cheer": load("res://assets/audio/sfx/sfx_sister_cheer.wav")
	}

	bgm_streams = {
		0: load("res://assets/audio/bgm/bgm_title_theme.wav"), # Title / Main Menu Theme
		1: load("res://assets/audio/bgm/bgm_home_morning.wav"),
		2: load("res://assets/audio/bgm/bgm_village_lively.wav"),
		25: load("res://assets/audio/bgm/bgm_bus_stop.wav"), # Bus stop pavilion
		3: load("res://assets/audio/bgm/bgm_bus_ride.wav"),
		4: load("res://assets/audio/bgm/bgm_terminal_bustle.wav"),
		5: load("res://assets/audio/bgm/bgm_school_morning.wav"),
		6: load("res://assets/audio/bgm/bgm_classroom.wav"),
		7: load("res://assets/audio/bgm/bgm_canteen.wav"),
		8: load("res://assets/audio/bgm/bgm_school_garden.wav"),
		9: load("res://assets/audio/bgm/bgm_songthaew_ride.wav"),
		95: load("res://assets/audio/bgm/bgm_bus_stop.wav"), # Bus stop return transfer
		10: load("res://assets/audio/bgm/bgm_bus_sunset.wav"),
		11: load("res://assets/audio/bgm/bgm_rainy_village.wav"),
		12: load("res://assets/audio/bgm/bgm_home_night.wav")
	}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_audio_streams()
	
	# Create dual BGM players for smooth crossfades
	bgm_player_1 = AudioStreamPlayer.new()
	bgm_player_1.bus = "Master"
	bgm_player_1.volume_db = bgm_volume_db
	add_child(bgm_player_1)
	
	bgm_player_2 = AudioStreamPlayer.new()
	bgm_player_2.bus = "Master"
	bgm_player_2.volume_db = -80.0
	add_child(bgm_player_2)
	
	# Create SFX pool
	for i in range(pool_size):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		p.volume_db = sfx_volume_db
		add_child(p)
		sfx_pool.append(p)
		
	# Connect to GameManager signals
	_connect_game_manager_signals()

func _connect_game_manager_signals() -> void:
	if not GameManager:
		return
		
	GameManager.stars_changed.connect(func(): play_sfx("star"))
	GameManager.good_deed_updated.connect(func(_id, _pts, _tot, _title): play_sfx("merit"))
	GameManager.dialog_triggered.connect(func(_spk, _txt, _port): play_sfx("dialog_blip", 1.0, -8.0))

func play_sfx(sfx_name: String, pitch_scale: float = 1.0, volume_offset: float = 0.0) -> void:
	if is_muted:
		return
	if not sfx_streams.has(sfx_name):
		push_warning("SFX not found: " + sfx_name)
		return
		
	var stream: AudioStream = sfx_streams[sfx_name]
	var player: AudioStreamPlayer = sfx_pool[current_sfx_idx]
	current_sfx_idx = (current_sfx_idx + 1) % pool_size
	
	player.stream = stream
	player.pitch_scale = pitch_scale
	player.volume_db = sfx_volume_db + volume_offset
	player.play()

func play_title_bgm() -> void:
	play_level_bgm(0)

func play_level_bgm(level_number: int) -> void:
	if not bgm_streams.has(level_number):
		return
		
	var stream: AudioStream = bgm_streams[level_number]
	var track_key: String = str(level_number)
	
	if current_bgm_track == track_key and (bgm_player_1.playing or bgm_player_2.playing):
		return # Already playing this track
		
	current_bgm_track = track_key
	_crossfade_to_stream(stream)

func _crossfade_to_stream(new_stream: AudioStream) -> void:
	if is_muted:
		return
		
	# Crossfade between player 1 and player 2
	var current_player := bgm_player_1 if active_bgm_player == 1 else bgm_player_2
	var next_player := bgm_player_2 if active_bgm_player == 1 else bgm_player_1
	active_bgm_player = 2 if active_bgm_player == 1 else 1
	
	next_player.stream = new_stream
	# Enable loop on stream if it's AudioStreamWAV
	if new_stream is AudioStreamWAV:
		var wav := new_stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		var bytes_per_sample: int = 4 if wav.stereo else 2
		wav.loop_end = int(wav.data.size() / bytes_per_sample)
		
	next_player.volume_db = -80.0
	next_player.play()
	
	# Tween crossfade
	var tween := create_tween().set_parallel(true)
	tween.tween_property(next_player, "volume_db", bgm_volume_db, 1.2)
	tween.tween_property(current_player, "volume_db", -80.0, 1.2)
	tween.chain().tween_callback(func(): current_player.stop())

func set_bgm_volume(val_db: float) -> void:
	bgm_volume_db = val_db
	if active_bgm_player == 1:
		bgm_player_1.volume_db = bgm_volume_db
	else:
		bgm_player_2.volume_db = bgm_volume_db

func set_sfx_volume(val_db: float) -> void:
	sfx_volume_db = val_db
	for p in sfx_pool:
		p.volume_db = sfx_volume_db

func toggle_mute() -> bool:
	is_muted = not is_muted
	if is_muted:
		bgm_player_1.stop()
		bgm_player_2.stop()
		for p in sfx_pool:
			p.stop()
	else:
		if current_bgm_track != "":
			play_level_bgm(int(current_bgm_track))
	return is_muted
