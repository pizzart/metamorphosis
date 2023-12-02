extends PanelContainer

signal back
const INPUT = preload("res://scenes/input.tscn")
const INPUTS = {
	"up": "up",
	"down": "down",
	"left": "left",
	"right": "right",
	"attack": "attack",
	"change_gun": "switch",
	"use": "interact",
	"special": "special",
	"heal": "heal",
}
var awaiting_input: bool
var current_input: InputEvent
var current_action: StringName
var current_button

func _ready():
	update_settings()

func update_all_inputs():
	for c in $Controls/Scroll/V.get_children():
		c.queue_free()
	for input in INPUTS.keys():
		var inp = INPUT.instantiate()
		inp.get_node("Label").text = INPUTS[input]
		for i in InputMap.action_get_events(input):
			if i is InputEventKey:
				inp.get_node("Button").text = OS.get_keycode_string(i.physical_keycode)
				inp.get_node("Button").tooltip_text = ""
				inp.get_node("Button").pressed.connect(_on_input_pressed.bind(inp, i, input))
				break
			elif i is InputEventMouseButton:
				inp.get_node("Button").text = ""
				inp.get_node("Button").tooltip_text = ""
				if i.button_index == MOUSE_BUTTON_LEFT:
					inp.get_node("Button").icon = preload("res://sprites/ui/lmb.png")
				elif i.button_index == MOUSE_BUTTON_RIGHT:
					inp.get_node("Button").icon = preload("res://sprites/ui/rmb.png")
				else:
					inp.get_node("Button").text = "err!"
					inp.get_node("Button").tooltip_text = "the input can be used but there is no icon for it\n" + i.as_text()
				inp.get_node("Button").pressed.connect(_on_input_pressed.bind(inp, i, input))
				break
			else:
				inp.get_node("Button").text = "big err!"
				inp.get_node("Button").tooltip_text = "the input can be used but there is no icon for it\n" + i.as_text()
		$Controls/Scroll/V.add_child(inp)

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if awaiting_input:
			$ClickSFX.play()
			awaiting_input = false
			
			if not event.is_action_pressed("ui_cancel"):
				InputMap.action_erase_event(current_action, current_input)
				InputMap.action_add_event(current_action, event)
			
			update_all_inputs()
			UI.update_keys()

func update_settings():
	$M/List/Music/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(1)) * 20
	$M/List/Sound/HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(2)) * 20
	$M/List/Sensitivity/HSlider.value = ((Global.mouse_sens + 0.0005) * 100 - 0.01) * 20
	$M/List/Shake/HSlider.value = Global.shake_strength * 20
	$M/List/Fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	$M/List/Aberration.button_pressed = Global.aberration_enabled
	$M/List/Timer.button_pressed = UI.timer.visible
	$M/List/Hold.button_pressed = Global.skip_enabled
	update_all_inputs()

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
	$ClickSFX.play()
	get_tree().call_group("settings", "update_settings")

func _on_shake_value_changed(value):
	Global.shake_strength = value / 20

func _on_fullscreen_toggled(button_pressed):
	$ClickSFX.play()
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_tree().call_group("settings", "update_settings")

func _on_back_pressed():
	$ClickSFX.play()
	back.emit()

func _on_input_pressed(item, input: InputEvent, action: StringName):
	item.get_node("Button").text = "..."
	item.get_node("Button").icon = null
	awaiting_input = true
	current_input = input
	current_button = item
	current_action = action

func _on_controls_pressed():
	$ClickSFX.play()
	$M.hide()
	$Controls.show()

func _on_controls_back_pressed():
	$ClickSFX.play()
	$Controls.hide()
	$M.show()

func _on_reset_pressed():
	$ClickSFX.play()
	InputMap.load_from_project_settings()
	update_all_inputs()
	UI.update_keys()

func _on_aberration_toggled(button_pressed):
	$ClickSFX.play()
	Global.aberration_enabled = button_pressed
	if button_pressed:
		Global.set_shader_param(1, "aberration_amount")
	else:
		Global.set_shader_param(0, "aberration_amount")

func _on_timer_toggled(button_pressed):
	$ClickSFX.play()
	UI.timer.visible = button_pressed

func _on_hold_toggled(button_pressed):
	$ClickSFX.play()
	Global.skip_enabled = button_pressed
