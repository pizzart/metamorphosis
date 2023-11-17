extends Node3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_boss_killed():
	$NextArea.monitoring = true
	$NextArea/Light.show()

func _on_next_area_body_entered(body):
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_boss_damaged():
	$CanvasLayer2/M/BossBar.value = $Boss.health
