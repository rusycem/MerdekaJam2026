extends CharacterBody2D


@export var SPEED = 300.0
@export var GRAVITY := 980
@export var TERMINAL_VELOCITY := 500
@export var JUMP_STRENGTH := -400
@export var health := 5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_STRENGTH

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	var camera = get_viewport().get_camera_2d()
	if (position.y > camera.limit_bottom) :
		get_tree().quit()


#from movingenemy hitbox
func _on_hitbox_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Hostiles")):
		health -= 1
		print("Ouch")
	if (health <= 0):
		get_tree().quit()
		
