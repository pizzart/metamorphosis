extends Node3D

const BOSS = preload("res://scenes/3d/boss.tscn")
var stop: bool

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	UI.get_node("Control/M/Bars/Weight").hide()
	UI.get_node("Control/M/Bars/Ammo").hide()
	UI.get_node("Control/M/Bars/Health/Bar/Buffer").hide()
	UI.transition_out()
	RenderingServer.global_shader_parameter_set("vignette_opacity", Global.VIGNETTE_OPACITY)
	PauseMenu.can_show = true

func _process(delta):
	Global.timer += delta
	UI.set_time(Global.timer)

func _physics_process(_delta):
	if not stop and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_boss_killed():
#	$NextArea.monitoring = true
#	$NextArea/Light.show()
	UI.transition_in(5)
	var tween = create_tween()
	tween.tween_property($Music, "volume_db", -80, 5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(5).timeout
	stop = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	UI.get_node("Control/M/Bars/Weight").show()
	UI.get_node("Control/M/Bars/Ammo").show()
	UI.get_node("Control/M/Bars/Health/Bar/Buffer").show()
	Global.after_boss = true
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_next_area_body_entered(body):
	stop = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	UI.get_node("Control/M/Bars/Weight").show()
	UI.get_node("Control/M/Bars/Health/Bar/Buffer").show()
	Global.after_boss = true
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_boss_damaged():
	$CanvasLayer2/M/BossBar.value = $Boss.health

func _on_deathzone_body_entered(body):
	body.global_position = $RespawnPoint.global_position

func _on_anim_animation_finished():
	var boss = BOSS.instantiate()
	boss.global_position = $BossSpawn.global_position
	boss.damaged.connect(_on_boss_damaged)
	boss.killed.connect(_on_boss_killed)
	add_child(boss)
	$Anim.hide()

func _on_player_hit_floor():
	$Player.hit_floor.disconnect(_on_player_hit_floor)
	$Player.can_move = true
#	await get_tree().create_timer(4).timeout
	for i in range(3):
		$BellSFX.play()
		await get_tree().create_timer(5).timeout
	$ScareSFX.play()
	$Anim.play("default")
	$Music.play()

func _on_anim_frame_changed():
	pass
#	if $Anim.frame == 2 or $Anim.frame == 6 or $Anim.frame == 12:
#		$BellSFX.play()
#	if $Anim.frame == 13:
#		$ScareSFX.play()
