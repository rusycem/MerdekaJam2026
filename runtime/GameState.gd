extends Node

var flags: Array[String] = []
var dnd_stats: Dictionary = {
	"STR": 10,
	"DEX": 10,
	"CON": 10,
	"INT": 10,
	"WIS": 10,
	"CHA": 10
}

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

func get_stat_modifier(stat: String) -> int:
	if dnd_stats.has(stat):
		# Standard D&D 5e modifier calculation: (Score - 10) / 2
		return floor((dnd_stats[stat] - 10) / 2.0)
	return 0
