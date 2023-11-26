extends StaticBody2D

func _process(delta):
	$Propeller.rotation += delta * (int(global_position.x + global_position.y) % 5 + 1) / 2
