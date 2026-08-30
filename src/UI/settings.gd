extends PanelContainer

const ACTION_BUTTONS := {
	"next": "NextChatBtn",
	"toggle_auto_next": "AutoNextBtn",
	"toggle_ui": "HideMenuBtn",
	"toggle_transcript": "TranscriptBtn",
	"pause": "PauseBtn",
}

var listening_action: String = ""

@onready var listening_container: PanelContainer = %ListeningContainer
@onready var listening_label: Label = %ListeningLabel
@onready var listening_cancel_btn: Button = %CancelBtn
@onready var save_grid: GridContainer = %SaveGrid
@onready var status_lbl: RichTextLabel = %StatusLabel


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_FILL

	%FullscreenCheck.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

	var volume_sliders := {
		"Master": %MasterSlider,
		"BGM": %BGMSlider,
		"SFX": %SFXSlider,
		"Voice": %VoiceSlider,
	}
	for bus_name in volume_sliders:
		var bus_idx := AudioServer.get_bus_index(bus_name)
		if bus_idx == -1:
			continue
		var slider: HSlider = volume_sliders[bus_name]
		slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
		slider.value_changed.connect(_on_volume_changed.bind(bus_idx))

	for i in range(1, 10):
		var slot := "Slot_" + str(i)
		var slot_btn: Button = save_grid.get_node(slot)
		slot_btn.pressed.connect(_on_slot_pressed.bind(slot))

	_refresh_save_ui()
	_refresh_keybind_labels()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	if EventBus.has_signal("scene_change_requested"):
		var root_main = get_node_or_null("/root/Main")
		if root_main:
			EventBus.scene_change_requested.emit(root_main.starting_level, true)


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_changed(value: float, bus_idx: int) -> void:
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


func _on_slot_pressed(slot: String) -> void:
	if get_tree().current_scene and get_tree().current_scene.has_node("VNPlayer"):
		GameState.resume_node_id = get_tree().current_scene.get_node("VNPlayer").current_node_id
	SaveManager.save_game(slot)
	_refresh_save_ui()


func _refresh_save_ui() -> void:
	for i in range(1, 10):
		var slot := "Slot_" + str(i)
		var slot_btn: Button = save_grid.get_node(slot)
		var meta: Dictionary = SaveManager.get_save_metadata(slot)
		if meta.is_empty():
			slot_btn.text = "Save " + str(i) + "\n[Empty]"
		else:
			slot_btn.text = "Save " + str(i) + "\n" + meta["player_name"] + "\n" + meta["timestamp"]


func _refresh_status():
	if not status_lbl: return
	
	var txt = "[font_size=24][b]Player:[/b] " + GameState.player_name + " (" + GameState.player_class + ")[/font_size]\n"
	
	# Added as a new line
	txt += "[b]Gender:[/b] " + GameState.player_gender + "\n"
	
	txt += "[b]Money:[/b] $" + str(GameState.money) + "\n\n"
	txt += "[b]Stats:[/b]\n"
	for k in GameState.stats.keys():
		var mod = GameState.get_stat_modifier(k)
		txt += k + ": " + str(GameState.stats[k]) + " (+" + str(mod) + ")\n"
	status_lbl.text = txt


func _process(_delta: float) -> void :
	if listening_action != "":
		return

	if (Input.is_action_just_pressed("pause")) :
		if (get_tree().paused) :
			get_tree().paused = false
			hide()

		else :
			get_tree().paused = true
			_refresh_save_ui()
			_refresh_status()
			show()


func _input(event: InputEvent) -> void:
	if listening_action == "":
		return

	if event is InputEventKey and event.pressed and not event.echo:
		GameSettings.set_action_key(listening_action, event)
		_refresh_keybind_labels()
		_stop_listening()
		get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.pressed:
		if listening_cancel_btn.get_global_rect().has_point(event.global_position):
			return
		GameSettings.set_action_key(listening_action, event)
		_refresh_keybind_labels()
		_stop_listening()
		get_viewport().set_input_as_handled()


func _refresh_keybind_labels() -> void:
	for action in ACTION_BUTTONS:
		var btn: Button = get_node("%" + ACTION_BUTTONS[action])
		btn.text = GameSettings.get_action_text(action)


func _begin_listening(action: String) -> void:
	listening_action = action
	listening_label.text = "Listening: %s..." % action
	listening_container.visible = true


func _stop_listening() -> void:
	listening_action = ""
	listening_container.visible = false


func _on_next_chat_pressed() -> void:
	_begin_listening("next")


func _on_auto_next_pressed() -> void:
	_begin_listening("toggle_auto_next")


func _on_hide_menu_pressed() -> void:
	_begin_listening("toggle_ui")


func _on_open_transcript_pressed() -> void:
	_begin_listening("toggle_transcript")


func _on_pause_pressed() -> void:
	_begin_listening("pause")


func _on_slow_toggled(toggled_on: bool) -> void:
	if (toggled_on) :
		GameSettings.text_speed = GameSettings.TextSpeed.SLOW


func _on_medium_toggled(toggled_on: bool) -> void:
	if (toggled_on) :
		GameSettings.text_speed = GameSettings.TextSpeed.MEDIUM


func _on_fast_toggled(toggled_on: bool) -> void:
	if (toggled_on) :
		GameSettings.text_speed = GameSettings.TextSpeed.FAST
