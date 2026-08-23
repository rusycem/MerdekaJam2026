@tool
extends VBoxContainer

@export var graph_edit: GraphEdit
@onready var flag_list: ItemList = $FlagList

var _flag_node_map: Array[String] = []

func _on_scan_flags_pressed() -> void:
	if not graph_edit: return
	flag_list.clear()
	_flag_node_map.clear()
	
	for child in graph_edit.get_children():
		if child.has_method("get_node_data"):
			var data = child.get_node_data()
			
			if data["type"] == "dialogue" and data.has("set_flags"):
				var flags_raw = data["set_flags"]
				if not flags_raw.is_empty():
					var split_flags = flags_raw.split(",")
					for f in split_flags:
						var f_clean = f.strip_edges()
						if not f_clean.is_empty():
							flag_list.add_item("[SET] " + f_clean + " (" + child.name + ")")
							_flag_node_map.append(child.name)
							
			elif data["type"] == "choice_branch":
				for choice in data.get("choices", []):
					if typeof(choice) == TYPE_DICTIONARY:
						var condition = choice.get("condition", "")
						if not condition.is_empty():
							flag_list.add_item("[REQ] " + condition + " (" + child.name + ")")
							_flag_node_map.append(child.name)

func _on_flag_list_item_activated(index: int) -> void:
	if not graph_edit: return
	if index < 0 or index >= _flag_node_map.size():
		return
	var target_node_name = _flag_node_map[index]
	var target_node = graph_edit.get_node_or_null(NodePath(target_node_name))
	if target_node is GraphNode:
		var view_size = graph_edit.size
		graph_edit.scroll_offset = target_node.position_offset - (view_size / 2.0) + (target_node.size / 2.0)
		
		for child in graph_edit.get_children():
			if child is GraphNode:
				child.selected = false
		target_node.selected = true
