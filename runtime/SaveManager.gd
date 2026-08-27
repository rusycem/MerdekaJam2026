extends Node

const SAVE_DIR = "user://saves/"

func _ready():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func save_game(slot_name: String) -> void:
	var path = SAVE_DIR + slot_name + ".json"
	
	var data = {
		"player_name": GameState.player_name,
		"player_class": GameState.player_class,
		"flags": GameState.flags,
		"money": GameState.money,
		"last_minigame_result": GameState.last_minigame_result,
		"hub_turns_remaining": GameState.hub_turns_remaining,
		"next_chapter_uid": GameState.next_chapter_uid,
		"current_chapter_uid": GameState.current_chapter_uid,
		"resume_node_id": GameState.resume_node_id,
		"stats": GameState.stats
	}
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		print("SaveManager: Saved game to ", slot_name)
	else:
		print("SaveManager: Error opening file to save: ", path)

func load_game(slot_name: String) -> bool:
	var path = SAVE_DIR + slot_name + ".json"
	if not FileAccess.file_exists(path):
		print("SaveManager: Save file does not exist: ", path)
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return false
		
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(content)
	if err == OK:
		var data = json.get_data()
		if typeof(data) == TYPE_DICTIONARY:
			# Apply data
			if data.has("player_name"): GameState.player_name = str(data["player_name"])
			if data.has("player_class"): GameState.player_class = str(data["player_class"])
			
			if data.has("flags"):
				GameState.flags.clear()
				for f in data["flags"]:
					GameState.flags.append(f)
					
			if data.has("money"): GameState.money = int(data["money"])
			if data.has("last_minigame_result"): GameState.last_minigame_result = bool(data["last_minigame_result"])
			if data.has("hub_turns_remaining"): GameState.hub_turns_remaining = int(data["hub_turns_remaining"])
			if data.has("next_chapter_uid"): GameState.next_chapter_uid = str(data["next_chapter_uid"])
			if data.has("current_chapter_uid"): GameState.current_chapter_uid = str(data["current_chapter_uid"])
			if data.has("resume_node_id"): GameState.resume_node_id = str(data["resume_node_id"])
			
			if data.has("stats") and typeof(data["stats"]) == TYPE_DICTIONARY:
				for k in data["stats"]:
					GameState.stats[k] = int(data["stats"][k])
					
			print("SaveManager: Loaded game from ", slot_name)
			return true
			
	print("SaveManager: Failed to parse save file: ", path)
	return false

func get_all_saves() -> Array[String]:
	var saves: Array[String] = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				# Remove .json extension for the list
				saves.append(file_name.substr(0, file_name.length() - 5))
			file_name = dir.get_next()
	return saves

func get_save_metadata(slot_name: String) -> Dictionary:
	var path = SAVE_DIR + slot_name + ".json"
	if not FileAccess.file_exists(path):
		return {}
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
		
	var content = file.get_as_text()
	var modified_time = FileAccess.get_modified_time(path)
	file.close()
	
	var json = JSON.new()
	var err = json.parse(content)
	if err == OK:
		var data = json.get_data()
		if typeof(data) == TYPE_DICTIONARY:
			var time_dict = Time.get_datetime_dict_from_unix_time(modified_time)
			var time_str = "%04d-%02d-%02d %02d:%02d" % [time_dict.year, time_dict.month, time_dict.day, time_dict.hour, time_dict.minute]
			return {
				"player_name": data.get("player_name", "Unknown"),
				"player_class": data.get("player_class", "None"),
				"timestamp": time_str
			}
	return {}
