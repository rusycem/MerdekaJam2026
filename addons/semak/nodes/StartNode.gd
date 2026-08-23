# StartNode.gd
@tool
extends GraphNode

func _ready() -> void:
	title = "START ENTRY"
	name = "Start" # Forces node name tracking ID integrity
	
	# Start node has NO inputs (Left), only ONE output link route (Right)
	set_slot_enabled_right(0, true)
	set_slot_type_right(0, 0)
	set_slot_color_right(0, Color.CYAN)
	
	var label = Label.new()
	label.text = "➔ Story Chapter Begins Here"
	add_child(label)

func get_node_data() -> Dictionary:
	return {
		"type": "start",
		"node_name": name,
		"position": [position_offset.x, position_offset.y],
		"next_node": "" # Connected at compile sequence validation runs
	}
