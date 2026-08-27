extends Control

@export_file("*.tscn") var first_level_scene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
<<<<<<<< HEAD:scripts/main_menu.gd
	get_tree().change_scene_to_file("res://scenes/action_phase.tscn")

========
	EventBus.scene_change_requested.emit("res://src/UI/CharacterCreation.tscn", false)
>>>>>>>> 119211ca4243f91b086ec47ec6c60da160146f5f:src/UI/main_menu.gd

func _on_settings_pressed() -> void:
	var save_menu_res = load("res://scenes/UI/SaveMenu.tscn")
	if save_menu_res:
		var sm = save_menu_res.instantiate()
		add_child(sm)

func _on_exit_pressed():
	get_tree().quit()
