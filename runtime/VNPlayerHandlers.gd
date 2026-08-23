class_name VNPlayerHandlers extends RefCounted

static func handle_dialogue(player: Node, data: Dictionary) -> void:
	player.dialogue_panel.show()
	player.speaker_label.text = data.get("speaker", "").replace("{player}", GameState.player_name)
	player.text_label.text = data.get("text", "").replace("{player}", GameState.player_name)
	player.text_label.visible_characters = 0
	player.last_visible_characters = 0
	
	player.current_blip_pitch = 1.0
	var speaker_key = player.speaker_label.text.to_lower()
	if player.active_profiles.has(speaker_key):
		player.current_blip_pitch = player.active_profiles[speaker_key].blip_pitch
		
	if player.voice_player.playing:
		player.voice_player.stop()
		
	var voice_uid = data.get("voice_audio_uid", "")
	if voice_uid != "":
		var stream = ResourceLoader.load(voice_uid)
		if stream is AudioStream:
			player.voice_player.stream = stream
			player.voice_player.play()
	
	if player.type_tween:
		player.type_tween.kill()
		
	var text_length = player.text_label.text.length()
	if text_length > 0:
		player.type_tween = player.create_tween()
		player.type_tween.tween_property(player.text_label, "visible_characters", text_length, text_length * 0.03)
	else:
		player.text_label.visible_characters = -1
	
	if data.has("set_flags") and data["set_flags"] != "":
		GameState.grant_flags(data["set_flags"])
		
	player.current_node_id = data.get("next_node", "")

static func handle_choice(player: Node, data: Dictionary) -> void:
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


static func handle_dnd_check(player: Node, data: Dictionary) -> void:
	player.dice_panel.show()
	var stat = data.get("target_stat", "STR")
	var dc = data.get("dc_value", 10)
	
	var roll = randi() % 20 + 1
	var mod = GameState.get_stat_modifier(stat)
	var total = roll + mod
	
	var result_text = "Rolling %s Check...\n" % stat
	result_text += "d20 Roll: %d\n" % roll
	result_text += "%s Modifier: %+d\n" % [stat, mod]
	result_text += "Total: %d vs DC %d\n\n" % [total, dc]
	
	if total >= dc:
		result_text += "[color=green]SUCCESS![/color]"
		player.dice_target_node = data.get("next_pass", "")
	else:
		result_text += "[color=red]FAILURE![/color]"
		player.dice_target_node = data.get("next_fail", "")
		
	player.dice_result_label.text = result_text

static func handle_command(player: Node, data: Dictionary) -> void:
	var cmd = data.get("command", "")
	if cmd.begins_with("minigame"):
		var parts = cmd.split(" ", false)
		if parts.size() > 1:
			var minigame_id = parts[1]
			EventBus.start_minigame.emit(minigame_id)
			
			# Wait for the minigame to finish
			await EventBus.minigame_finished
			
	elif cmd.begins_with("start_hub"):
		var parts = cmd.split(" ", false)
		if parts.size() > 1:
			GameState.hub_turns_remaining = int(parts[1])
		else:
			GameState.hub_turns_remaining = 5
			
		GameState.resume_node_id = data.get("next_node", "")
		print("VNPlayer: Handing off to Hub. Resuming at ", GameState.resume_node_id)
		
		EventBus.start_hub.emit()
		player.queue_free()
		return # Stop execution entirely, we are destroying ourselves
		
	elif cmd.begins_with("bgm"):
		var parts = cmd.split(" ", false)
		if parts.size() > 1:
			if parts[1] == "stop":
				if Engine.has_singleton("AudioManager"):
					AudioManager.stop_bgm()
			elif parts[1] == "play" and parts.size() > 2:
				if Engine.has_singleton("AudioManager"):
					AudioManager.play_bgm(parts[2])
			
	elif cmd != "":
		GameState.execute_command(cmd)
		
	# Move to the next node immediately
	player.current_node_id = data.get("next_node", "")
	player._process_node()

static func handle_actor(player: Node, data: Dictionary) -> void:
	var events = data.get("events", [])
	
	for ev in events:
		var action = ev.get("action_type", "show_character")
		
		if action == "change_bg":
			var bg_uid = ev.get("background_uid", "")
			if bg_uid != "":
				var tex = ResourceLoader.load(bg_uid)
				if tex is Texture2D:
					if player.background_rect.texture != tex:
						# Crossfade
						player.background_rect_2.texture = player.background_rect.texture
						player.background_rect_2.modulate.a = 1.0
						player.background_rect.texture = tex
						player.background_rect.modulate.a = 0.0
						var tw = player.create_tween()
						tw.tween_property(player.background_rect, "modulate:a", 1.0, 0.5)
						tw.parallel().tween_property(player.background_rect_2, "modulate:a", 0.0, 0.5)
				else:
					print("VNPlayer: BG UID invalid")
					
		elif action == "hide_character":
			var char_name = ev.get("character", "Unknown").to_lower()
			var node_name = "Sprite_" + char_name
			if player.character_container.has_node(node_name):
				var sprite = player.character_container.get_node(node_name)
				sprite.queue_free()
				
		elif action == "show_character":
			var char_uid = ev.get("character_uid", "")
			var expr = ev.get("expression", "Neutral")
			
			var profile: CharacterProfile = null
			if char_uid != "":
				profile = ResourceLoader.load(char_uid) as CharacterProfile
				
			var char_name = ev.get("character", "Unknown").to_lower()
			if profile:
				player.active_profiles[char_name] = profile
				
			var node_name = "Sprite_" + char_name
			
			var sprite: TextureRect
			if player.character_container.has_node(node_name):
				sprite = player.character_container.get_node(node_name)
			else:
				sprite = TextureRect.new()
				sprite.name = node_name
				sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				sprite.stretch_mode = TextureRect.STRETCH_SCALE
				#set potrait size for characters
				sprite.custom_minimum_size = Vector2(400, 600)
				sprite.size = Vector2(400, 600)
				player.character_container.add_child(sprite)
				
			if profile and profile.portraits.has(expr):
				sprite.texture = profile.portraits[expr]
			else:
				print("VNPlayer: Portrait for ", expr, " not found in profile!")
				
			sprite.z_index = ev.get("z_index", 0)
			
			var slot = ev.get("position_slot", "Center")
			var screen_w = player.get_viewport().get_visible_rect().size.x
			var screen_h = player.get_viewport().get_visible_rect().size.y
			
			var base_x = screen_w / 2.0
			var start_offset_x = 0.0
			
			if slot == "Left": 
				base_x = screen_w * 0.2
				start_offset_x = -100.0
			elif slot == "Center-Left": 
				base_x = screen_w * 0.35
				start_offset_x = -100.0
			elif slot == "Center-Right": 
				base_x = screen_w * 0.65
				start_offset_x = 100.0
			elif slot == "Right": 
				base_x = screen_w * 0.8
				start_offset_x = 100.0
			
			var final_pos = Vector2(
				base_x - (sprite.custom_minimum_size.x / 2.0) + ev.get("offset_x", 0.0),
				(screen_h - sprite.custom_minimum_size.y) + ev.get("offset_y", 0.0)
			)
			
			var anim = ev.get("animation", "None")
			var dur = ev.get("anim_duration", 0.5)
			
			if anim == "None":
				sprite.position = final_pos
				sprite.modulate.a = 1.0
			elif anim == "Fade In":
				sprite.position = Vector2(final_pos.x + start_offset_x, final_pos.y)
				sprite.modulate.a = 0.0
				var tw = player.create_tween()
				tw.set_parallel(true)
				tw.tween_property(sprite, "modulate:a", 1.0, dur)
				tw.tween_property(sprite, "position:x", final_pos.x, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			elif anim == "Fade Out":
				sprite.position = final_pos
				var tw = player.create_tween()
				tw.set_parallel(true)
				tw.tween_property(sprite, "modulate:a", 0.0, dur)
				tw.tween_property(sprite, "position:x", final_pos.x + start_offset_x, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				tw.chain().tween_callback(sprite.queue_free)
			elif anim == "Jump":
				sprite.position = final_pos
				sprite.modulate.a = 1.0
				var tw = player.create_tween()
				tw.tween_property(sprite, "position:y", final_pos.y - 100, dur / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tw.tween_property(sprite, "position:y", final_pos.y, dur / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			elif anim == "Shake":
				sprite.position = final_pos
				sprite.modulate.a = 1.0
				var tw = player.create_tween()
				var shake_amt = 20.0
				for i in range(int(dur * 10)):
					tw.tween_property(sprite, "position:x", final_pos.x + randf_range(-shake_amt, shake_amt), 0.1)
				tw.tween_property(sprite, "position:x", final_pos.x, 0.1)
			
	# Proceed to next node
	player.current_node_id = data.get("next_node", "")
	player._process_node()

static func handle_condition(player: Node, data: Dictionary) -> void:
	var cond = data.get("condition", "")
	if GameState.evaluate_condition(cond):
		player.current_node_id = data.get("next_true", "")
	else:
		player.current_node_id = data.get("next_false", "")
		
	player._process_node()

