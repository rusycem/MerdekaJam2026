extends Control

@export_file("*.tscn") var first_level_scene: String


func _ready() -> void:
	if get_tree().root.has_node("AudioManager"):
		AudioManager.play_bgm("res://assets/audio/bgm/SchoolOfOldLaughingPeople.ogg")

func _on_play_button_up() -> void:
	EventBus.scene_change_requested.emit("res://src/UI/CharacterCreation.tscn", false)


func _on_load_button_up() -> void:
	var save_menu_res = load("res://scenes/UI/SaveMenu.tscn")
	if save_menu_res:
		var sm = save_menu_res.instantiate()
		add_child(sm)


func _on_options_button_up() -> void:
	var settings := $Settings

	settings.visible = !settings.visible


func _on_quit_button_up() -> void:
	get_tree().quit()
