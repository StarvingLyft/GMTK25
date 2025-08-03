extends Area2D


func _on_body_entered(body):
	if $trueIcon.visible:
		get_parent().get_node("coin_sound").play()
		hide()
		get_parent().flag_count-=1
		print(get_parent().flag_count)
