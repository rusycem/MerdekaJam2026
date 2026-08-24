extends Node2D

func _ready() -> void :
	var dice := $Window/SubViewport/dice20

	# attach signal to every buttons in the grid 
	for row in $VBoxContainer.get_children():
		for button in row.get_children():
			button.number_chosen.connect(dice.roll_to_number)


func _on_button_button_up() -> void:
	var dice := $Window/SubViewport/dice20
	dice.roll_to_number(randi_range(1, 20))
