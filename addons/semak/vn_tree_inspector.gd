@tool
extends VBoxContainer

var currently_inspected_node: Node = null

func build_inspector(node: Node) -> void:
	clear_inspector()
	currently_inspected_node = node
	
	if not node.has_method("get_node_data"):
		# Could be a comment frame or unsupported node
		if node.is_class("GraphFrame") or (node is GraphNode and node.title == "Comment Box"):
			_build_comment_inspector(node)
		else:
			var lbl = Label.new()
			lbl.text = "No custom data to inspect."
			add_child(lbl)
		return
		
	var data = node.get_node_data()
	if data["type"] == "dialogue":
		_build_dialogue_inspector(node)
	elif data["type"] == "dnd_check":
		_build_dnd_inspector(node)
	elif data["type"] == "choice_branch":
		_build_choice_inspector(node)

func clear_inspector() -> void:
	currently_inspected_node = null
	for child in get_children():
		child.queue_free()
	var lbl = Label.new()
	lbl.text = "Select a node to edit..."
	add_child(lbl)

func _build_choice_inspector(node: GraphNode) -> void:
	var prompt_lbl = Label.new()
	prompt_lbl.text = "Prompt / Question:"
	add_child(prompt_lbl)
	
	var prompt_input = TextEdit.new()
	prompt_input.text = node.prompt_text
	prompt_input.custom_minimum_size = Vector2(0, 80)
	prompt_input.text_changed.connect(func(): 
		node.prompt_text = prompt_input.text
		node.update_preview()
	)
	add_child(prompt_input)
	
	var sep = HSeparator.new()
	add_child(sep)
	
	var options_lbl = Label.new()
	options_lbl.text = "Choices:"
	add_child(options_lbl)
	
	var options_container = VBoxContainer.new()
	add_child(options_container)
	
	var add_btn = Button.new()
	add_btn.text = "+ Add Choice"
	add_btn.pressed.connect(func():
		node.add_choice_option()
		_refresh_choice_inspector(node, options_container)
	)
	add_child(add_btn)
	
	_refresh_choice_inspector(node, options_container)

func _refresh_choice_inspector(node: GraphNode, container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()
		
	for child in node.get_children():
		if child != node.get_node("PreviewLabel") and child.has_meta("text"):
			var panel = PanelContainer.new()
			var vbox = VBoxContainer.new()
			panel.add_child(vbox)
			
			var text_input = LineEdit.new()
			text_input.text = child.get_meta("text")
			text_input.placeholder_text = "Choice text"
			text_input.text_changed.connect(func(val: String): 
				child.set_meta("text", val)
				node.refresh_choice_row(child)
			)
			vbox.add_child(text_input)
			
			var flag_input = LineEdit.new()
			flag_input.text = child.get_meta("condition")
			flag_input.placeholder_text = "Required Flag(s)"
			flag_input.text_changed.connect(func(val: String): 
				child.set_meta("condition", val)
				node.refresh_choice_row(child)
			)
			vbox.add_child(flag_input)
			
			var hbox = HBoxContainer.new()
			var hide_toggle = CheckBox.new()
			hide_toggle.text = "Hide if locked"
			hide_toggle.button_pressed = child.get_meta("hide_if_locked")
			hide_toggle.toggled.connect(func(val: bool): 
				child.set_meta("hide_if_locked", val)
			)
			hbox.add_child(hide_toggle)
			
			var del_btn = Button.new()
			del_btn.text = "Delete"
			del_btn.pressed.connect(func():
				node.call("_remove_option", child)
				get_tree().create_timer(0.05).timeout.connect(func():
					if is_instance_valid(container):
						_refresh_choice_inspector(node, container)
				)
			)
			hbox.add_child(del_btn)
			vbox.add_child(hbox)
			
			container.add_child(panel)

func _build_dialogue_inspector(node: GraphNode) -> void:
	var speaker_lbl = Label.new()
	speaker_lbl.text = "Speaker:"
	add_child(speaker_lbl)
	
	var speaker_input = LineEdit.new()
	speaker_input.text = node.speaker_text
	speaker_input.text_changed.connect(func(new_text: String): 
		node.speaker_text = new_text
		node.update_preview()
	)
	add_child(speaker_input)
	
	var text_lbl = Label.new()
	text_lbl.text = "Dialogue:"
	add_child(text_lbl)
	
	var text_input = TextEdit.new()
	text_input.text = node.dialogue_text
	text_input.custom_minimum_size = Vector2(0, 150)
	text_input.wrap_mode = 1 # LINE_WRAP_BOUNDARY
	text_input.text_changed.connect(func(): 
		node.dialogue_text = text_input.text
		node.update_preview()
	)
	add_child(text_input)
	
	var flags_lbl = Label.new()
	flags_lbl.text = "Grants Flags (comma separated):"
	add_child(flags_lbl)
	
	var flags_input = LineEdit.new()
	flags_input.text = node.flags_text
	flags_input.text_changed.connect(func(new_text: String): 
		node.flags_text = new_text
		node.update_preview()
	)
	add_child(flags_input)

func _build_dnd_inspector(node: GraphNode) -> void:
	var stat_lbl = Label.new()
	stat_lbl.text = "Target Stat:"
	add_child(stat_lbl)
	
	var stat_dropdown = OptionButton.new()
	var stats = ["STR", "DEX", "CON", "INT", "WIS", "CHA"]
	for s in stats:
		stat_dropdown.add_item(s)
	
	var idx = stats.find(node.target_stat)
	if idx != -1:
		stat_dropdown.selected = idx
		
	stat_dropdown.item_selected.connect(func(i: int): 
		node.target_stat = stats[i]
		node.update_preview()
	)
	add_child(stat_dropdown)
	
	var dc_lbl = Label.new()
	dc_lbl.text = "DC Value:"
	add_child(dc_lbl)
	
	var dc_input = SpinBox.new()
	dc_input.min_value = 1
	dc_input.max_value = 30
	dc_input.value = node.dc_value
	dc_input.value_changed.connect(func(val: float): 
		node.dc_value = int(val)
		node.update_preview()
	)
	add_child(dc_input)

func _build_comment_inspector(node: Control) -> void:
	var title_lbl = Label.new()
	title_lbl.text = "Comment Title:"
	add_child(title_lbl)
	
	var title_input = LineEdit.new()
	title_input.text = node.title
	title_input.text_changed.connect(func(val: String): node.title = val)
	add_child(title_input)
	
	var size_lbl = Label.new()
	size_lbl.text = "Frame Size:"
	add_child(size_lbl)
	
	var size_hbox = HBoxContainer.new()
	
	var w_lbl = Label.new()
	w_lbl.text = "W:"
	size_hbox.add_child(w_lbl)
	
	var w_input = SpinBox.new()
	w_input.max_value = 5000
	w_input.value = node.size.x
	w_input.value_changed.connect(func(v: float): node.size.x = v)
	size_hbox.add_child(w_input)
	
	var h_lbl = Label.new()
	h_lbl.text = "H:"
	size_hbox.add_child(h_lbl)
	
	var h_input = SpinBox.new()
	h_input.max_value = 5000
	h_input.value = node.size.y
	h_input.value_changed.connect(func(v: float): node.size.y = v)
	size_hbox.add_child(h_input)
	
	add_child(size_hbox)
	
	if node.has_method("set_tint_color_enabled"):
		var color_lbl = Label.new()
		color_lbl.text = "Tint Color:"
		add_child(color_lbl)
		
		var color_picker = ColorPickerButton.new()
		color_picker.custom_minimum_size = Vector2(0, 40)
		color_picker.color = node.get_tint_color() if node.has_method("get_tint_color") else Color(0.2, 0.2, 0.2, 0.5)
		color_picker.color_changed.connect(func(c: Color):
			node.set_tint_color_enabled(true)
			node.set_tint_color(c)
		)
		add_child(color_picker)
