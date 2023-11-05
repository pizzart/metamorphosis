extends Area2D

var can_pick_up: bool
var pickup_name: String
var item: Gun
var player: Player

func _ready():
	$Name.text = pickup_name
#	$Sprite2D.texture = item.sprite.texture

func init_properties(pos, n, i):
	global_position = pos
	pickup_name = n
	item = i

func _on_body_entered(body):
	player = body
	can_pick_up = true
	$Name.show()

func _on_body_exited(_body):
	can_pick_up = false
	$Name.hide()

func _input(event):
	if event.is_action_pressed("use") and can_pick_up:
		player.replace_gun(item)
		queue_free()
