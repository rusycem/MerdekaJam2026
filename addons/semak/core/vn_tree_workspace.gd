@tool
extends Control

# Match your exact folder path:
const DIALOGUE_NODE_SCENE = preload("res://addons/semak/nodes/DialogueNode.tscn")
const DND_CHECK_SCENE = preload("res://addons/semak/nodes/DnDCheckNode.tscn")
const START_NODE_SCENE = preload("res://addons/semak/nodes/StartNode.tscn")
const CHOICE_NODE_SCENE = preload("res://addons/semak/nodes/ChoiceNode.tscn")
const COMMAND_NODE_SCENE = preload("res://addons/semak/nodes/CommandNode.tscn")
const CONDITION_NODE_SCENE = preload("res://addons/semak/nodes/ConditionNode.tscn")
const ACTOR_NODE_SCENE = preload("res://addons/semak/nodes/ActorNode.tscn")

# Using Godot's Unique Node Name syntax ensures it's found regardless of layout indentation
@onready var graph_edit: GraphEdit = $HSplitContainer/VBoxContainer/StoryGraph 
@onready var flag_list: ItemList = $HSplitContainer/SidebarTabs/DebuggerScroll/Debugger/FlagList
@onready var sidebar_tabs: TabContainer = $HSplitContainer/SidebarTabs
@onready var inspector_text_edit: TextEdit = $HSplitContainer/SidebarTabs/InspectorScroll/Inspector/InspectorTextEdit

@onready var save_load_manager = $SaveLoadManager
@onready var inspector_tab = $HSplitContainer/SidebarTabs/InspectorScroll/Inspector
@onready var debugger_tab = $HSplitContainer/SidebarTabs/DebuggerScroll/Debugger

var clipboard_data: Array = []

func _ready() -> void:
	# Fail-safe check to prevent tool editor crashes if things aren't rendered yet
	if not graph_edit:
		push_error("VN Tree Error: Could not locate your GraphEdit node! Check your scene tree names.")
		return
		
	save_load_manager.graph_edit = graph_edit
	debugger_tab.graph_edit = graph_edit
		
	# Safe to connect signals now!
	graph_edit.connection_request.connect(_on_connection_request)
	graph_edit.disconnection_request.connect(_on_disconnection_request)
	graph_edit.delete_nodes_request.connect(_on_delete_nodes_request)
	
	graph_edit.copy_nodes_request.connect(_on_copy_nodes_request)
	graph_edit.paste_nodes_request.connect(_on_paste_nodes_request)
	
	graph_edit.node_selected.connect(func(node): 
		inspector_tab.build_inspector(node)
		sidebar_tabs.current_tab = 0
	)
	graph_edit.node_deselected.connect(func(_node): inspector_tab.clear_inspector())
	
	graph_edit.popup_request.connect(_on_graph_popup_request)
	graph_edit.connection_to_empty.connect(_on_connection_to_empty)
	_setup_context_menu()

# Triggered when a designer drags a connection line from an output to an input slot
func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# Check if connection exactly identical exists to prevent duplicates
	for connection in graph_edit.get_connection_list():
		if connection.from_node == from_node and connection.from_port == from_port and connection.to_node == to_node and connection.to_port == to_port:
			return
			
	# Ensure one output port can only connect to one input port (standard graph behavior)
	for connection in graph_edit.get_connection_list():
		if connection.from_node == from_node and connection.from_port == from_port:
			graph_edit.disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			
	# We DO NOT block multiple connections to the same to_node/to_port anymore to allow Converging Inputs!
	graph_edit.connect_node(from_node, from_port, to_node, to_port)

# Triggered when a designer detaches or deletes a visual connection line
func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node = graph_edit.get_node(NodePath(node_name))
		if node:
			# Disconnect any lines tied to this node before killing it
			for conn in graph_edit.get_connection_list():
				if conn.from_node == node_name or conn.to_node == node_name:
					graph_edit.disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
			node.queue_free()
			
			
# --- CONTEXT MENU --- #
var context_menu: PopupMenu
var last_click_position: Vector2
var pending_connection_from_node: StringName = ""
var pending_connection_from_port: int = -1

func _setup_context_menu() -> void:
	context_menu = PopupMenu.new()
	context_menu.add_item("Add Dialogue", 0)
	context_menu.add_item("Add Choice Branch", 1)
	context_menu.add_item("Add D&D Check", 2)
	context_menu.add_item("Add Command", 3)
	context_menu.add_item("Add Condition", 4)
	context_menu.add_item("Add Actor / Stage", 5)
	context_menu.add_item("Add Start Entry", 6)
	context_menu.add_separator()
	context_menu.add_item("Add Comment Frame", 7)
	context_menu.id_pressed.connect(_on_context_menu_id_pressed)
	add_child(context_menu)

func _on_graph_popup_request(position: Vector2) -> void:
	pending_connection_from_node = ""
	pending_connection_from_port = -1
	last_click_position = position
	context_menu.position = Vector2i(get_viewport().get_mouse_position())
	context_menu.popup()

func _on_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	pending_connection_from_node = from_node
	pending_connection_from_port = from_port
	last_click_position = release_position
	context_menu.position = Vector2i(get_viewport().get_mouse_position())
	context_menu.popup()

func _on_context_menu_id_pressed(id: int) -> void:
	match id:
		0: _spawn_node(DIALOGUE_NODE_SCENE)
		1: _spawn_node(CHOICE_NODE_SCENE, true)
		2: _spawn_node(DND_CHECK_SCENE)
		3: _spawn_node(COMMAND_NODE_SCENE)
		4: _spawn_node(CONDITION_NODE_SCENE)
		5: _spawn_node(ACTOR_NODE_SCENE)
		6: _spawn_node(START_NODE_SCENE)
		7: _spawn_comment_frame()

func _spawn_node(scene: PackedScene, is_choice: bool = false) -> void:
	var node = scene.instantiate()
	
	# Assign a safe, unique name to prevent Godot from auto-assigning "@" names
	# "@" names get scrubbed on load, causing permanent line disconnections!
	node.name = "Node_" + str(Time.get_ticks_usec()) + "_" + str(randi() % 1000)
	
	node.position_offset = (last_click_position + graph_edit.scroll_offset) / graph_edit.zoom
	
	if node is GraphNode:
		node.delete_request.connect(func(): node.queue_free())
		
	graph_edit.add_child(node)
	
	if is_choice:
		node.add_choice_option("Choice Option 1")
		node.add_choice_option("Choice Option 2")
		
	if pending_connection_from_node != "":
		# Wait one frame for the node to enter the tree and get its unique name
		get_tree().create_timer(0.01).timeout.connect(func():
			if is_instance_valid(node) and node.is_inside_tree():
				graph_edit.connect_node(pending_connection_from_node, pending_connection_from_port, node.name, 0)
		)
		pending_connection_from_node = ""
		pending_connection_from_port = -1

func _spawn_comment_frame() -> void:
	# GraphFrame exists natively in Godot 4.3!
	var frame = null
	if ClassDB.class_exists("GraphFrame"):
		frame = ClassDB.instantiate("GraphFrame")
	else:
		# Fallback just in case they are on an older Godot 4 version
		frame = GraphNode.new()
		
	frame.resizable = true
	frame.title = "Comment Box"
	
	if frame.has_method("set_autoshrink_enabled"):
		frame.set_autoshrink_enabled(false)
		
	# Assign a safe, unique name
	frame.name = "Comment_" + str(Time.get_ticks_usec()) + "_" + str(randi() % 1000)
	
	# IMPORTANT: Godot requires manual plumbing for resize requests!
	if frame.has_signal("resize_request"):
		frame.resize_request.connect(func(new_size: Vector2):
			frame.size = new_size
		)
	
	var selected_nodes = []
	for child in graph_edit.get_children():
		if (child is GraphNode or child.is_class("GraphElement")) and child.get("selected") == true:
			selected_nodes.append(child)
			
	if selected_nodes.size() > 0:
		var min_pos = Vector2(INF, INF)
		var max_pos = Vector2(-INF, -INF)
		
		for node in selected_nodes:
			var pos = node.position_offset
			var size = node.size
			if pos.x < min_pos.x: min_pos.x = pos.x
			if pos.y < min_pos.y: min_pos.y = pos.y
			if pos.x + size.x > max_pos.x: max_pos.x = pos.x + size.x
			if pos.y + size.y > max_pos.y: max_pos.y = pos.y + size.y
			
		var padding = 40
		frame.position_offset = min_pos - Vector2(padding, padding + 20)
		frame.size = (max_pos - min_pos) + Vector2(padding * 2, padding * 2 + 20)
	else:
		frame.position_offset = (last_click_position + graph_edit.scroll_offset) / graph_edit.zoom
		frame.size = Vector2(300, 200)
	
	# Try to set tint color if available
	if frame.has_method("set_tint_color_enabled"):
		frame.set_tint_color_enabled(true)
		frame.set_tint_color(Color(0.2, 0.2, 0.2, 0.5))
	
	if frame is GraphNode or frame.has_signal("delete_request"):
		frame.delete_request.connect(func(): frame.queue_free())
		
	graph_edit.add_child(frame)
	
	pending_connection_from_node = ""
	pending_connection_from_port = -1
	
# Clear -- Helper function to wipe the board clean before loading or starting over
func clear_workspace() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()

func _on_toggle_sidebar_pressed() -> void:
	sidebar_tabs.visible = not sidebar_tabs.visible

func _on_copy_nodes_request() -> void:
	clipboard_data.clear()
	for child in graph_edit.get_children():
		if child.has_method("is_selected") and child.is_selected():
			if child.has_method("get_node_data"):
				var data = child.get_node_data()
				clipboard_data.append(data)
			elif child.get_class() == "GraphFrame":
				var data = {
					"type": "comment",
					"position": [child.position_offset.x, child.position_offset.y],
					"size": [child.size.x, child.size.y],
					"title": child.title
				}
				clipboard_data.append(data)

func _on_paste_nodes_request() -> void:
	if clipboard_data.is_empty():
		return
		
	# Deselect all
	graph_edit.set_selected(null)
	
	var offset = Vector2(50, 50)
	for data in clipboard_data:
		var node_data = data.duplicate(true)
		var type = node_data.get("type", "")
		
		var original_pos = node_data.get("position", [0,0])
		var new_pos = Vector2(original_pos[0] + offset.x, original_pos[1] + offset.y)
		
		# Hijack last_click_position so _spawn_node puts it at our new_pos exactly
		last_click_position = (new_pos * graph_edit.zoom) - graph_edit.scroll_offset
		
		if type == "comment":
			_spawn_comment_frame()
			# Need to wait a frame for it to spawn to set size/title properly
			get_tree().create_timer(0.01).timeout.connect(func():
				var new_frame = graph_edit.get_child(graph_edit.get_child_count() - 1)
				if new_frame.get_class() == "GraphFrame":
					new_frame.title = node_data.get("title", "")
					var s = node_data.get("size", [200, 200])
					new_frame.size = Vector2(s[0], s[1])
			)
		else:
			var scene: PackedScene = null
			var is_choice = false
			if type == "dialogue": scene = DIALOGUE_NODE_SCENE
			elif type == "choice_branch": 
				scene = CHOICE_NODE_SCENE
				is_choice = true
			elif type == "dnd_check": scene = DND_CHECK_SCENE
			elif type == "command": scene = COMMAND_NODE_SCENE
			elif type == "condition": scene = CONDITION_NODE_SCENE
			elif type == "actor": scene = ACTOR_NODE_SCENE
			elif type == "start": scene = START_NODE_SCENE
			
			if scene:
				_spawn_node(scene, false)
				# Need to inject the exact data since _spawn_node spawns defaults
				get_tree().create_timer(0.01).timeout.connect(func():
					var spawned = graph_edit.get_child(graph_edit.get_child_count() - 1)
					if spawned.has_method("set_node_data"):
						spawned.set_node_data(node_data)
						if spawned.has_method("update_preview"):
							spawned.update_preview()
				)
