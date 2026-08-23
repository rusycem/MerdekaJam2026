with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'r', encoding='utf-8') as f:
    text = f.read()

missing_logic = '''
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
'''

import re
text = re.sub(r'\t\n\tplayer\.current_node_id = data\.get\("next_node", ""\)', missing_logic, text)
text = text.replace('regex.compile("\{([A-Za-z0-9_:, ]+)\}")', 'regex.compile("\\\\{([A-Za-z0-9_:, ]+)\\\\}")')

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'w', encoding='utf-8') as f:
    f.write(text)
