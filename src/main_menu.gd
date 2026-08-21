extends Control

@export_file("*.tscn") var first_level_scene: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	if first_level_scene:
		# Emit through the global EventBus singleton
		EventBus.level_change_requested.emit(first_level_scene)
	else:
		push_warning("No first level scene set in Main Menu inspector!")


func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed():
	get_tree().quit()
