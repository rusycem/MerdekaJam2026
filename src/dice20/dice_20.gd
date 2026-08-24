extends Node3D

# why dict? readability and also 1-index
const FACES_ROTATION: Dictionary[String, Vector3] = {
	"1": Vector3(0, -90, -37.5),
	"2": Vector3(-30, 20, 167.0),
	"3": Vector3(20, 58.5, 31.0),
	"4": Vector3(21.5, -122, -149.5),
	"5": Vector3(-35, -159, -11.5),
	"6": Vector3(-36.0, -82, -102.5),
	"7": Vector3(0, -90, -80.5),
	"8": Vector3(-70.5, 58, 124.5),
	"9": Vector3(69.5, 118.5, 121.5),
	"10": Vector3(-34.5, 96, 77.5),

	"11": Vector3(35.5, -96.5, -103.5),
	"12": Vector3(-69.5, -119.5, -59.5),
	"13": Vector3(70.0, -65.5, -64.0),
	"14": Vector3(0.5, 89.5, 100.5),
	"15": Vector3(35.5, 81.5, 76.5),
	"16": Vector3(35, 157.5, 168.0),
	"17": Vector3(-20.5, 120.5, 31.5),
	"18": Vector3(-20.5, -60.0, -148.5),
	"19": Vector3(35.5, -22.5, -13.0),
	"20": Vector3(180, -90, -37.5),
}


@export var settle_duration := 0.5
@export var spin_speed := 1800.0
@export var spin_acceleration := 3600.0

var target_number := 1
var rolling := false
var _spin_dir := Vector3.ZERO
var _spin_velocity := Vector3.ZERO
var _settle_tween: Tween


func _process(delta: float) -> void :
	if rolling :
		spin_randomly(delta)


func roll_to_number(n: int) -> void :
	target_number = n

	# reset if die is rolled again
	if (_settle_tween) :
		_settle_tween.kill()
		_settle_tween = null

	rolling = true

	_spin_dir = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()

	_spin_velocity = Vector3.ZERO
	$RollingTimer.start()


func spin_randomly(delta: float) -> void :
	_spin_velocity = _spin_velocity.move_toward(_spin_dir * spin_speed, spin_acceleration * delta)

	_spin_velocity += Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	) * spin_speed * delta * 0.5

	_spin_velocity = _spin_velocity.limit_length(spin_speed * 1.5)

	rotation_degrees += _spin_velocity * delta


func _on_rolling_timer_timeout() -> void :
	rolling = false
	_settle_tween = create_tween()

	_settle_tween.tween_property(
		self,
		"rotation_degrees",
		FACES_ROTATION[str(target_number)],
		settle_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
