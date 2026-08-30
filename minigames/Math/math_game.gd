extends Control

@export var timer: TextureProgressBar
@export var score_label: Label
@export var equation_label: Label
@export var target_score: int = 50 

const PUNISHMENT_SECONDS := 10.0
const OPERATIONS := ["+", "-", "*"]

var score := 0
var answer_choice := 0
var is_game_over := false #


func _ready() -> void :
	_generate_question()


func _process(delta: float) -> void :
	if is_game_over:
		return
		
	timer.value -= delta
	score_label.text = "Score: %d" % score
	if (timer.value <= 0) :
		_handle_game_finish()


func _handle_game_finish() -> void :
	is_game_over = true
	var player_won: bool = score >= target_score
	GameState.last_minigame_result = player_won
	EventBus.minigame_finished.emit()
	queue_free()


func _handle_correct_answer() -> void :
	score += 10
	_generate_question()


func _handle_wrong_answer() -> void :
	timer.value -= PUNISHMENT_SECONDS
	_generate_question()


func _generate_question() -> void :
	answer_choice = randi_range(0, 2)

	var equation := _generate_equation()
	_assign_answer(equation)


func _generate_equation() -> String :
	var equation := ""

	# dumbass equation idc
	@warning_ignore("integer_division")
	var max_number_of_numbers := min(2 + (score / 100), 4) as int
	var number_of_numbers := randi_range(2, max_number_of_numbers)

	for i in range(number_of_numbers) :
		# dumbass equation idc
		@warning_ignore("integer_division")
		var max_random_num := min(20 + 10 * (score / 100), 1000) as int
		var random_num := str(randi_range(1, max_random_num))
		equation += " %s" % random_num

		var is_last_number := i == number_of_numbers - 1
		if (not is_last_number) :
			var random_operation := OPERATIONS.pick_random() as String
			equation += " %s" % random_operation

	equation_label.text = equation
	return equation


func _assign_answer(equation: String) -> void :	
	var answer := _calculate_equation(equation)
	var index := 0

	for choice in $"Body/MarginContainer/VBoxContainer/Answers".get_children() :
		if (index == answer_choice) :
			choice.text = str(answer)
		else :
			var delta := 0
			while (delta == 0) :
				delta = randi_range(-50, 50)
			choice.text = str(answer + delta)

		index += 1


func _calculate_equation(equation: String) -> int :
	var expression := Expression.new()
	var response = expression.parse(equation)

	if (response != OK) :
		return -1

	var result = expression.execute()
	
	if (expression.has_execute_failed()) :
		return -1

	return result


###########
# Signals #
###########
func _on_choice_a_button_up() -> void:
	if (answer_choice == 0) :
		_handle_correct_answer()
	else :
		_handle_wrong_answer()


func _on_choice_b_button_up() -> void:
	if (answer_choice == 1) :
		_handle_correct_answer()
	else :
		_handle_wrong_answer()


func _on_choice_c_button_up() -> void:
	if (answer_choice == 2) :
		_handle_correct_answer()
	else :
		_handle_wrong_answer()
