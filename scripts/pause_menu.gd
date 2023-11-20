extends CanvasLayer

func _input(event):
	if event.is_action_pressed("pause"):
		visible = not visible
		get_tree().paused = not get_tree().paused

func _on_continue_pressed():
	visible = false
	get_tree().paused = false

func _on_quit_pressed():
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
