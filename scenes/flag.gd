extends Area2D


func _on_body_entered(body):
	if $trueIcon.visible:
		hide()
		get_parent().flag_count-=1
		if(get_parent().flag_count==0):
			print("Next level")
