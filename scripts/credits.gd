extends Control

func _ready():
	UI.transition_out(3)
	await get_tree().process_frame
	$VBoxContainer.set_position(Vector2(0, 220))

func _process(delta):
	$VBoxContainer.position.y = maxf($VBoxContainer.position.y - delta * 5, 0)
