class_name SimplePickup
extends Pickup

var time: float

func _input(event):
	if event.is_action_pressed("use") and can_interact:
		set_deferred("monitoring", false)
		can_interact = false
		interact()
		var tween = create_tween().set_parallel()
		tween.tween_property(sprite, "scale", Vector2(0, 10), 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "position", Vector2(0, -150), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		await tween.finished
		queue_free()

func _process(delta):
	time += delta
	sprite.position.y = sin(time) * 5

func interact():
	pass
