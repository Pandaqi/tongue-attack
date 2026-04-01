class_name AudioManager extends Node

var bg_streams : Array[AudioStream] = []
var bg_audio : AudioStreamPlayer
var ui_audio : AudioStreamPlayer
var ui_audio_stream : AudioStreamPlaybackPolyphonic

static func get_pitch_shift_semitones():
	var multiplier := 1.06
	var power := randi_range(-3, 3)
	var value := pow(multiplier, power)
	return value if randf() >= 0.5 else 1.0/value

static func pitch_shift(node) -> void:
	node.pitch_scale = get_pitch_shift_semitones()

static func play_audio_nice(node) -> void:
	pitch_shift(node)
	if node.bus == "Master": node.bus = "Game"
	node.play()

func _enter_tree() -> void:
	ensure_buses_exist()
	create_ui_audio()
	get_tree().node_added.connect(_on_node_added)

func _ready() -> void:
	create_bg_music()

func ensure_buses_exist():
	var buses := ["Background", "UI", "Game"]
	for bus_name in buses:
		var bus_exists := AudioServer.get_bus_index(bus_name) != -1
		if bus_exists: continue
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count-1, bus_name)

static func fade_in(ap:AudioStreamPlayer, dur := 1.0) -> Tween:
	ap.volume_db = linear_to_db(0.0001)
	var tw := ap.get_tree().create_tween()
	tw.tween_property(ap, "volume_db", linear_to_db(1.0), dur)
	return tw

static func fade_out(ap:AudioStreamPlayer, dur := 1.0) -> Tween:
	ap.volume_db = linear_to_db(1.0)
	var tw := ap.get_tree().create_tween()
	tw.tween_property(ap, "volume_db", linear_to_db(0.0001), dur)
	return tw

func create_ui_audio() -> void:
	ui_audio = AudioStreamPlayer.new()
	ui_audio.bus = "UI"
	add_child(ui_audio)
	fade_in(ui_audio)

	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	ui_audio.stream = stream
	ui_audio.play()
	ui_audio_stream = ui_audio.get_stream_playback()

func _on_node_added(node:Node) -> void:
	var is_button := (node is Button)
	var is_slider := (node is Slider)
	var needs_ui_sound := is_button or is_slider 
	if needs_ui_sound:
		node.mouse_entered.connect(func(): _on_ui_change(node))
	
	if is_button:
		node.pressed.connect(func(): _on_ui_change(node))
	
	if is_slider:
		node.value_changed.connect(func(_v:float): _on_ui_change(node))

func _on_ui_change(_node:Node) -> void:
	var audio = Global.config_system.audio_ui
	if not audio: return
	ui_audio_stream.play_stream(audio, 0, 0, get_pitch_shift_semitones())

func play_player_change_sound() -> void:
	var audio = Global.config_system.audio_player_change
	if not audio: return
	ui_audio_stream.play_stream(audio, 0, 0, get_pitch_shift_semitones())

func get_index_of_bus(key:String) -> int:
	return AudioServer.get_bus_index(key)

func change_volume_of_bus(key:String, vol:int) -> void:
	AudioServer.set_bus_volume_db(get_index_of_bus(key), vol)

func create_bg_music() -> void:
	if not Global.config_system.audio_bg: return
	
	bg_streams = Global.config_system.audio_bg
	var node = AudioStreamPlayer.new()
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	node.bus = "Background"
	node.finished.connect(_on_bg_music_finished)
	
	bg_audio = node
	add_child(node)
	fade_in(bg_audio)
	
	pick_next_bg_music()

func _on_bg_music_finished() -> void:
	pick_next_bg_music()

func pick_next_bg_music() -> void:
	if bg_streams.size() <= 0: return
	bg_audio.stream = bg_streams.pick_random()
	bg_audio.play()

func set_bg_paused(val:bool) -> void:
	if val: bg_audio.stop()
	else: bg_audio.play()
