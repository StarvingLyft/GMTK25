extends Node2D

var target=1
var flag_count: int=1

func _process(_delta):
	if(flag_count==0):
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/fourth_level.tscn")

func _on_character_body_2d_level_reset():
	#TO-DO
	#Reset icons to q marks as before and hide trueIcons
	var icons: Array[Node] = find_children("","Area2D",false,false)
	for icon in icons:
		icon.show()
		icon.get_node("trueIcon").hide()
		icon.get_node("qMark").show()
	#Reset Player to Start with blank slate
	flag_count=target
	$player.position = $player.START_POS
	$player.set_collision_mask_value(1,true)
	$player/bilbo.hide()
	$player/gandalf.show()
	$player.start_recording()
