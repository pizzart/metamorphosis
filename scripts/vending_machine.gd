extends Interactable

var cost: int = 1
var time: float

func _input(event):
	if event.is_action_pressed("use") and can_interact:
		if player.coins >= cost:
			player.spend_coins(cost)
			
			var new_pickup
			if Global.rng.randf() >= 0.35:
				var types = Global.weapon_pool.keys()
				var type = types.pick_random()
				var weapon = Global.weapon_pool[type].pick_random().new()
				new_pickup = Box.new(weapon)
			else:
				new_pickup = HealthPickup.new()
			new_pickup.global_position = player.global_position + global_position.direction_to(player.global_position) * 20
			get_parent().add_child(new_pickup)
			
			player.hide_coins()
			can_interact = false
		else:
			$Beep.play()
			player.shake_coins()
			player.change_emotion(Player.Emotion.Warning)

func _on_body_entered(body):
	super._on_body_entered(body)
	player.show_coins(cost)

func _on_body_exited(_body):
	super._on_body_exited(_body)
	player.hide_coins()
	player.change_emotion(Player.Emotion.None)

func unfocus():
	super.unfocus()
	player.hide_coins()
