class_name CoinPickup
extends Pickup

const FONT = preload("res://misc/fontreadable.png")

func _init():
	var rect = RectangleShape2D.new()
	rect.size = Vector2(18, 18)
	super._init(rect, preload("res://sprites/currency.png"))

func _draw():
	if can_interact:
		draw_string(FONT, Vector2(-2, -16), "E")

func _input(event):
	if event.is_action_pressed("use"):
		player.add_coin()
		queue_free()

func _on_body_entered(body):
	super._on_body_entered(body)
	queue_redraw()

func unfocus():
	super.unfocus()
	queue_redraw()
