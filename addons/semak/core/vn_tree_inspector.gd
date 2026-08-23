@tool
extends VBoxContainer

var currently_inspected_node: Node = null

func build_inspector(node: Node) -> void:
	clear_inspector()
	currently_inspected_node = node
	
	if not node.has_method("get_node_data"):
		# Could be a comment frame or unsupported node
		if node.is_class("GraphFrame") or (node is GraphNode and node.title == "Comment Box"):
			VNTreeInspectorBuilders.build_comment_inspector(self, node)
		else:
			var lbl = Label.new()
			lbl.text = "No custom data to inspect."
			add_child(lbl)
		return
		
	var data = node.get_node_data()
	if data["type"] == "dialogue":
		VNTreeInspectorBuilders.build_dialogue_inspector(self, node)
	elif data["type"] == "dnd_check":
		VNTreeInspectorBuilders.build_dnd_inspector(self, node)
	elif data["type"] == "choice_branch":
		VNTreeInspectorBuilders.build_choice_inspector(self, node)
	elif data["type"] == "command":
		VNTreeInspectorBuilders.build_command_inspector(self, node)
	elif data["type"] == "condition":
		VNTreeInspectorBuilders.build_condition_inspector(self, node)
	elif data["type"] == "actor":
		VNTreeInspectorBuilders.build_actor_inspector(self, node)

func clear_inspector() -> void:
	currently_inspected_node = null
	for child in get_children():
		child.queue_free()
	var lbl = Label.new()
	lbl.text = "Select a node to edit..."
	add_child(lbl)
