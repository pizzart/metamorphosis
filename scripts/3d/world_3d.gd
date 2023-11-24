extends Node3D

var stop: bool

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	UI.get_node("Control/M/Bars/Weight").hide()
	UI.get_node("Control/M/Bars/Health/Bar/Buffer").hide()
	UI.transition_out()
	RenderingServer.global_shader_parameter_set("vignette_opacity", Global.VIGNETTE_OPACITY)

func _process(delta):
	Global.timer += delta

func _physics_process(_delta):
	if not stop and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_boss_killed():
	$NextArea.monitoring = true
	$NextArea/Light.show()

func _on_next_area_body_entered(body):
	stop = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	UI.get_node("Control/M/Bars/Weight").show()
	UI.get_node("Control/M/Bars/Health/Bar/Buffer").show()
	Global.after_boss = true
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_boss_damaged():
	$CanvasLayer2/M/BossBar.value = $Boss.health
