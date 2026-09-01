class_name VNChoiceHandler extends RefCounted

static func handle(player: Node, data: Dictionary) -> void:
	player.choices_panel.show()
	player.choice_prompt_label.text = data.get("prompt", "").replace("{player}", GameState.player_name)
	
	# Clear old choices
	for child in player.choices_container.get_children():
		child.queue_free()
		
	var choices = data.get("choices", [])
	var next_nodes = data.get("next_nodes", [])
	
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = choice.get("text", "").replace("{player}", GameState.player_name)
		
		var condition = choice.get("condition", "")
		var hide_if_locked = choice.get("hide_if_locked", false)
		var can_select = true
		
		if condition != "":
			can_select = GameState.evaluate_condition(condition)
					
		if not can_select:
			if hide_if_locked:
				continue
			else:
				btn.disabled = true
				btn.text += " (Locked)"
				
		var target_node = ""
		if i < next_nodes.size():
			target_node = next_nodes[i]
			
		btn.pressed.connect(func():
			player.current_node_id = target_node
			player._process_node()
		)
		player.choices_container.add_child(btn)
