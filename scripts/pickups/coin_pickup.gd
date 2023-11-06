class_name CoinPickup
extends Pickup

const FONT = preload("res://misc/font.png")

func _init():
	var rect = RectangleShape2D.new()
	rect.size = Vector2(18, 18)
	super._init(rect, preload("res://sprites/health.png"))

func _draw():
	if can_pick_up:
		draw_string(FONT, Vector2(24, 0), "E")

func _on_body_entered(body):
	player = body
	can_pick_up = true
	queue_redraw()

func _on_body_exited(_body):
	can_pick_up = false
	queue_redraw()

func _input(event):
	if event.is_action_pressed("use") and can_pick_up:
		player.add_coin()
		queue_free()
