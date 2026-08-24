# LevelExit.gd
extends Area2D

@export_file("*.tscn") var target_level: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and target_level:
		print("yay!")
		EventBus.level_change_requested.emit(target_level)
