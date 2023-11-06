extends Window

var camera: Camera2D

func _process(delta: float):
	if camera != null:
		position = camera.global_position
#	camera.position = get_camera_pos_from_window()
