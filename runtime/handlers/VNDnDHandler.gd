class_name VNDnDHandler extends RefCounted

static func handle(player: Node, data: Dictionary) -> void:
	player.dice_panel.show()
	var stat = data.get("target_stat", "STR")
	var dc = data.get("dc_value", 10)
	
	var roll = randi() % 20 + 1
	var mod = GameState.get_stat_modifier(stat)
	var total = roll + mod
	
	# Find UI elements
	var vbox = player.dice_panel.get_node_or_null("VBoxContainer")
	var dice_viewport = player.dice_panel.get_node_or_null("DiceViewportContainer")
	var dice_node = player.dice_panel.find_child("dice20", true, false)
	
	# Enable Transparent BG and optimize
	if dice_viewport:
		dice_viewport.get_node("SubViewport").transparent_bg = true
		dice_viewport.get_node("SubViewport").render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# State 1: Rolling
	player.dice_panel.self_modulate.a = 0.0 # Hide panel background
	if vbox: vbox.hide()
	
	var original_pos = Vector2.ZERO
	if dice_viewport:
		# Compute the intended position dynamically using anchors and offsets
		# This avoids the Godot 4 hidden-control layout bug where position is (0,0)
		original_pos = Vector2(
			(player.dice_panel.size.x * 0.5) + dice_viewport.offset_left,
			(player.dice_panel.size.y * 0.5) + dice_viewport.offset_top
		)
		dice_viewport.show()
		
		# Center it perfectly on the SCREEN for the cinematic roll!
		var screen_size = player.get_viewport().get_visible_rect().size
		var global_center = screen_size / 2.0 - (dice_viewport.size / 2.0)
		dice_viewport.global_position = global_center
	
	if dice_node and dice_node.has_method("roll_to_number"):
		dice_node.roll_to_number(roll)
		await dice_node.roll_finished
		await player.get_tree().create_timer(0.4).timeout
	else:
		await player.get_tree().create_timer(1.0).timeout
	
	# State 2: Results Animation
	if dice_viewport:
		var tw = player.create_tween()
		tw.set_parallel(true)
		# Move the dice back UP to exactly where you placed it in the editor!
		tw.tween_property(dice_viewport, "position", original_pos, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(player.dice_panel, "self_modulate:a", 1.0, 0.4)
		await tw.finished
		dice_viewport.get_node("SubViewport").render_target_update_mode = SubViewport.UPDATE_DISABLED
	else:
		player.dice_panel.self_modulate.a = 1.0
		
	# Format aesthetic result text
	var result_text = ""
	if total >= dc:
		result_text += "[center][font_size=36][color=green]SUCCESS[/color][/font_size][/center]\n\n"
		player.dice_target_node = data.get("next_pass", "")
	else:
		result_text += "[center][font_size=36][color=red]FAILURE[/color][/font_size][/center]\n\n"
		player.dice_target_node = data.get("next_fail", "")
		
	result_text += "[center]Rolling %s Check\n" % stat
	result_text += "Target DC: [b]%d[/b]\n\n" % dc
	
	result_text += "Roll: %d\n" % roll
	if mod >= 0:
		result_text += "Modifier: +%d\n" % mod
	else:
		result_text += "Modifier: %d\n" % mod
		
	result_text += "\n[font_size=24]Total: [b]%d[/b][/font_size][/center]" % total
	
	player.dice_result_label.text = result_text
	
	if vbox: 
		vbox.modulate.a = 0.0
		vbox.show()
		var tw2 = player.create_tween()
		tw2.tween_property(vbox, "modulate:a", 1.0, 0.3)

