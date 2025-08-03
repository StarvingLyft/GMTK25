extends Area2D

@export var jump_height: float = 300.0
@export var jump_time_up: float = 0.5
@export var jump_time_down: float = 0.4

var initial_position: Vector2
var is_jumping: bool = false

func _ready():
	initial_position = self.position

func _physics_process(_delta):
	if $trueIcon.visible:
		start_jump()

func start_jump():
	if is_jumping:
		return

	is_jumping = true
	
	var tween = create_tween()

	tween.set_parallel(false)
	tween.set_trans(Tween.TRANS_QUAD)

	tween.tween_property(self, "position:y", initial_position.y - jump_height, jump_time_up).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", initial_position.y, jump_time_down).set_ease(Tween.EASE_IN)

	tween.finished.connect(_on_jump_finished)

func _on_jump_finished():
	is_jumping = false
	self.position = initial_position

func _on_body_entered(body):
	if $trueIcon.visible and body.name == "player":
		body.dead()
