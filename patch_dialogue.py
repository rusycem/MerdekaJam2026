with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'r', encoding='utf-8') as f:
    text = f.read()

replacement = '''static func handle_dialogue(player: Node, data: Dictionary) -> void:
	player.dialogue_panel.show()
	player.speaker_label.text = data.get("speaker", "").replace("{player}", GameState.player_name)
	
	var raw_text = data.get("text", "").replace("{player}", GameState.player_name)
	
	var regex = RegEx.new()
	regex.compile("\\\\{([A-Za-z0-9_]+)\\\\}")
	var emotion = ""
	
	var results = regex.search_all(raw_text)
	for res in results:
		var tag = res.get_string(1)
		# We assume any tag other than player (which is already replaced) is an emotion
		emotion = tag.capitalize()
		raw_text = raw_text.replace(res.get_string(0), "")
		
	player.text_label.text = raw_text
	player.text_label.visible_characters = 0
	player.last_visible_characters = 0
	
	player.current_blip_pitch = 1.0
	var speaker_key = player.speaker_label.text.to_lower()
	if player.active_profiles.has(speaker_key):
		player.current_blip_pitch = player.active_profiles[speaker_key].blip_pitch
		if emotion != "":
			var profile = player.active_profiles[speaker_key]
			if profile.portraits.has(emotion):
				var node_name = "Sprite_" + speaker_key
				if player.character_container.has_node(node_name):
					var sprite = player.character_container.get_node(node_name)
					sprite.texture = profile.portraits[emotion]
					# Little bounce animation for emotion change
					var tw = player.create_tween()
					var orig_y = sprite.position.y
					tw.tween_property(sprite, "position:y", orig_y - 20, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					tw.tween_property(sprite, "position:y", orig_y, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
'''

import re
text = re.sub(r'static func handle_dialogue.*?player\.current_blip_pitch = player\.active_profiles\[speaker_key\]\.blip_pitch', replacement, text, flags=re.DOTALL)

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'w', encoding='utf-8') as f:
    f.write(text)
