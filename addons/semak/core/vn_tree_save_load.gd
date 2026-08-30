@tool
extends Node

@export var graph_edit: GraphEdit

# Match your exact folder path:
const DIALOGUE_NODE_SCENE = preload("res://addons/semak/nodes/DialogueNode.tscn")
const DND_CHECK_SCENE = preload("res://addons/semak/nodes/DnDCheckNode.tscn")
const START_NODE_SCENE = preload("res://addons/semak/nodes/StartNode.tscn")
const CHOICE_NODE_SCENE = preload("res://addons/semak/nodes/ChoiceNode.tscn")

func _ready() -> void:
	pass

# Clear -- Helper function to wipe the board clean before loading or starting over
func clear_workspace() -> void:
	if not graph_edit: return
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()

func save_tree() -> void:
	if not graph_edit: return
	var story_tree = VNStoryTree.new()
	var compiled_nodes: Dictionary = {}
	
	for child in graph_edit.get_children():
		if child.has_method("get_node_data"):
			compiled_nodes[child.name] = child.get_node_data()
		elif child.is_class("GraphFrame") or (child is GraphNode and child.title == "Comment Box"):
			compiled_nodes[child.name] = {
				"type": "comment",
				"node_name": child.name,
				"position": [child.position_offset.x, child.position_offset.y],
				"size": [child.size.x, child.size.y],
				"title": child.title,
				"color": [child.get_tint_color().r, child.get_tint_color().g, child.get_tint_color().b, child.get_tint_color().a] if child.has_method("get_tint_color") else [0,0,0,0]
			}
			
	for conn in graph_edit.get_connection_list():
		var from_name = str(conn.from_node)
		var to_name = str(conn.to_node)
		
		if compiled_nodes.has(from_name):
			var node_data = compiled_nodes[from_name]
			if node_data["type"] == "choice_branch":
				# Resize choice tracking array boundaries dynamically to match port indices
				if node_data["next_nodes"].size() <= conn.from_port:
					node_data["next_nodes"].resize(conn.from_port + 1)
				node_data["next_nodes"][conn.from_port] = to_name
			
			if node_data["type"] == "dnd_check":
				if conn.from_port == 0:
					node_data["next_pass"] = to_name
				elif conn.from_port == 1:
					node_data["next_fail"] = to_name
			
			elif node_data["type"] == "dialogue":
				node_data["next_node"] = to_name
			
			elif node_data["type"] == "command":
				node_data["next_node"] = to_name
				
			elif node_data["type"] == "condition":
				if conn.from_port == 0:
					node_data["next_true"] = to_name
				elif conn.from_port == 1:
					node_data["next_false"] = to_name
			
			elif node_data["type"] == "actor":
				node_data["next_node"] = to_name
			
			elif node_data["type"] == "start":
				node_data["next_node"] = to_name

	story_tree.graph_data = compiled_nodes
	
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.add_filter("*.tres", "Godot Narrative Resource Files")
	file_dialog.current_path = "res://"
	
	file_dialog.file_selected.connect(func(path: String):
		var error = ResourceSaver.save(story_tree, path)
		if error == OK:
			print("VN Tree: Narrative plot saved successfully to: ", path)
		else:
			print("VN Tree Error: Failed to save script file. Error Code: ", error)
		file_dialog.queue_free()
	)
	
	EditorInterface.get_base_control().add_child(file_dialog)
	file_dialog.popup_file_dialog()

func load_tree() -> void:
	if not graph_edit: return
	var file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.tres", "Godot Narrative Resource Files")
	file_dialog.current_path = "res://"
	
	file_dialog.file_selected.connect(func(path: String):
		var story_tree = ResourceLoader.load(path, "VNStoryTree", ResourceLoader.CACHE_MODE_REPLACE)
		if not story_tree or not story_tree is VNStoryTree:
			print("VN Tree Error: Invalid file format.")
			file_dialog.queue_free()
			return
			
		clear_workspace()
		
		# Await process_frame safely by getting the tree from the scene tree
		await EditorInterface.get_base_control().get_tree().process_frame
		
		var graph_data = story_tree.graph_data
		
		# Load node scenes on demand to avoid cyclic load
		var COMMAND_NODE_SCENE = load("res://addons/semak/nodes/CommandNode.tscn")
		var CONDITION_NODE_SCENE = load("res://addons/semak/nodes/ConditionNode.tscn")
		var ACTOR_NODE_SCENE = load("res://addons/semak/nodes/ActorNode.tscn")
		
		# Step 1: Reconstruct nodes
		var name_map = {}
		for node_name in graph_data.keys():
			var data = graph_data[node_name]
			var node_instance: Control
			
			if data["type"] == "dialogue":
				node_instance = DIALOGUE_NODE_SCENE.instantiate()
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				node_instance.set_node_data(data)
			
			elif data["type"] == "choice_branch":
				node_instance = CHOICE_NODE_SCENE.instantiate()
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				node_instance.set_node_data(data)

			elif data["type"] == "dnd_check":
				node_instance = DND_CHECK_SCENE.instantiate()
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				node_instance.set_node_data(data)
				
			elif data["type"] == "command":
				node_instance = COMMAND_NODE_SCENE.instantiate()
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				node_instance.set_node_data(data)
				
			elif data["type"] == "condition":
				node_instance = CONDITION_NODE_SCENE.instantiate()
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				node_instance.set_node_data(data)
				
			elif data["type"] == "actor":
				node_instance = ACTOR_NODE_SCENE.instantiate()
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				node_instance.set_node_data(data)
				
			elif data["type"] == "start":
				node_instance = START_NODE_SCENE.instantiate()
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				
			elif data["type"] == "comment":
				if ClassDB.class_exists("GraphFrame"):
					node_instance = ClassDB.instantiate("GraphFrame")
				else:
					node_instance = GraphNode.new()
					node_instance.resizable = true
				
				if node_instance.has_method("set_autoshrink_enabled"):
					node_instance.set_autoshrink_enabled(false)
				
				graph_edit.add_child(node_instance)
				node_instance.name = node_name.replace("@", "_")
				name_map[node_name] = node_instance.name
				node_instance.title = data.get("title", "Comment Box")
				if data.has("size"):
					node_instance.size = Vector2(data["size"][0], data["size"][1])
				
				if node_instance.has_method("set_tint_color_enabled"):
					node_instance.set_tint_color_enabled(true)
					if data.has("color"):
						node_instance.set_tint_color(Color(data["color"][0], data["color"][1], data["color"][2], data["color"][3]))
					else:
						node_instance.set_tint_color(Color(0.2, 0.2, 0.2, 0.5))
				
				if node_instance.has_signal("resize_request"):
					node_instance.resize_request.connect(func(new_size: Vector2):
						node_instance.size = new_size
					)
				
			if node_instance:
				if node_instance is GraphNode or node_instance.is_class("GraphFrame"):
					node_instance.position_offset = Vector2(data["position"][0], data["position"][1])
				if node_instance.has_signal("delete_request"):
					node_instance.delete_request.connect(func(): node_instance.queue_free())
				
		# Step 2: Relink connections
		for node_name in graph_data.keys():
			var data = graph_data[node_name]
			var actual_from = name_map.get(node_name, node_name)
			
			if data["type"] == "dialogue" and data.get("next_node", "") != "":
				var actual_to = name_map.get(data["next_node"], data["next_node"])
				graph_edit.connect_node(actual_from, 0, actual_to, 0)
			elif data["type"] == "start" and data.get("next_node", "") != "":
				var actual_to = name_map.get(data["next_node"], data["next_node"])
				graph_edit.connect_node(actual_from, 0, actual_to, 0)
			elif data["type"] == "command" and data.get("next_node", "") != "":
				var actual_to = name_map.get(data["next_node"], data["next_node"])
				graph_edit.connect_node(actual_from, 0, actual_to, 0)
			elif data["type"] == "actor" and data.get("next_node", "") != "":
				var actual_to = name_map.get(data["next_node"], data["next_node"])
				graph_edit.connect_node(actual_from, 0, actual_to, 0)
			elif data["type"] == "choice_branch":
				for port_idx in range(data["next_nodes"].size()):
					var target_path_node = data["next_nodes"][port_idx]
					if target_path_node != "":
						var actual_to = name_map.get(target_path_node, target_path_node)
						graph_edit.connect_node(actual_from, port_idx, actual_to, 0)
			elif data["type"] == "dnd_check":
				if data.get("next_pass", "") != "":
					var actual_to = name_map.get(data["next_pass"], data["next_pass"])
					graph_edit.connect_node(actual_from, 0, actual_to, 0)
				if data.get("next_fail", "") != "":
					var actual_to = name_map.get(data["next_fail"], data["next_fail"])
					graph_edit.connect_node(actual_from, 1, actual_to, 0)
			elif data["type"] == "condition":
				if data.get("next_true", "") != "":
					var actual_to = name_map.get(data["next_true"], data["next_true"])
					graph_edit.connect_node(actual_from, 0, actual_to, 0)
				if data.get("next_false", "") != "":
					var actual_to = name_map.get(data["next_false"], data["next_false"])
					graph_edit.connect_node(actual_from, 1, actual_to, 0)
					
		print("VN Tree: Data asset loaded successfully!")
		file_dialog.queue_free()
	)
	
	EditorInterface.get_base_control().add_child(file_dialog)
	file_dialog.popup_file_dialog()
