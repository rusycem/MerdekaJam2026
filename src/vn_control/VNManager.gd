# VNManager.gd
extends Node

# Global Signals for your Hybrid Architecture UI to listen to
signal dialogue_requested(speaker: String, text: String, profile: CharacterStats)
signal dnd_check_requested(stat_name: String, dc_value: int)
signal choice_menu_requested(prompt: String, choices_options: Array) # Options will be dictionaries with text, unlocked, hide_if_locked
signal story_ended()

var current_tree: VNStoryTree
var current_node_id: String = ""
var character_database: Dictionary = {}

var campaign_data: CampaignData
var active_save: SaveSlot

func _ready() -> void:
	# Load default campaign config
	if ResourceLoader.exists("res://src/vn_control/CampaignData.tres"):
		campaign_data = load("res://src/vn_control/CampaignData.tres")
		_initialize_campaign()
	else:
		print("VNManager: No CampaignData.tres found! Running with empty defaults.")
		active_save = SaveSlot.new()

func _initialize_campaign() -> void:
	character_database.clear()
	for character in campaign_data.character_roster:
		# Assuming CharacterStats has a character_name or we use resource name
		var char_name = character.resource_path.get_file().get_basename()
		# Fallback to resource name if there's no character_name property
		if "character_name" in character:
			char_name = character.get("character_name")
		character_database[char_name] = character

	active_save = SaveSlot.new()
	active_save.unlocked_flags = campaign_data.initial_story_flags.duplicate()
	active_save.relationships = {}

func set_flag(flag_name: String) -> void:
	if not active_save.unlocked_flags.has(flag_name):
		active_save.unlocked_flags.append(flag_name)
	print("Narrative System: Flag acquired -> ", flag_name)
	
func check_flag(flag_name: String) -> bool:
	return active_save.unlocked_flags.has(flag_name)

# Expression Evaluator for complex flags
func evaluate_condition(condition_str: String) -> bool:
	if condition_str.is_empty():
		return true
	
	var expression = Expression.new()
	var error = expression.parse(condition_str)
	if error != OK:
		print("VNManager: Expression parsing failed for condition '", condition_str, "': ", expression.get_error_text())
		return check_flag(condition_str) # Fallback to simple boolean flag check

	var result = expression.execute([], self)
	if expression.has_execute_failed():
		print("VNManager: Expression execution failed for condition '", condition_str, "'.")
		return check_flag(condition_str) # Fallback

	if typeof(result) == TYPE_BOOL:
		return result
	
	return check_flag(condition_str)

# Helper functions for the Godot Expression evaluator
func has_flag(flag: String) -> bool: 
	return check_flag(flag)

func get_relationship(character: String) -> int: 
	return active_save.relationships.get(character, 50)

func change_relationship(character: String, amount: int) -> void:
	active_save.relationships[character] = clampi(active_save.relationships.get(character, 50) + amount, 0, 100)
	print("Relationship Change: ", character, " is now ", active_save.relationships[character])

func load_story(resource_path: String) -> void:
	var story_resource = ResourceLoader.load(resource_path)
	if not story_resource is VNStoryTree:
		push_error("VNManager Error: Loaded file is not a valid VNStoryTree data asset!")
		return
	current_tree = story_resource	
	current_node_id = "Start" if current_tree.graph_data.has("Start") else current_tree.graph_data.keys()[0]
	print("VNManager: Successfully loaded story tree. Starting at node: ", current_node_id)
	_execute_current_node()

# Save Checkpoint at significant narrative moments
func save_checkpoint() -> void:
	if active_save:
		active_save.current_node_id = current_node_id
		active_save.timestamp = Time.get_datetime_string_from_system()
		var save_path = "user://save_checkpoint.tres"
		var err = ResourceSaver.save(active_save, save_path)
		if err == OK:
			print("VNManager: Checkpoint autosaved to ", save_path)
		else:
			print("VNManager Error: Checkpoint autosave failed. Code: ", err)

func _execute_current_node() -> void:
	if current_node_id == "" or not current_tree.graph_data.has(current_node_id):
		story_ended.emit()
		return
		
	var node_data: Dictionary = current_tree.graph_data[current_node_id]
	
	match node_data["type"]:
		"start":
			current_node_id = node_data["next_node"]
			_execute_current_node()
			
		"dialogue":
			if node_data.has("set_flags") and not node_data["set_flags"].is_empty():
				var flags = node_data["set_flags"].split(",")
				for f in flags:
					var clean_flag = f.strip_edges()
					if not clean_flag.is_empty():
						set_flag(clean_flag)
			
			var speaker = node_data["speaker"]
			var profile: CharacterStats = character_database.get(speaker, null)
			dialogue_requested.emit(speaker, node_data["text"], profile)
			
		"dnd_check":
			save_checkpoint() # Autosave before D&D check
			var target_stat = node_data["target_stat"]
			var dc_value = node_data["dc_value"]
			_calculate_automatic_dnd_check(target_stat, dc_value)
		
		"choice_branch":
			save_checkpoint() # Autosave before choices
			var raw_choices = node_data["choices"]
			var processed_choices: Array = []
			
			for choice_data in raw_choices:
				var is_unlocked = true
				if typeof(choice_data) == TYPE_DICTIONARY:
					is_unlocked = evaluate_condition(choice_data.get("condition", ""))
					processed_choices.append({
						"text": choice_data.get("text", ""),
						"unlocked": is_unlocked,
						"hide_if_locked": choice_data.get("hide_if_locked", false)
					})
				else:
					# Legacy string fallback
					processed_choices.append({
						"text": choice_data,
						"unlocked": true,
						"hide_if_locked": false
					})
					
			choice_menu_requested.emit(node_data["prompt"], processed_choices)

func advance_dialogue() -> void:
	if current_node_id == "" or not current_tree.graph_data.has(current_node_id):
		return
		
	var node_data = current_tree.graph_data[current_node_id]
	if node_data["type"] == "dialogue":
		current_node_id = node_data["next_node"]
		_execute_current_node()

func select_choice_branch(choice_index: int) -> void:
	var node_data = current_tree.graph_data[current_node_id]
	if node_data["type"] == "choice_branch":
		current_node_id = node_data["next_nodes"][choice_index]
		_execute_current_node()

func resolve_dnd_check(is_success: bool) -> void:
	var node_data = current_tree.graph_data[current_node_id]
	if node_data["type"] == "dnd_check":
		if is_success:
			print("VNManager: D&D Check PASSED. Routing to: ", node_data["next_pass"])
			current_node_id = node_data["next_pass"]
		else:
			print("VNManager: D&D Check FAILED. Routing to: ", node_data["next_fail"])
			current_node_id = node_data["next_fail"]
			
		_execute_current_node()

func _calculate_automatic_dnd_check(stat_name: String, dc: int) -> void:
	var player_profile: CharacterStats = character_database.get("Player", null)
	var modifier: int = 0
	
	if player_profile:
		modifier = player_profile.get_modifier(stat_name)
		
	var roll = randi_range(1, 20)
	var total = roll + modifier
	print("VN Engine: Player rolled d20 on ", stat_name, ". Roll: ", roll, " + Mod: ", modifier, " = Total: ", total, " vs DC: ", dc)
	
	resolve_dnd_check(total >= dc)
