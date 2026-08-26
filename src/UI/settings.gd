extends PanelContainer

const ACTION_BUTTONS := {
	"next": "Options/NextChat/Button",
	"toggle_auto_next": "Options/AutoNext/Button",
	"toggle_ui": "Options/HideMenu/Button",
	"toggle_transcript": "Options/OpenTranscript/Button",
	"pause": "Options/PauseButton/Button",
}

var listening_action: String = ""

@onready var listening_container = $ListeningContainer
@onready var listening_label = $ListeningContainer/HBox/Label
@onready var listening_cancel_btn = $ListeningContainer/HBox/CancelBtn


func _ready() -> void:
	_refresh_keybind_labels()


func _process(_delta: float) -> void :
	if listening_action != "":
		return

	if (Input.is_action_just_pressed("pause")) :
		if (get_tree().paused) :
			get_tree().paused = false
			hide()

		else :
			get_tree().paused = true
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
		var btn := get_node_or_null(ACTION_BUTTONS[action]) as Button
		if btn:
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
