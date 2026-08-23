# EventBus.gd
extends Node

@warning_ignore("unused_signal")
signal level_change_requested(level_path: String)

signal scene_change_requested(scene_path: String, is_menu: bool)

# Signals for VN actions
signal dialogue_advanced
signal change_background(bg_path: String)
signal show_portrait(character_name: String, expression: String)
signal hide_portrait(character_name: String)
signal play_voice(audio_path: String)
