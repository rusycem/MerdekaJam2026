# Example code snippet for your UI Scene Script (e.g., GameUI.gd)
extends Control

@onready var name_label = $TextBox/SpeakerName
@onready var text_label = $TextBox/DialogueText
@onready var audio_player: AudioStreamPlayer = $TextBox/VoiceBlipPlayer

var active_profile: CharacterStats

func _ready() -> void:
	# Connecting standard local listeners to the global runtime event manager loops
	VNManager.dialogue_requested.connect(_on_dialogue_received)
	VNManager.dnd_check_requested.connect(_on_dnd_check_triggered)
	
	# Fix applied: setting TextServer enumeration cleanly
	text_label.visible_characters_behavior = TextServer.VC_CHARS_BEFORE_SHAPING
	text_label.character_displayed.connect(_on_character_displayed)
	
	# Boot up your custom workspace tree export file asset
	VNManager.load_story("res://story/chapter_1.tres")

func _on_dnd_check_triggered(stat: String, dc: int) -> void:
	# Trigger dice roll calculations! 
	# (For example, grab the player's STR stat modifier, add a d20 roll, and compare against 'dc')
	var player_modifier = 3 # Hardcoded placeholder for demonstration
	var roll = randi_range(1, 20)
	var total = roll + player_modifier
	
	print("Rolled a ", roll, " + ", player_modifier, " = ", total, " against DC: ", dc)
	
	# Tell the manager how the check resolved
	VNManager.resolve_dnd_check(total >= dc)

# Triggered when visible characters tick up on screen text scroll pipelines
func _on_text_label_character_displayed(character_index: int) -> void:
	if active_profile and active_profile.text_voice_blip:
		# Apply a slight pitch shift variance to clear mechanical repetition artifacting
		audio_player.stream = active_profile.text_voice_blip
		audio_player.pitch_scale = randf_range(active_profile.voice_pitch_min, active_profile.voice_pitch_max)
		audio_player.play()

func _on_dialogue_received(speaker: String, text: String, profile: CharacterStats) -> void:
	active_profile = profile
	name_label.text = speaker
	text_label.text = text
	
	# Animate crawling string array timeline values
	text_label.visible_ratio = 0.0
	var tween = create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, text.length() * 0.025)

func _on_character_displayed(character_index: int) -> void:
	if active_profile and active_profile.text_voice_blip:
		audio_player.stream = active_profile.text_voice_blip
		audio_player.pitch_scale = randf_range(active_profile.voice_pitch_min, active_profile.voice_pitch_max)
		audio_player.play()
		
func _on_next_button_pressed() -> void:
	VNManager.advance_dialogue()
