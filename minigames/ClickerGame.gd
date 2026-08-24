extends Control

@onready var time_label = $TimeLabel
@onready var score_label = $ScoreLabel
@onready var target_button = $TargetButton
@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/ResultLabel
@onready var return_button = $ResultPanel/ReturnButton

var time_left: float = 10.0
var clicks: int = 0
var target_clicks: int = 10
var game_active: bool = true

func _ready() -> void:
	target_button.pressed.connect(_on_target_pressed)
	return_button.pressed.connect(_on_return_pressed)
	_move_button()
	_update_ui()

func _process(delta: float) -> void:
	if not game_active:
		return
		
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		_end_game(false)
	_update_ui()

func _on_target_pressed() -> void:
	if not game_active: return
	
	clicks += 1
	if clicks >= target_clicks:
		_end_game(true)
	else:
		_move_button()
		_update_ui()

func _move_button() -> void:
	var screen_size = get_viewport_rect().size
	var btn_size = target_button.size
	
	# Keep it within bounds
	var max_x = screen_size.x - btn_size.x
	var max_y = screen_size.y - btn_size.y
	
	target_button.position = Vector2(
		randf_range(50, max_x - 50),
		randf_range(150, max_y - 50) # Keep below UI text
	)

func _update_ui() -> void:
	time_label.text = "Time: %.1f" % time_left
	score_label.text = "Clicks: %d / %d" % [clicks, target_clicks]

func _end_game(win: bool) -> void:
	game_active = false
	target_button.hide()
	result_panel.show()
	
	GameState.last_minigame_result = win
	
	if win:
		result_label.text = "SUCCESS!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		result_label.text = "FAILED!"
		result_label.add_theme_color_override("font_color", Color.RED)

func _on_return_pressed() -> void:
	# Tell EventBus we are done, VNPlayer will resume
	EventBus.minigame_finished.emit()
	queue_free()
