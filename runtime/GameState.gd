extends Node

var flags: Array[String] = []
var money: int = 0
var last_minigame_result: bool = false
var hub_turns_remaining: int = 5
var next_chapter_uid: String = ""
var current_chapter_uid: String = ""
var resume_node_id: String = ""

var player_name: String = "Student"
var player_class: String = "None"
var player_gender: String = "Male"

var stats: Dictionary = {
	"Charm": 5,
	"Intelligence": 5,
	"Courage": 5,
	"Dexterity": 5
}

func reset_state() -> void:
	player_name = "Student"
	player_class = "None"
	player_gender = "Male"
	flags.clear()
	money = 0
	last_minigame_result = false
	hub_turns_remaining = 5
	current_chapter_uid = ""
	resume_node_id = ""
	for stat in stats.keys():
		stats[stat] = 5

func has_flag(flag: String) -> bool:
	flag = flag.strip_edges()
	return flags.has(flag)

func grant_flags(flags_string: String) -> void:
	if flags_string.is_empty():
		return
		
	var granted = flags_string.split(",")
	for f in granted:
		var cleaned_flag = f.strip_edges()
		if cleaned_flag != "" and not flags.has(cleaned_flag):
			flags.append(cleaned_flag)
			print("GameState: Granted Flag [", cleaned_flag, "]")

func remove_flag(flag: String) -> void:
	flag = flag.strip_edges()
	if flags.has(flag):
		flags.erase(flag)
		print("GameState: Removed Flag [", flag, "]")

func execute_command(cmd: String) -> void:
	cmd = cmd.strip_edges()
	if cmd == "": return
	
	var parts = cmd.split(" ", false)
	if parts.size() < 2: return
	
	var action = parts[0].to_lower()
	var target = parts[1]
	
	if action == "reward":
		if target.to_lower() == "money" and parts.size() >= 3:
			money += int(parts[2])
			print("GameState: Gained ", parts[2], " money. Total: ", money)
			
	elif action == "set_next_chapter":
		next_chapter_uid = target
		print("GameState: Next Chapter set to ", next_chapter_uid)
		
	elif action == "add_turns":
		hub_turns_remaining += int(target)
		print("GameState: Added turns. Total turns: ", hub_turns_remaining)
	
	elif action == "stat":
		if parts.size() >= 3:
			# target could be "charm", make it capitalize first letter nicely
			var stat_name = target.capitalize()
			if stats.has(stat_name):
				stats[stat_name] += int(parts[2])
				print("GameState: Stat ", stat_name, " modified by ", parts[2])
				
	elif action == "flag":
		if parts.size() >= 3:
			var flag_name = parts[2]
			if target.to_lower() == "add":
				grant_flags(flag_name)
			elif target.to_lower() == "remove":
				remove_flag(flag_name)

func evaluate_condition(cond: String) -> bool:
	cond = cond.strip_edges()
	if cond == "": return true
	
	if "&&" in cond:
		var subconds = cond.split("&&")
		var result = true
		for sc in subconds:
			if not evaluate_condition(sc):
				result = false
				break
		return result
		
	if "||" in cond:
		var subconds = cond.split("||")
		var result = false
		for sc in subconds:
			if evaluate_condition(sc):
				result = true
				break
		return result
		
	var negate = false
	if cond.begins_with("!"):
		negate = true
		cond = cond.substr(1).strip_edges()
		
	if cond.to_lower() == "minigame_won":
		return last_minigame_result if not negate else not last_minigame_result
	if cond.to_lower() == "minigame_lost":
		return not last_minigame_result if not negate else last_minigame_result
	
	if ">=" in cond:
		var parts = cond.split(">=")
		var res = _get_value(parts[0].strip_edges()) >= int(parts[1].strip_edges())
		return res if not negate else not res
	elif "<=" in cond:
		var parts = cond.split("<=")
		var res = _get_value(parts[0].strip_edges()) <= int(parts[1].strip_edges())
		return res if not negate else not res
	elif ">" in cond:
		var parts = cond.split(">")
		var res = _get_value(parts[0].strip_edges()) > int(parts[1].strip_edges())
		return res if not negate else not res
	elif "<" in cond:
		var parts = cond.split("<")
		var res = _get_value(parts[0].strip_edges()) < int(parts[1].strip_edges())
		return res if not negate else not res
	elif "==" in cond:
		var parts = cond.split("==")
		var res = _get_value(parts[0].strip_edges()) == int(parts[1].strip_edges())
		return res if not negate else not res
		
	var has = has_flag(cond)
	if negate:
		return not has
	return has

func _get_value(key: String) -> int:
	if key.to_lower() == "money":
		return money
	var stat_name = key.capitalize()
	if stats.has(stat_name):
		return stats[stat_name]
	return 0

func get_stat_modifier(stat: String) -> int:
	var stat_name = stat.capitalize()
	if stats.has(stat_name):
		return floor((stats[stat_name] - 4) / 2.0)
	return 0
