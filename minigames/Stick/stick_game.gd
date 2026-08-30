extends Control

@onready var board: Node2D = $Board
@onready var turn_label: Label = $TurnLabel
@onready var result_panel: Panel = $ResultPanel
@onready var result_label: Label = $ResultPanel/ResultLabel
@onready var return_button: Button = $ResultPanel/ReturnButton

const STICK_W := 130.0
const STICK_H := 24.0
const STICK_CHAMFER := 7.0

const BOARD_W := 840.0
const BOARD_H := 460.0

const PLAYER_COLOR := Color(0.3, 0.62, 1.0)
const ENEMY_COLOR := Color(1.0, 0.4, 0.35)
const TABLE_COLOR := Color(0.31, 0.24, 0.17)

const LAYER_MAP := 1
const LAYER_PLAYER := 2
const LAYER_ENEMY := 4

const FLICK_IMPULSE := 500.0
const FLICK_TORQUE := 14.0
const BLAST_RADIUS := 100.0
const BLAST_MIN := 0.5
const BLAST_MAX := 1.5
const HOP_SCALE := 1.35
const HOP_TIME := 0.3
const FLIGHT_TIME := 1.2

const AI_DELAY := 1.0

enum Turn { PLAYER, AI, GAME_OVER }
enum Outcome { LANDED, OFF_TABLE, MISS }

var player_stick: RigidBody2D
var enemy_stick: RigidBody2D

var turn := Turn.PLAYER
var attacker: RigidBody2D
var defender: RigidBody2D
var resolving := false
var resolve_time := 0.0
var z_top := 1


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)
	_build_table()
	player_stick = _build_stick(Vector2(-300, 0), PLAYER_COLOR, LAYER_PLAYER)
	enemy_stick = _build_stick(Vector2(300, 0), ENEMY_COLOR, LAYER_ENEMY)
	_update_turn_label()


func _build_table() -> void:
	var poly := Polygon2D.new()
	poly.polygon = _rect_points(BOARD_W, BOARD_H)
	poly.color = TABLE_COLOR
	board.add_child(poly)


func _build_stick(pos: Vector2, color: Color, layer: int) -> RigidBody2D:
	var stick := RigidBody2D.new()
	stick.position = pos
	stick.rotation = PI / 2.0
	stick.gravity_scale = 0.0
	stick.linear_damp = 0.0
	stick.angular_damp = 0.0
	stick.can_sleep = false
	stick.collision_layer = layer
	stick.collision_mask = LAYER_MAP
	stick.z_index = z_top
	z_top += 1

	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(STICK_W, STICK_H)
	collision.shape = rect
	stick.add_child(collision)

	var sprite := Polygon2D.new()
	sprite.name = "Sprite"
	sprite.polygon = _chamfered_rect_points(STICK_W, STICK_H, STICK_CHAMFER)
	sprite.color = color
	stick.add_child(sprite)

	var detector := Area2D.new()
	detector.name = "Detector"
	detector.collision_layer = 0
	detector.collision_mask = LAYER_PLAYER | LAYER_ENEMY
	var detect_shape := CollisionShape2D.new()
	var detect_rect := RectangleShape2D.new()
	detect_rect.size = Vector2(STICK_W, STICK_H)
	detect_shape.shape = detect_rect
	detector.add_child(detect_shape)
	stick.add_child(detector)

	board.add_child(stick)
	return stick


func _detector_for(stick: RigidBody2D) -> Area2D:
	return stick.get_node("Detector") as Area2D


func _rect_points(w: float, h: float) -> PackedVector2Array:
	var hw := w / 2.0
	var hh := h / 2.0
	return PackedVector2Array([
		Vector2(-hw, -hh),
		Vector2(hw, -hh),
		Vector2(hw, hh),
		Vector2(-hw, hh),
	])


func _chamfered_rect_points(w: float, h: float, c: float) -> PackedVector2Array:
	var hw: float = w / 2.0
	var hh: float = h / 2.0
	var r: float = minf(c, minf(hw, hh))
	return PackedVector2Array([
		Vector2(-hw + r, -hh),
		Vector2(hw - r, -hh),
		Vector2(hw, -hh + r),
		Vector2(hw, hh - r),
		Vector2(hw - r, hh),
		Vector2(-hw + r, hh),
		Vector2(-hw, hh - r),
		Vector2(-hw, -hh + r),
	])


func _gui_input(event: InputEvent) -> void:
	if turn != Turn.PLAYER or resolving:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos := board.to_local(get_global_mouse_position())
		_start_turn(player_stick, enemy_stick, click_pos)


func _physics_process(delta: float) -> void:
	if not resolving:
		return

	resolve_time += delta

	if _is_off_table(attacker):
		_finish(Outcome.OFF_TABLE)
		return

	if resolve_time >= FLIGHT_TIME:
		if _detector_for(attacker).overlaps_body(defender):
			_finish(Outcome.LANDED)
		else:
			_finish(Outcome.MISS)


func _start_turn(attacker_stick: RigidBody2D, defender_stick: RigidBody2D, click_pos: Vector2) -> void:
	attacker = attacker_stick
	defender = defender_stick
	attacker.linear_velocity = Vector2.ZERO
	attacker.angular_velocity = 0.0
	resolving = true
	resolve_time = 0.0
	_flick(attacker_stick, defender_stick, click_pos)


func _flick(attacker_stick: RigidBody2D, defender_stick: RigidBody2D, click_pos: Vector2) -> void:
	var dir := attacker_stick.position - click_pos
	if dir.length() < 8.0:
		dir = defender_stick.position - attacker_stick.position
	dir = dir.normalized().rotated(randf_range(-0.05, 0.05))

	attacker_stick.z_index = z_top
	z_top += 1

	var sprite := attacker_stick.get_node("Sprite")
	var hop := create_tween()
	hop.tween_property(sprite, "scale", Vector2(HOP_SCALE, HOP_SCALE), FLIGHT_TIME / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hop.tween_property(sprite, "scale", Vector2.ONE, FLIGHT_TIME / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	var dist := click_pos.distance_to(attacker_stick.position)
	var power := clampf(1.5 - dist / BLAST_RADIUS, BLAST_MIN, BLAST_MAX)
	attacker_stick.apply_central_impulse(dir * (FLICK_IMPULSE * power))
	attacker_stick.apply_torque_impulse(FLICK_TORQUE * randf_range(-1.2, 1.2))


func _is_off_table(stick: RigidBody2D) -> bool:
	var p := stick.position
	return abs(p.x) > BOARD_W / 2.0 or abs(p.y) > BOARD_H / 2.0


func _finish(outcome: Outcome) -> void:
	resolving = false

	attacker.linear_velocity = Vector2.ZERO
	attacker.angular_velocity = 0.0

	var land := create_tween()
	land.tween_property(attacker.get_node("Sprite"), "scale", Vector2.ONE, HOP_TIME)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	if outcome == Outcome.MISS:
		_next_turn()
		return

	var attacker_won := outcome == Outcome.LANDED
	var player_won := attacker_won if attacker == player_stick else not attacker_won
	_end_game(player_won)


func _next_turn() -> void:
	if turn == Turn.PLAYER:
		turn = Turn.AI
		_update_turn_label()
		_schedule_ai_flick()
	else:
		turn = Turn.PLAYER
		_update_turn_label()


func _schedule_ai_flick() -> void:
	await get_tree().create_timer(AI_DELAY).timeout
	if turn != Turn.AI:
		return
	var to_player := (player_stick.position - enemy_stick.position).normalized()
	var perpendicular := to_player.orthogonal()
	var ai_click := enemy_stick.position - to_player * randf_range(190.0, 310.0)
	ai_click += perpendicular * randf_range(-70.0, 70.0)
	_start_turn(enemy_stick, player_stick, ai_click)


func _end_game(player_won: bool) -> void:
	turn = Turn.GAME_OVER
	resolving = false

	GameState.last_minigame_result = player_won

	result_panel.show()
	if player_won:
		result_label.text = "YOU WIN!"
		result_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		result_label.text = "YOU LOSE!"
		result_label.add_theme_color_override("font_color", Color.RED)


func _update_turn_label() -> void:
	match turn:
		Turn.PLAYER:
			turn_label.text = "Your turn - click BEHIND your stick to blast it toward the enemy!"
		Turn.AI:
			turn_label.text = "Opponent is aiming..."
		Turn.GAME_OVER:
			turn_label.text = ""


func _on_return_pressed() -> void:
	EventBus.minigame_finished.emit()
	queue_free()
