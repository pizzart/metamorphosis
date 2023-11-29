extends Control

const UNREADABLE_FONT = preload("res://misc/font.png")
const MENU_SPRITE = preload("res://scenes/menu_sprite.tscn")
const TEXTURES = [
	preload("res://sprites/menu/noddy.png"),
]

func _ready():
	PauseMenu.can_show = false
	UI.hide()
	Global.set_menu_cursor()
	for i in range(6):
		add_sprite()
		await get_tree().create_timer(Global.rng.randf_range(0.5, 1.3)).timeout

func _process(delta):
	var r = Global.rng.randf()
	if r < 0.001:
		add_sprite()

func _input(event):
	if not event is InputEventMouseMotion and not event is InputEventJoypadMotion:
		$Start.hide()
		$M.show()

func add_sprite():
	var sprite = MENU_SPRITE.instantiate()
	sprite.texture = TEXTURES.pick_random()
	sprite.direction = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN].pick_random()
	sprite.speed = Global.rng.randf_range(5.0, 18.0)
	sprite.global_position = Vector2(160, 120) - sprite.direction * 200
	if sprite.direction.x != 0:
		sprite.global_position.y += Global.rng.randf_range(-130, 130)
	else:
		sprite.global_position.x += Global.rng.randf_range(-170, 170)
#	add_child(sprite)

func _on_start_mouse_entered():
	$M/Main/List/Start.add_theme_font_override("font", UNREADABLE_FONT)

func _on_start_mouse_exited():
	$M/Main/List/Start.remove_theme_font_override("font")

func _on_start_pressed():
	$M/Main/List/Start.disabled = true
	$M/Main/List/Settings.disabled = true
	$M/Main/List/Quit.disabled = true
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
