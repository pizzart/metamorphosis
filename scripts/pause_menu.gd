extends CanvasLayer

var can_show: bool

func unpause():
	$ClickSFX.play()
	
	$Control/PanelContainer/Main.show()
	$Control/PanelContainer/Settings.hide()
	
	hide()
	get_tree().paused = false
	AudioServer.set_bus_effect_enabled(1, 0, false)

func _input(event):
	if event.is_action_pressed("pause") and can_show:
		$ClickSFX.play()
		
		$Control/PanelContainer/Main.show()
		$Control/PanelContainer/Settings.hide()
		
		visible = not visible
		get_tree().paused = not get_tree().paused
		AudioServer.set_bus_effect_enabled(1, 0, not AudioServer.is_bus_effect_enabled(1, 0))
		if visible:
			Global.set_menu_cursor()
		else:
			Global.set_game_cursor()

func _on_continue_pressed():
	unpause()
	Global.set_game_cursor()

func _on_quit_pressed():
	unpause()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.after_boss = false
	Global.current_area = 0
	Global.loop = 0

func _on_settings_back():
	$Control/PanelContainer/Main.show()
	$Control/PanelContainer/Settings.hide()

func _on_settings_pressed():
	$ClickSFX.play()
	$Control/PanelContainer/Settings.show()
	$Control/PanelContainer/Main.hide()
