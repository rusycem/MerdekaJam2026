# EventBus.gd
extends Node

@warning_ignore("unused_signal")
signal level_change_requested(level_path: String)

signal scene_change_requested(scene_path: String, is_menu: bool)
