@tool
extends GraphNode

var condition_text: String = ""

func update_preview():
	$PreviewLabel.text = "If: " + condition_text if condition_text != "" else "[Empty Condition]"

func get_node_data() -> Dictionary:
	return {
		"type": "condition",
		"position": [position_offset.x, position_offset.y],
		"condition": condition_text,
		"next_true": "",
		"next_false": ""
	}

func set_node_data(data: Dictionary) -> void:
	condition_text = data.get("condition", "")
	update_preview()
