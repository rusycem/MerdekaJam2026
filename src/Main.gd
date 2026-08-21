# Main.gd
extends Node

@onready var level_container = $LevelContainer2D # This should be a Node3D for your 2.5D game
@onready var fader = $TransitionLayer/ColorRect

# This lets you drag and drop your starting scene in the Inspector
@export_file("*.tscn") var starting_level: String

func _ready() -> void:
	EventBus.level_change_requested.connect(_on_level_change_requested)
	fader.modulate.a = 0.0 # Ensure screen is clear when game starts
	
	# Load the starting scene if one is set
	if starting_level:
		_on_level_change_requested(starting_level)

func _on_level_change_requested(level_path: String) -> void:
	# 1. Fade to Black
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.5) # Fade to alpha 1 over 0.5 seconds
	await tween.finished # Wait for the fade to finish

	# 2. Swap the Level safely in the background
	for child in level_container.get_children():
		child.queue_free()

	var new_level_scene = load(level_path)
	if new_level_scene:
		var level_instance = new_level_scene.instantiate()
		level_container.add_child(level_instance)

	# 3. Fade back to Gameplay
	tween = create_tween()
	tween.tween_property(fader, "modulate:a", 0.0, 0.5) # Fade back to alpha 0
