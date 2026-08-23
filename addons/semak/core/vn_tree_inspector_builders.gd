@tool
class_name VNTreeInspectorBuilders
extends RefCounted

static func build_dialogue_inspector(inspector: VBoxContainer, node: GraphNode) -> void:
	var speaker_lbl = Label.new()
	speaker_lbl.text = "Speaker:"
	inspector.add_child(speaker_lbl)
	
	var speaker_input = LineEdit.new()
	speaker_input.text = node.speaker_text
	speaker_input.text_changed.connect(func(new_text: String): 
		node.speaker_text = new_text
		node.update_preview()
	)
	inspector.add_child(speaker_input)
	
	var text_lbl = Label.new()
	text_lbl.text = "Dialogue:"
	inspector.add_child(text_lbl)
	
	var text_input = TextEdit.new()
	text_input.text = node.dialogue_text
	text_input.custom_minimum_size = Vector2(0, 150)
	text_input.wrap_mode = 1 # LINE_WRAP_BOUNDARY
	text_input.text_changed.connect(func(): 
		node.dialogue_text = text_input.text
		node.update_preview()
	)
	inspector.add_child(text_input)
	
	var flags_lbl = Label.new()
	flags_lbl.text = "Grants Flags (comma separated):"
	inspector.add_child(flags_lbl)
	
	var flags_input = LineEdit.new()
	flags_input.text = node.flags_text
	flags_input.text_changed.connect(func(new_text: String): 
		node.flags_text = new_text
		node.update_preview()
	)
	inspector.add_child(flags_input)

static func build_dnd_inspector(inspector: VBoxContainer, node: GraphNode) -> void:
	var stat_lbl = Label.new()
	stat_lbl.text = "Target Stat:"
	inspector.add_child(stat_lbl)
	
	var stat_dropdown = OptionButton.new()
	var stats = ["Charm", "Intelligence", "Courage", "Dexterity"]
	for s in stats:
		stat_dropdown.add_item(s)
	
	var idx = stats.find(node.target_stat)
	if idx != -1:
		stat_dropdown.selected = idx
		
	stat_dropdown.item_selected.connect(func(i: int): 
		node.target_stat = stats[i]
		node.update_preview()
	)
	inspector.add_child(stat_dropdown)
	
	var dc_lbl = Label.new()
	dc_lbl.text = "DC Value:"
	inspector.add_child(dc_lbl)
	
	var dc_input = SpinBox.new()
	dc_input.min_value = 1
	dc_input.max_value = 30
	dc_input.value = node.dc_value
	dc_input.value_changed.connect(func(val: float): 
		node.dc_value = int(val)
		node.update_preview()
	)
	inspector.add_child(dc_input)

static func refresh_choice_inspector(inspector: VBoxContainer, node: GraphNode, container: VBoxContainer) -> void:
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
				node.get_tree().create_timer(0.05).timeout.connect(func():
					if is_instance_valid(container):
						refresh_choice_inspector(inspector, node, container)
				)
			)
			hbox.add_child(del_btn)
			vbox.add_child(hbox)
			
			container.add_child(panel)

static func build_choice_inspector(inspector: VBoxContainer, node: GraphNode) -> void:
	var prompt_lbl = Label.new()
	prompt_lbl.text = "Prompt / Question:"
	inspector.add_child(prompt_lbl)
	
	var prompt_input = TextEdit.new()
	prompt_input.text = node.prompt_text
	prompt_input.custom_minimum_size = Vector2(0, 80)
	prompt_input.text_changed.connect(func(): 
		node.prompt_text = prompt_input.text
		node.update_preview()
	)
	inspector.add_child(prompt_input)
	
	var sep = HSeparator.new()
	inspector.add_child(sep)
	
	var options_lbl = Label.new()
	options_lbl.text = "Choices:"
	inspector.add_child(options_lbl)
	
	var options_container = VBoxContainer.new()
	inspector.add_child(options_container)
	
	var add_btn = Button.new()
	add_btn.text = "+ Add Choice"
	add_btn.pressed.connect(func():
		node.add_choice_option()
		refresh_choice_inspector(inspector, node, options_container)
	)
	inspector.add_child(add_btn)
	
	refresh_choice_inspector(inspector, node, options_container)

static func build_command_inspector(inspector: VBoxContainer, node: GraphNode) -> void:
	var label = Label.new()
	label.text = "Command String:"
	inspector.add_child(label)
	
	var edit = LineEdit.new()
	edit.text = node.command_text
	edit.placeholder_text = "e.g. minigame calc, reward money 50"
	edit.text_changed.connect(func(new_text: String):
		node.command_text = new_text
		node.update_preview()
	)
	inspector.add_child(edit)

static func build_condition_inspector(inspector: VBoxContainer, node: GraphNode) -> void:
	var label = Label.new()
	label.text = "Condition Expression:"
	inspector.add_child(label)
	
	var edit = LineEdit.new()
	edit.text = node.condition_text
	edit.placeholder_text = "e.g. Math >= 50, has_met_mirul"
	edit.text_changed.connect(func(new_text: String):
		node.condition_text = new_text
		node.update_preview()
	)
	inspector.add_child(edit)

static func build_actor_inspector(inspector: VBoxContainer, node: GraphNode) -> void:
	var add_btn = Button.new()
	add_btn.text = "+ Add Scene Event"
	add_btn.pressed.connect(func():
		node.events.append({
			"action_type": "show_character",
			"character_uid": "",
			"character": "Alyssa",
			"expression": "Neutral",
			"position_slot": "Center",
			"offset_x": 0.0,
			"offset_y": 0.0,
			"z_index": 0,
			"animation": "None",
			"anim_duration": 0.5,
			"background_uid": ""
		})
		node.update_preview()
		inspector.build_inspector(node)
	)
	inspector.add_child(add_btn)
	inspector.add_child(HSeparator.new())
	
	for i in range(node.events.size()):
		var ev = node.events[i]
		
		var header_hbox = HBoxContainer.new()
		var action_lbl = Label.new()
		action_lbl.text = "Event " + str(i + 1) + ":"
		action_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_hbox.add_child(action_lbl)
		
		var del_btn = Button.new()
		del_btn.text = "X"
		del_btn.pressed.connect(func():
			node.events.remove_at(i)
			node.update_preview()
			inspector.build_inspector(node)
		)
		header_hbox.add_child(del_btn)
		inspector.add_child(header_hbox)
		
		var action_opt = OptionButton.new()
		action_opt.add_item("Show Character")
		action_opt.add_item("Hide Character")
		action_opt.add_item("Change Background")
		
		if ev["action_type"] == "show_character": action_opt.selected = 0
		elif ev["action_type"] == "hide_character": action_opt.selected = 1
		elif ev["action_type"] == "change_bg": action_opt.selected = 2
		
		action_opt.item_selected.connect(func(idx: int):
			if idx == 0: ev["action_type"] = "show_character"
			elif idx == 1: ev["action_type"] = "hide_character"
			elif idx == 2: ev["action_type"] = "change_bg"
			node.update_preview()
			inspector.build_inspector(node)
		)
		inspector.add_child(action_opt)
		
		if ev["action_type"] == "change_bg":
			var bg_lbl = Label.new()
			bg_lbl.text = "Background Image:"
			inspector.add_child(bg_lbl)
			var bg_picker = EditorResourcePicker.new()
			bg_picker.base_type = "Texture2D"
			if ev.has("background_uid") and ev["background_uid"] != "":
				var res = ResourceLoader.load(ev["background_uid"])
				if res: bg_picker.edited_resource = res
			bg_picker.resource_changed.connect(func(res: Resource):
				if res and res.resource_path != "":
					var uid = ResourceLoader.get_resource_uid(res.resource_path)
					ev["background_uid"] = ResourceUID.id_to_text(uid)
				else:
					ev["background_uid"] = ""
				node.update_preview()
			)
			inspector.add_child(bg_picker)
		else:
			var char_lbl = Label.new()
			char_lbl.text = "Character Profile (.tres):"
			inspector.add_child(char_lbl)
			var char_picker = EditorResourcePicker.new()
			char_picker.base_type = "CharacterProfile"
			if ev.has("character_uid") and ev["character_uid"] != "":
				var res = ResourceLoader.load(ev["character_uid"])
				if res: char_picker.edited_resource = res
			char_picker.resource_changed.connect(func(res: Resource):
				if res and res.resource_path != "":
					var uid = ResourceLoader.get_resource_uid(res.resource_path)
					ev["character_uid"] = ResourceUID.id_to_text(uid)
					if res.get("character_name"):
						ev["character"] = res.character_name
				else:
					ev["character_uid"] = ""
					ev["character"] = "Unknown"
				node.update_preview()
			)
			inspector.add_child(char_picker)
			
			if ev["action_type"] == "show_character":
				var exp_lbl = Label.new()
				exp_lbl.text = "Expression:"
				inspector.add_child(exp_lbl)
				var exp_edit = LineEdit.new()
				exp_edit.text = ev["expression"]
				exp_edit.text_changed.connect(func(val: String): ev["expression"] = val; node.update_preview())
				inspector.add_child(exp_edit)
				
				var pos_lbl = Label.new()
				pos_lbl.text = "Base Slot:"
				inspector.add_child(pos_lbl)
				var pos_opt = OptionButton.new()
				var slots = ["Left", "Center-Left", "Center", "Center-Right", "Right"]
				for s in slots: pos_opt.add_item(s)
				pos_opt.selected = slots.find(ev["position_slot"]) if slots.find(ev["position_slot"]) != -1 else 2
				pos_opt.item_selected.connect(func(idx: int): ev["position_slot"] = slots[idx]; node.update_preview())
				inspector.add_child(pos_opt)
				
				var off_lbl = Label.new()
				off_lbl.text = "Offset X/Y:"
				inspector.add_child(off_lbl)
				var off_hbox = HBoxContainer.new()
				var off_x = SpinBox.new()
				off_x.min_value = -2000; off_x.max_value = 2000; off_x.value = ev["offset_x"]
				off_x.value_changed.connect(func(val: float): ev["offset_x"] = val; node.update_preview())
				off_hbox.add_child(off_x)
				var off_y = SpinBox.new()
				off_y.min_value = -2000; off_y.max_value = 2000; off_y.value = ev["offset_y"]
				off_y.value_changed.connect(func(val: float): ev["offset_y"] = val; node.update_preview())
				off_hbox.add_child(off_y)
				inspector.add_child(off_hbox)
				
				var z_lbl = Label.new()
				z_lbl.text = "Z-Index:"
				inspector.add_child(z_lbl)
				var z_spin = SpinBox.new()
				z_spin.min_value = -10; z_spin.max_value = 10; z_spin.value = ev["z_index"]
				z_spin.value_changed.connect(func(val: float): ev["z_index"] = int(val); node.update_preview())
				inspector.add_child(z_spin)
				
				var anim_lbl = Label.new()
				anim_lbl.text = "Animation:"
				inspector.add_child(anim_lbl)
				var anim_opt = OptionButton.new()
				var anims = ["None", "Fade In", "Fade Out", "Jump", "Shake"]
				for a in anims: anim_opt.add_item(a)
				anim_opt.selected = anims.find(ev["animation"]) if anims.find(ev["animation"]) != -1 else 0
				anim_opt.item_selected.connect(func(idx: int): ev["animation"] = anims[idx]; node.update_preview())
				inspector.add_child(anim_opt)
				
				var dur_lbl = Label.new()
				dur_lbl.text = "Anim Duration (s):"
				inspector.add_child(dur_lbl)
				var dur_spin = SpinBox.new()
				dur_spin.min_value = 0.1; dur_spin.max_value = 10.0; dur_spin.step = 0.1; dur_spin.value = ev["anim_duration"]
				dur_spin.value_changed.connect(func(val: float): ev["anim_duration"] = val; node.update_preview())
				inspector.add_child(dur_spin)
				
		inspector.add_child(HSeparator.new())

static func build_comment_inspector(inspector: VBoxContainer, node: Control) -> void:
	var title_lbl = Label.new()
	title_lbl.text = "Comment Title:"
	inspector.add_child(title_lbl)
	
	var title_input = LineEdit.new()
	title_input.text = node.title
	title_input.text_changed.connect(func(val: String): node.title = val)
	inspector.add_child(title_input)
	
	var size_lbl = Label.new()
	size_lbl.text = "Frame Size:"
	inspector.add_child(size_lbl)
	
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
	
	inspector.add_child(size_hbox)
	
	if node.has_method("set_tint_color_enabled"):
		var color_lbl = Label.new()
		color_lbl.text = "Tint Color:"
		inspector.add_child(color_lbl)
		
		var color_picker = ColorPickerButton.new()
		color_picker.custom_minimum_size = Vector2(0, 40)
		color_picker.color = node.get_tint_color() if node.has_method("get_tint_color") else Color(0.2, 0.2, 0.2, 0.5)
		color_picker.color_changed.connect(func(c: Color):
			node.set_tint_color_enabled(true)
			node.set_tint_color(c)
		)
		inspector.add_child(color_picker)
