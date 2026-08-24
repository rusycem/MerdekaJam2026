extends Node

var bgm_player: AudioStreamPlayer

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	add_child(bgm_player)

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
