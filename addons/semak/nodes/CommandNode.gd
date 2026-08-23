@tool
extends GraphNode

var command_text: String = ""

func update_preview():
	$PreviewLabel.text = command_text if command_text != "" else "[Empty Command]"

func get_node_data() -> Dictionary:
	return {
		"type": "command",
		"position": [position_offset.x, position_offset.y],
		"command": command_text,
		"next_node": ""
	}

func set_node_data(data: Dictionary) -> void:
	command_text = data.get("command", "")
	update_preview()
