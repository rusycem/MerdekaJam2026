class_name VNCommandHandler extends RefCounted

static func handle(player: Node, data: Dictionary) -> void:
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
		return # Stop execution entirely, Main.gd will cache us in memory
		
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

