# CharacterStats.gd
class_name CharacterStats
extends Resource

@export var character_name: String = "Unnamed Student"

@export_category("D&D Attributes")
@export_range(1, 30) var dexterity: int = 10
@export_range(1, 30) var intelligence: int = 10
@export_range(1, 30) var charisma: int = 10

@export_category("Audio Configuration")
## The unique sound loop played letter-by-letter as this character's text prints out (Animal Crossing / Undertale style)
@export var text_voice_blip: AudioStream
## Pitch range variance for the text blips to make the voice sound more organic
@export var voice_pitch_min: float = 0.95
@export var voice_pitch_max: float = 1.05

# Helper method to calculate standard D&D D20 modifiers
func get_modifier(stat_name: String) -> int:
	var value: int = 10
	match stat_name.to_upper():
		"DEX": value = dexterity
		"INT": value = intelligence
		"CHA": value = charisma
		
	# Standard D&D 5e modifier calculation: (Score - 10) / 2 floored
	return floori((value - 10) / 2.0)
