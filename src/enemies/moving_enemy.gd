extends CharacterBody2D

# values
@export var speed: int = 67
@export var gravity: int = 100
@export var terminal_velocity: int = 400
var direction := Vector2.RIGHT


# just like normal _process(), but runs at a constant 60 times per sec
# even if the FPS is less
func _physics_process(delta: float) -> void :
	# set the goblin velo based on direction
	velocity.x = direction.x * speed 
	
	# gravity
	if (not is_on_floor()) :
		velocity.y += gravity
		velocity.y = min(terminal_velocity, velocity.y)
		
	if ($RayCast2D.is_colliding()) :
		direction *= -1
		$RayCast2D.target_position.x *= -1
		$Sprite2D.flip_h = !$Sprite2D.flip_h
	
	# apply physics
	move_and_slide()
