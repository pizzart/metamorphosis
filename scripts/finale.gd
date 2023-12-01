extends Node2D

func _ready():
	UI.get_node("Control/M/Bars").hide()

func _on_validation_confirmed():
	$Confirm.show()

func _on_validation_canceled():
	$Again.show()

func _on_confirm_confirmed():
	$Stats.dialog_text = "TIME SPENT: %s\nSTATUS: SUCCESS" % snappedf(Global.timer, 0.01)
	$Stats.show()

func _on_confirm_canceled():
	$Validation.show()

func _on_again_confirmed():
	$AgainWarning.show()

func _on_again_canceled():
	$Validation.show()

func _on_final_dialogue_finished():
	get_tree().get_first_node_in_group("player").cam.process_mode = PROCESS_MODE_PAUSABLE
	get_tree().paused = true
	PauseMenu.can_show = false
	$Validation.show()

func _on_stats_confirmed():
	if Global.condition:
		Global.save_image()
		$Reward.show()
	else:
		goto_credits()

func _on_again_warning_canceled():
	$Validation.show()

func _on_again_warning_confirmed():
	get_tree().get_first_node_in_group("player").cam.process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = false
	
	Global.current_area = 0
	Global.after_boss = false
	Global.loop += 1
	UI.get_node("Control/M/Bars").show()
	
	get_tree().reload_current_scene()

func _on_reward_confirmed():
	goto_credits()

func goto_credits():
	UI.get_node("Control").hide()
	UI.transition_in(5)
	await get_tree().create_timer(5).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
