# DialogueNode.gd
@tool
extends GraphNode

@onready var preview_label: Label = $VBox/PreviewLabel

var speaker_text: String = "e.g. Elyssa"
var dialogue_text: String = "Enter line narrative..."
var flags_text: String = ""

func _ready() -> void:
	title = "Dialogue Text"
	
	# Slot 0
	set_slot_enabled_left(0, true)
	set_slot_type_left(0, 0)
	set_slot_color_left(0, Color.WHITE)
	
	set_slot_enabled_right(0, true)
	set_slot_type_right(0, 0)
	set_slot_color_right(0, Color.WHITE)
	
	update_preview()
	size = Vector2.ZERO

func get_node_data() -> Dictionary:
	return {
		"type": "dialogue",
		"node_name": name,
		"position": [position_offset.x, position_offset.y],
		"speaker": speaker_text,
		"text": dialogue_text,
		"set_flags": flags_text,
		"next_node": "" 
	}

func set_node_data(data: Dictionary) -> void:
	speaker_text = data.get("speaker", speaker_text)
	dialogue_text = data.get("text", dialogue_text)
	flags_text = data.get("set_flags", flags_text)
	if data.has("position"):
		position_offset = Vector2(data["position"][0], data["position"][1])
	update_preview()

func update_preview() -> void:
	if not is_inside_tree() or not preview_label: return
	
	var preview = ""
	if speaker_text != "":
		preview += speaker_text + ":\n"
	if dialogue_text != "":
		if dialogue_text.length() > 40:
			preview += dialogue_text.substr(0, 40) + "..."
		else:
			preview += dialogue_text
			
	if preview == "":
		preview = "[Empty Dialogue]"
		
	if flags_text != "":
		preview += "\n[Flags: " + flags_text + "]"
		
	preview_label.text = preview
	size = Vector2.ZERO
