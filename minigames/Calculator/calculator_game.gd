extends Control

@export var digit_slots: HBoxContainer

const OPERATIONS := ["+", "-", "*"]


var score: int = 0
var attempt: int = 0 # solely to make the game harder by time
var target_num: int
var display_cursor_position: int = 0 

func _process(_delta: float) -> void :
	if (Input.is_action_just_pressed("ui_up")) :
		_generate_random_equation()


func _ready() -> void :
	_connect_all_buttons()
	_generate_random_equation()


func _connect_all_buttons() -> void :
	var body := $TheCalc/MarginContainer/Body

	for row in body.get_children() :
		if (not row is HBoxContainer): continue

		for button in row.get_children() :
			button.pressed.connect(_on_button_pressed.bind(button))


func _generate_random_equation() -> void :
	var equation: String
	var target_label := $Target
	var result: int

	while (true) :
		equation = "XXXXX"
		equation = _place_operations(equation)
		equation = _place_numbers(equation)
		result   = _calculate_result(equation) 

		# if theres an err, but this also means that no equation will result in -1 lol
		if (result != -1) :
			break

	_place_digit(equation)

	print(equation)
	
	target_label.text = "Target: %s" % result


func _place_operations(equation: String) -> String :
	var total_operations := randi_range(1, 2)

	if (total_operations == 1) :
		var operation_slot := randi_range(1, 3)
		equation[operation_slot] = OPERATIONS.pick_random()

	else :
		for operation_slot in [1, 3] :
			equation[operation_slot] = OPERATIONS.pick_random()

	return equation


func _place_numbers(equation: String) -> String :
	for num_slot in equation.length() :
		if (equation[num_slot] in OPERATIONS): continue

		equation[num_slot] = str(randi_range(0, 9))

	return equation


func _calculate_result(equation: String) -> int :
	var expression := Expression.new()
	var response = expression.parse(equation)

	if (response != OK) :
		return -1

	var result = expression.execute()
	
	if (expression.has_execute_failed()) :
		return -1

	return result


func _place_digit(equation: String) -> void :
	var random_slot := randi_range(0, 4)
	var random_digit_slot = digit_slots.get_child(random_slot)

	# flush out the display
	for digit_slot in digit_slots.get_children() :
		digit_slot.text = ""

	random_digit_slot.text = equation[random_slot]



###########
# Signals #
###########
func _on_button_pressed(button: Button) -> void :
	if (button.text in ["=", "Del"]) :
		_handle_controls(button.text)
		return

	elif (button.text in OPERATIONS) :
		_handle_operations(button.text)

	else :
		_handle_numbers(button.text)



func _handle_controls(control: String) -> void :
	match control :
		"=" :
			_handle_calculation()

		"Del" :
			_handle_deletion()


func _handle_calculation() -> void :
	var digit_string := ""
	var result_label := $Result

	# combine the digits into a single string
	for digit_slot in digit_slots.get_children() :
		digit_string += digit_slot.text

	var expression := Expression.new()
	var response = expression.parse(digit_string)

	if (response != OK) :
		result_label.text = "Error"
		return

	var result = expression.execute()
	
	if (expression.has_execute_failed()) :
		result_label.text = "NaN"
		return

	result_label.text = str(result)


func _handle_deletion() -> void :
	display_cursor_position -= 1
	display_cursor_position = max(display_cursor_position, 0)

	var digit_slot = digit_slots.get_child(display_cursor_position)

	digit_slot.text = ""


func _handle_operations(operation: String) -> void :
	# disallow operations to be the first/last
	if (display_cursor_position in [0, 4]): return
	
	# disallow operations to be inserted in sequence
	var prev_digit_slot = digit_slots.get_child(display_cursor_position - 1)	
	if (prev_digit_slot.text in OPERATIONS): return
	
	_display_digit(operation)


func _handle_numbers(digit: String) -> void :
	_display_digit(digit)


func _display_digit(display_item: String) -> void :
	# do not do anything if curson is overflowed
	if (display_cursor_position == 5) :
		return

	var digit_slot := digit_slots.get_child(display_cursor_position)

	digit_slot.text = display_item
	display_cursor_position += 1
	display_cursor_position = min(display_cursor_position, 5) # allowing overflow so that the last slot can still be deleted
