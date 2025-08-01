extends CharacterBody2D

var speed = 300.0
var jump_speed = -400.0
var is_replaying: bool = false

# Get the gravity from the project settings so you can sync with rigid body nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_replaying:
		velocity.y = jump_speed

	# Get the input direction.
	if not is_replaying:
		var input_dir = Input.get_vector("left", "right", "ui_up", "ui_down")
		velocity.x = input_dir.x * speed

	move_and_slide()
