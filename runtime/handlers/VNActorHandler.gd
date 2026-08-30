class_name VNActorHandler
extends RefCounted

static func handle(player: Node, data: Dictionary) -> void:
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
						
						if player.has_method("add_to_history"):
							var loc_name = ev.get("place_name", "")
							if loc_name == "":
								loc_name = bg_uid.get_file().get_basename().capitalize().replace("_", " ")
							player.add_to_history("System", "[b]Location:[/b] " + loc_name, "")
				else:
					print("VNPlayer: BG UID invalid")
					
		elif action == "clear_stage":
			for child in player.character_container.get_children():
				child.queue_free()
			player.background_rect_2.texture = player.background_rect.texture
			player.background_rect_2.modulate.a = 1.0
			player.background_rect.texture = null
			player.background_rect.modulate.a = 0.0
			var tw = player.create_tween()
			tw.tween_property(player.background_rect_2, "modulate:a", 0.0, 0.5)

		elif action == "hide_all":
			for child in player.character_container.get_children():
				child.queue_free()
				
		elif action == "hide_character":
			var char_name = ev.get("character", "Unknown").replace("{player}", GameState.player_name).to_lower()
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
				
			var char_name = ev.get("character", "Unknown").replace("{player}", GameState.player_name).to_lower()
			if profile:
				if char_name == "player" or char_name == GameState.player_name.to_lower():
					if GameState.player_gender == "Female":
						var p = ResourceLoader.load("res://assets/DataAssets/CharacterData/FemalePlayer.tres")
						if p: profile = p as CharacterProfile
					else:
						var p = ResourceLoader.load("res://assets/DataAssets/CharacterData/MalePlayer.tres")
						if p: profile = p as CharacterProfile
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
			sprite.flip_h = ev.get("flip_h", false)
			
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
			sprite.set_meta("base_pos", final_pos)
			
			if expr.contains("_"):
				var ex_parts = expr.split("_")
				sprite.set_meta("pose", ex_parts[0])
				sprite.set_meta("emotion", ex_parts[1])
			else:
				sprite.set_meta("emotion", expr)
				if not sprite.has_meta("pose"): sprite.set_meta("pose", "Neutral")

			
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
