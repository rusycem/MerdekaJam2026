extends Control

# Error Hunt Minigame (Enhanced Multi-Format Edition)
# Formats: Word-Tap, MCQ Error Identification, Correction / Fill-in-the-Blank, Sentence Spotter
# Dataset: 200+ distinct authored questions from ErrorHuntData

@onready var time_label: Label = $Header/TimeLabel
@onready var score_label: Label = $Header/ScoreLabel
@onready var target_label: Label = $Header/TargetLabel

@onready var main_card: PanelContainer = $MainCard
@onready var badge_label: Label = $MainCard/VBox/BadgeLabel
@onready var prompt_label: Label = $MainCard/VBox/PromptLabel
@onready var sentence_display_card: PanelContainer = $MainCard/VBox/SentenceDisplayCard
@onready var sentence_label: Label = $MainCard/VBox/SentenceDisplayCard/SentenceLabel
@onready var word_card: PanelContainer = $MainCard/VBox/WordCard
@onready var word_container: HFlowContainer = $MainCard/VBox/WordCard/WordContainer
@onready var options_box: VBoxContainer = $MainCard/VBox/OptionsBox

@onready var result_panel: Panel = $ResultPanel
@onready var result_title: Label = $ResultPanel/ResultBox/ResultTitle
@onready var result_status: Label = $ResultPanel/ResultBox/ResultStatus
@onready var result_score_label: Label = $ResultPanel/ResultBox/ResultScoreLabel
@onready var return_button: Button = $ResultPanel/ResultBox/ReturnButton

# Minigame settings
var time_left: float = 60.0
var score: int = 0
var target_score: int = 100
var solved_count: int = 0
var game_active: bool = true
var is_transitioning: bool = false

var current_question: Dictionary = {}
var question_queue: Array[Dictionary] = []

func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)
	_refill_and_shuffle_queue()
	_load_next_question()
	_update_ui()

func _refill_and_shuffle_queue() -> void:
	question_queue = ErrorHuntData.QUESTIONS.duplicate()
	question_queue.shuffle()

func _process(delta: float) -> void:
	if not game_active:
		return
		
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_end_game()
	_update_ui()

func _update_ui() -> void:
	time_label.text = "Time: %.1fs" % time_left
	score_label.text = "Score: %d" % score
	target_label.text = "Target: %d pts (Solved: %d)" % [target_score, solved_count]
	
	if time_left <= 10.0:
		time_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
	elif time_left <= 25.0:
		time_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
	else:
		time_label.add_theme_color_override("font_color", Color.WHITE)

func _load_next_question() -> void:
	if question_queue.is_empty():
		_refill_and_shuffle_queue()
		
	current_question = question_queue.pop_front()
	is_transitioning = false
	
	var q_type = current_question.get("type", "word_tap")
	var category = current_question.get("category", "Grammar")
	
	# Clear old buttons
	for c in word_container.get_children():
		c.queue_free()
	for c in options_box.get_children():
		c.queue_free()
		
	match q_type:
		"word_tap":
			badge_label.text = "[TAP THE ERROR] %s" % category.to_upper()
			prompt_label.text = "Tap the incorrect word in the sentence below:"
			sentence_display_card.hide()
			word_card.show()
			options_box.hide()
			
			var words: Array = current_question.get("words", [])
			for i in range(words.size()):
				var word = str(words[i])
				var btn = Button.new()
				btn.text = word
				btn.custom_minimum_size = Vector2(70, 52)
				btn.add_theme_font_size_override("font_size", 26)
				btn.focus_mode = Control.FOCUS_NONE
				btn.pressed.connect(_on_word_pressed.bind(i, btn))
				word_container.add_child(btn)
				
		"mcq_error":
			badge_label.text = "[IDENTIFY THE ERROR] %s" % category.to_upper()
			prompt_label.text = current_question.get("prompt", "Identify the option with the grammatical error:")
			sentence_display_card.show()
			sentence_label.text = current_question.get("sentence", "")
			word_card.hide()
			options_box.show()
			
			_populate_options(current_question.get("options", []))
			
		"mcq_fix":
			badge_label.text = "[FILL IN THE BLANK] %s" % category.to_upper()
			prompt_label.text = current_question.get("prompt", "Choose the correct option to fix or complete the sentence:")
			sentence_display_card.show()
			sentence_label.text = current_question.get("sentence", "")
			word_card.hide()
			options_box.show()
			
			_populate_options(current_question.get("options", []))
			
		"sentence_spotter":
			badge_label.text = "[SPOT THE FLAW] %s" % category.to_upper()
			prompt_label.text = current_question.get("prompt", "Which of the four sentences contains a grammatical error?")
			sentence_display_card.hide()
			word_card.hide()
			options_box.show()
			
			_populate_options(current_question.get("options", []))

func _populate_options(options: Array) -> void:
	for i in range(options.size()):
		var opt_text = str(options[i])
		var btn = Button.new()
		btn.text = opt_text
		btn.custom_minimum_size = Vector2(0, 50)
		btn.add_theme_font_size_override("font_size", 22)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_option_pressed.bind(i, btn))
		options_box.add_child(btn)

func _on_word_pressed(word_index: int, button: Button) -> void:
	if not game_active or is_transitioning:
		return
		
	var correct_idx: int = current_question.get("correct_index", -1)
	if word_index == correct_idx:
		_handle_correct(button)
	else:
		_handle_incorrect(button)

func _on_option_pressed(option_index: int, button: Button) -> void:
	if not game_active or is_transitioning:
		return
		
	var correct_idx: int = current_question.get("correct_index", -1)
	if option_index == correct_idx:
		_handle_correct(button)
	else:
		_handle_incorrect(button)

func _handle_correct(button: Button) -> void:
	is_transitioning = true
	score += 10
	solved_count += 1
	_update_ui()
	
	button.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3, 1.0))
	var tw = create_tween()
	tw.tween_property(button, "scale", Vector2(1.08, 1.08), 0.08)
	tw.tween_property(button, "scale", Vector2(1.0, 1.0), 0.08)
	
	# Rapid, snappy transition (0.16s)
	await get_tree().create_timer(0.16).timeout
	if game_active:
		_load_next_question()

func _handle_incorrect(button: Button) -> void:
	button.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
	var tw = create_tween()
	var orig_pos = button.position
	tw.tween_property(button, "position:x", orig_pos.x - 8, 0.04)
	tw.tween_property(button, "position:x", orig_pos.x + 8, 0.04)
	tw.tween_property(button, "position:x", orig_pos.x, 0.04)
	tw.tween_callback(func():
		if is_instance_valid(button):
			button.remove_theme_color_override("font_color")
	)

func _end_game() -> void:
	game_active = false
	is_transitioning = true
	main_card.hide()
	result_panel.show()
	
	var win: bool = (score >= target_score)
	GameState.last_minigame_result = win
	
	if win:
		result_status.text = "SUCCESS!"
		result_status.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3, 1.0))
		result_title.text = "GREAT WORK!"
	else:
		result_status.text = "FAILED!"
		result_status.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3, 1.0))
		result_title.text = "TIME'S UP!"
		
	result_score_label.text = "Final Score: %d Points\nChallenges Solved: %d\nTarget Goal: %d Points" % [
		score, solved_count, target_score
	]

func _on_return_pressed() -> void:
	EventBus.minigame_finished.emit()
	queue_free()
