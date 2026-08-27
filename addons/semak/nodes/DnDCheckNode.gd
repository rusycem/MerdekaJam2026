# DnDCheckNode.gd
@tool
extends GraphNode

@onready var preview_label: Label = $VBoxContainer/PreviewLabel

var target_stat: String = "STR"
var dc_value: int = 10

func _ready() -> void:
	title = "D&D Skill Check"
	
	# Slot 0: Execution Input / Success Output
	set_slot_enabled_left(0, true)
	set_slot_type_left(0, 0)
	set_slot_color_left(0, Color.WHITE)
	set_slot_enabled_right(0, true)
	set_slot_type_right(0, 0)
	set_slot_color_right(0, Color.GREEN)
	
	# Slot 1: Failure Output
	set_slot_enabled_left(1, false)
	set_slot_type_left(1, 0)
	set_slot_color_left(1, Color.WHITE)
	set_slot_enabled_right(1, true)
	set_slot_type_right(1, 0)
	set_slot_color_right(1, Color.RED)
	
	update_preview()
	size = Vector2.ZERO

func get_node_data() -> Dictionary:
	return {
		"type": "dnd_check",
		"node_name": name,
		"position": [position_offset.x, position_offset.y],
		"target_stat": target_stat,
		"dc_value": dc_value,
		"next_pass": "", 
		"next_fail": ""  
	}

func set_node_data(data: Dictionary) -> void:
	target_stat = data.get("target_stat", target_stat)
	dc_value = data.get("dc_value", dc_value)
	if data.has("position"):
		position_offset = Vector2(data["position"][0], data["position"][1])
	update_preview()

func update_preview() -> void:
	if not is_inside_tree() or not preview_label: return
	preview_label.text = "[Roll " + target_stat + " DC " + str(dc_value) + "]"
	size = Vector2.ZERO
