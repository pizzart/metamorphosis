extends Control

const UNREADABLE_FONT = preload("res://misc/font.png")

func _ready():
	PauseMenu.can_show = false
	UI.hide()
	Global.set_menu_cursor()

func _input(event):
	if not event is InputEventMouseMotion and not event is InputEventJoypadMotion and $Start.visible:
		$ClickSFX.play()
		$Start.hide()
		$M.show()

func _on_start_mouse_entered():
	$M/Main/List/Start.add_theme_font_override("font", UNREADABLE_FONT)

func _on_start_mouse_exited():
	$M/Main/List/Start.remove_theme_font_override("font")

func _on_start_pressed():
	for c in $M/Main/List.get_children():
		c.disabled = true
	UI.transition_in(0.1)
	var tween = create_tween().set_parallel()
	tween.tween_property($Black, "color", Color.BLACK, 3.0)
	tween.tween_property($Music, "volume_db", -80, 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	$ClickSFX.play()
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_settings_pressed():
	$ClickSFX.play()
	$M/Main.hide()
	$M/Settings.show()

func _on_quit_pressed():
	$ClickSFX.play()
	await $ClickSFX.finished
	get_tree().quit()

func _on_settings_back():
	$M/Settings.hide()
	$M/Main.show()

func _on_press_timer_timeout():
	$Start/Press.visible = not $Start/Press.visible

func _on_credits_pressed():
	$ClickSFX.play()
	$M/Main.hide()
	$M/Credits.show()

func _on_credits_back_pressed():
	$ClickSFX.play()
	$M/Credits.hide()
	$M/Main.show()
