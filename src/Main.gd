# Main.gd
extends Node

@onready var level_container = $LevelContainer
@onready var menu_container = $UI/MenuContainer
@onready var fader = $TransitionLayer/ColorRect

@export_file("*.tscn") var starting_level: String

func _ready() -> void:
	EventBus.scene_change_requested.connect(_on_scene_change_requested)
	fader.modulate.a = 0.0 
	
	# Start the game by loading the Main Menu into the MenuContainer
	_on_scene_change_requested(starting_level, true)

func _on_scene_change_requested(scene_path: String, is_menu: bool) -> void:
	# 1. Fade to black
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.5)
	await tween.finished

	# 2. Clear out EVERYTHING (both old menus and old levels)
	for child in level_container.get_children():
		child.queue_free()
	for child in menu_container.get_children():
		child.queue_free()

	# 3. Load the new scene
	var new_scene = load(scene_path)
	if new_scene:
		var instance = new_scene.instantiate()
		
		# 4. Route it to the correct container based on the 'is_menu' flag
		if is_menu:
			menu_container.add_child(instance)
			# You can also hide the HUD here: $UI/HUD.hide()
		else:
			level_container.add_child(instance)
			# You can show the HUD here: $UI/HUD.show()

	# 5. Fade back in
	tween = create_tween()
	tween.tween_property(fader, "modulate:a", 0.0, 0.5)
