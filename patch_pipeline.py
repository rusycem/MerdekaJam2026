import re

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Update handle_dialogue
dialogue_func = '''static func handle_dialogue(player: Node, data: Dictionary) -> void:
	player.dialogue_panel.show()
	player.speaker_label.text = data.get("speaker", "").replace("{player}", GameState.player_name)
	
	var raw_text = data.get("text", "").replace("{player}", GameState.player_name)
	
	# Parse tag: {Emotion, Pose, Anim}
	var regex = RegEx.new()
	regex.compile("\\\\{([A-Za-z0-9_:, ]+)\\\\}")
	
	var new_emotion = ""
	var new_pose = ""
	var new_anim = ""
	
	var results = regex.search_all(raw_text)
	for res in results:
		var tag = res.get_string(1)
		var parts = tag.split(",")
		
		if parts.size() > 0 and parts[0].strip_edges() != "":
			new_emotion = parts[0].strip_edges().capitalize()
		if parts.size() > 1 and parts[1].strip_edges() != "":
			new_pose = parts[1].strip_edges().capitalize()
		if parts.size() > 2 and parts[2].strip_edges() != "":
			new_anim = parts[2].strip_edges().to_lower()
			
		raw_text = raw_text.replace(res.get_string(0), "")
		
	player.text_label.text = raw_text.strip_edges()
	player.text_label.visible_characters = 0
	player.last_visible_characters = 0
	
	player.current_blip_pitch = 1.0
	var speaker_key = player.speaker_label.text.to_lower()
	if player.active_profiles.has(speaker_key):
		player.current_blip_pitch = player.active_profiles[speaker_key].blip_pitch
		
		var node_name = "Sprite_" + speaker_key
		if player.character_container.has_node(node_name):
			var sprite = player.character_container.get_node(node_name)
			var profile = player.active_profiles[speaker_key]
			
			var current_emotion = sprite.get_meta("emotion", "Neutral")
			var current_pose = sprite.get_meta("pose", "Neutral")
			
			if new_emotion != "": current_emotion = new_emotion
			if new_pose != "": current_pose = new_pose
			
			sprite.set_meta("emotion", current_emotion)
			sprite.set_meta("pose", current_pose)
			
			var key_full = current_pose + "_" + current_emotion
			var tex = null
			
			if profile.portraits.has(key_full):
				tex = profile.portraits[key_full]
			elif profile.portraits.has(current_emotion):
				tex = profile.portraits[current_emotion]
				
			if tex:
				sprite.texture = tex
			
			var anim_to_play = new_anim
			if anim_to_play == "" and new_emotion != "":
				var EMOTION_ANIMATIONS = {
					"Happy": "bounce",
					"Angry": "shake",
					"Surprised": "jump",
					"Sad": "sink",
					"Annoyed": "twitch"
				}
				if EMOTION_ANIMATIONS.has(new_emotion):
					anim_to_play = EMOTION_ANIMATIONS[new_emotion]
					
			if anim_to_play != "":
				var tw = player.create_tween()
				var orig_pos = sprite.get_meta("base_pos", sprite.position)
				sprite.set_meta("base_pos", orig_pos)
				
				# Ensure sprite is back to base before animating
				sprite.position = orig_pos
				sprite.rotation_degrees = 0
				
				if anim_to_play == "bounce":
					tw.tween_property(sprite, "position:y", orig_pos.y - 20, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					tw.tween_property(sprite, "position:y", orig_pos.y, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				elif anim_to_play == "shake":
					var shake_amt = 15.0
					for i in range(4):
						tw.tween_property(sprite, "position:x", orig_pos.x + (shake_amt if i%2==0 else -shake_amt), 0.05)
					tw.tween_property(sprite, "position:x", orig_pos.x, 0.05)
				elif anim_to_play == "jump":
					tw.tween_property(sprite, "position:y", orig_pos.y - 60, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					tw.tween_property(sprite, "position:y", orig_pos.y, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				elif anim_to_play == "sink":
					tw.tween_property(sprite, "position:y", orig_pos.y + 25, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				elif anim_to_play == "twitch":
					tw.tween_property(sprite, "rotation_degrees", 5, 0.05)
					tw.tween_property(sprite, "rotation_degrees", -5, 0.05)
					tw.tween_property(sprite, "rotation_degrees", 0, 0.05)
'''

text = re.sub(r'static func handle_dialogue.*?player\.current_node_id = data\.get\("next_node", ""\)', dialogue_func + '\n\t\n\tplayer.current_node_id = data.get("next_node", "")', text, flags=re.DOTALL)


# 2. Update handle_actor to track base_pos, pose, and emotion
actor_patch = '''			var final_pos = Vector2(
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
'''
text = text.replace('''			var final_pos = Vector2(
				base_x - (sprite.custom_minimum_size.x / 2.0) + ev.get("offset_x", 0.0),
				(screen_h - sprite.custom_minimum_size.y) + ev.get("offset_y", 0.0)
			)''', actor_patch)

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'w', encoding='utf-8') as f:
    f.write(text)
