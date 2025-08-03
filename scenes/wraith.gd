extends Area2D

@export var move_distance: float = 250.0
@export var move_time_left: float = 1
@export var move_time_right: float = 1

var initial_position: Vector2
var is_moving: bool = false

func _ready():
	initial_position = self.position

func _physics_process(_delta):
	if $trueIcon.visible:
		start_move()

func start_move():
	if is_moving:
		return

	is_moving = true
	
	var tween = create_tween()

	tween.set_parallel(false)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "position:x", initial_position.x - move_distance, move_time_left).set_ease(Tween.EASE_OUT)
	tween.tween_callback($trueIcon.set.bind("flip_h", true))
	tween.tween_property(self, "position:x", initial_position.x, move_time_right).set_ease(Tween.EASE_IN)
	tween.tween_callback($trueIcon.set.bind("flip_h", false))

	tween.finished.connect(_on_move_finished)

func _on_move_finished():
	is_moving = false
	self.position = initial_position


func _on_body_entered(body):
	if $trueIcon.visible and body.name == "player":
		body.dead()
