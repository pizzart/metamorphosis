extends Area2D

var player: Player
var can_buy: bool
var cost: int

func _input(event):
	if event.is_action_pressed("use") and can_buy:
		if player.coins >= cost:
			player.coins -= cost

func _on_body_entered(body):
	player = body
	can_buy = true

func _on_body_exited(_body):
	can_buy = false
