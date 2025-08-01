extends Area2D


func _on_body_entered(body):
	if $trueIcon.visible:
		body.dead()
