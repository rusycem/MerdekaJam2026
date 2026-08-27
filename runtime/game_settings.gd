extends Node

signal text_speed_changed

enum TextSpeed {
	SLOW,
	MEDIUM,
	FAST
}

const REBINDABLE_ACTIONS := ["next", "toggle_auto_next", "toggle_ui", "toggle_transcript", "pause"]
const KEYBIND_PATH := "user://keybinds.cfg"

var text_speed := TextSpeed.MEDIUM :
	set(value) :
		text_speed = value
		text_speed_changed.emit()


var auto_next_enabled := false


func _ready() -> void :
	load_keybinds()


func get_text_speed_delay() -> float :
	match text_speed :
		TextSpeed.SLOW:   return 0.05
		TextSpeed.MEDIUM: return 0.03
		TextSpeed.FAST:   return 0.01
		_: return 0


func get_action_text(action: String) -> String :
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "None"
	return events[0].as_text()


func set_action_key(action: String, event: InputEvent) -> void :
	var ev: InputEvent
	if event is InputEventKey:
		var k := InputEventKey.new()
		k.keycode = event.keycode
		k.physical_keycode = event.physical_keycode
		ev = k
	elif event is InputEventMouseButton:
		var m := InputEventMouseButton.new()
		m.button_index = event.button_index
		ev = m
	else:
		return

	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, ev)
	save_keybinds()


func save_keybinds() -> void :
	var cf := ConfigFile.new()
	for action in REBINDABLE_ACTIONS:
		var events := InputMap.action_get_events(action)
		if events.is_empty():
			continue
		var ev := events[0]
		if ev is InputEventKey:
			cf.set_value("keybinds", action, {"type": "key", "keycode": ev.keycode, "physical": ev.physical_keycode})
		elif ev is InputEventMouseButton:
			cf.set_value("keybinds", action, {"type": "mouse", "button": ev.button_index})
	cf.save(KEYBIND_PATH)


func load_keybinds() -> void :
	var cf := ConfigFile.new()
	if cf.load(KEYBIND_PATH) != OK:
		return

	for action in REBINDABLE_ACTIONS:
		if not cf.has_section_key("keybinds", action):
			continue
		var data: Dictionary = cf.get_value("keybinds", action)
		var ev: InputEvent
		if data.get("type", "") == "mouse":
			var m := InputEventMouseButton.new()
			m.button_index = data.get("button", 1)
			ev = m
		else:
			var k := InputEventKey.new()
			k.keycode = data.get("keycode", 0)
			k.physical_keycode = data.get("physical", 0)
			ev = k
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, ev)
