extends Node2D

func _input(event):
	if event.is_action_pressed("record_toggle"):
		get_tree().change_scene_to_file("res://scenes/thankyou.tscn")
