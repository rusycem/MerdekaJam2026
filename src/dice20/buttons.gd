extends Button

signal number_chosen(number: int)


func _ready() -> void :
	button_up.connect(_on_button_pressed)

func _on_button_pressed() -> void :
	number_chosen.emit(int(text))
