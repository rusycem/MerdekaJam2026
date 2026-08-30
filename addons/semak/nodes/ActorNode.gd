@tool
extends GraphNode

var events: Array = []

func update_preview():
	var txt = ""
	for ev in events:
		var atype = ev.get("action_type", "")
		if atype == "show_character":
			txt += "Show " + ev.get("character", "Unknown") + "\n"
		elif atype == "hide_character":
			txt += "Hide " + ev.get("character", "Unknown") + "\n"
		elif atype == "change_bg":
			txt += "Set BG\n"
			
	if txt == "":
		txt = "[Empty Director Node]"
	$PreviewLabel.text = txt.strip_edges()

func get_node_data() -> Dictionary:
	return {
		"type": "actor",
		"position": [position_offset.x, position_offset.y],
		"events": events,
		"next_node": ""
	}

func set_node_data(data: Dictionary) -> void:
	if data.has("events"):
		events = data["events"].duplicate(true)
	else:
		# Fallback for old single-event format if any exists
		var single_event = {
			"action_type": data.get("action_type", "show_character"),
			"character": data.get("character", "Alyssa"),
			"expression": data.get("expression", "Neutral"),
			"position_slot": data.get("position_slot", "Center"),
			"offset_x": data.get("offset_x", 0.0),
			"offset_y": data.get("offset_y", 0.0),
			"z_index": data.get("z_index", 0),
			"flip_h": data.get("flip_h", false),
			"animation": data.get("animation", "None"),
			"anim_duration": data.get("anim_duration", 0.5),
			"background_id": data.get("background_id", "")
		}
		events = [single_event]
		
	update_preview()
