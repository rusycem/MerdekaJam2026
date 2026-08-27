extends Node

var bgm_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "BGM"
	add_child(bgm_player)
	
	ui_player = AudioStreamPlayer.new()
	ui_player.bus = "SFX"
	# Generate a soft UI click sound
	var click = AudioStreamWAV.new()
	click.format = AudioStreamWAV.FORMAT_16_BITS
	click.mix_rate = 44100
	click.stereo = false
	var click_data = PackedByteArray()
	for i in range(44100 * 0.03):
		var t = i / 44100.0
		var sample = int(sin(t * 2.0 * PI * 1200.0) * 12000.0 * exp(-t * 50.0))
		click_data.append(sample & 0xFF)
		click_data.append((sample >> 8) & 0xFF)
	click.data = click_data
	ui_player.stream = click
	add_child(ui_player)
	
	# Modular Hook: Connect to node_added to hook every button dynamically
	get_tree().node_added.connect(_on_node_added)
	_hook_existing_buttons(get_tree().root)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		if not node.pressed.is_connected(play_ui_click):
			node.pressed.connect(play_ui_click)

func _hook_existing_buttons(node: Node) -> void:
	if node is BaseButton:
		if not node.pressed.is_connected(play_ui_click):
			node.pressed.connect(play_ui_click)
	for child in node.get_children():
		_hook_existing_buttons(child)

func play_ui_click() -> void:
	ui_player.pitch_scale = randf_range(0.95, 1.05)
	ui_player.play()

func play_bgm(uid: String) -> void:
	if uid == "":
		stop_bgm()
		return
		
	var stream = ResourceLoader.load(uid)
	if stream is AudioStream:
		if bgm_player.stream == stream and bgm_player.playing:
			return # Already playing
		bgm_player.stream = stream
		bgm_player.play()
	else:
		print("AudioManager: Failed to load BGM uid: ", uid)

func stop_bgm() -> void:
	bgm_player.stop()
	bgm_player.stream = null
