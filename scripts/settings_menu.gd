extends PanelContainer

signal back

func _ready():
	update_settings()

func update_settings():
	$M/List/Music/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(1)) * 20
	$M/List/Sound/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(2)) * 20
	$M/List/Sensitivity/HSlider.value = ((Global.mouse_sens + 0.0005) * 100 - 0.01) * 20
	$M/List/Shake/HSlider.value = Global.shake_strength * 20
	$M/List/Fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value / 20))

func _on_sound_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value / 20))

func _on_music_drag_ended(_value_changed):
	get_tree().call_group("settings", "update_settings")

func _on_sound_drag_ended(_value_changed):
	$ClickSFX.play()
	get_tree().call_group("settings", "update_settings")

func _on_sens_drag_ended(_value_changed):
	$ClickSFX.play()
	get_tree().call_group("settings", "update_settings")

func _on_sens_value_changed(value):
	Global.mouse_sens = max((value / 20 + 0.01) * 0.01 - 0.0005, 0.00001)

func _on_shake_drag_ended(_value_changed):
	get_tree().call_group("settings", "update_settings")

func _on_shake_value_changed(value):
	Global.shake_strength = value / 20

func _on_fullscreen_toggled(button_pressed):
	$ClickSFX.play()
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_tree().call_group("settings", "update_settings")

func _on_back_pressed():
	$ClickSFX.play()
	back.emit()
