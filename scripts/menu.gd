extends Control

const UNREADABLE_FONT = preload("res://misc/font.png")

func _ready():
	PauseMenu.can_show = false
	UI.hide()

func _on_start_mouse_entered():
	$M/Main/List/Start.add_theme_font_override("font", UNREADABLE_FONT)

func _on_start_mouse_exited():
	$M/Main/List/Start.remove_theme_font_override("font")

func _on_start_pressed():
	$ClickSFX.play()
	await $ClickSFX.finished
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
