extends Node2D

func _on_validation_confirmed():
	$Confirm.show()

func _on_validation_canceled():
	$Again.show()

func _on_confirm_confirmed():
	pass # FINAL SEQUENCE

func _on_confirm_canceled():
	$Validation.show()

func _on_again_confirmed():
	get_tree().get_first_node_in_group("player").cam.process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_again_canceled():
	$Validation.show()

func _on_final_dialogue_finished():
	get_tree().get_first_node_in_group("player").cam.process_mode = PROCESS_MODE_PAUSABLE
	get_tree().paused = true
	$Validation.show()
