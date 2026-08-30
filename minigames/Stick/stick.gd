extends RigidBody2D

@export var stick_color: Color = Color.WHITE

func _ready() -> void:
	get_node("Sprite").color = stick_color
