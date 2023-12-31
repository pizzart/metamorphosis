class_name CoinPickup
extends SimplePickup

func _init():
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 32)
	super._init(rect, preload("res://sprites/currency.png"))

func interact():
	player.add_coin()
	super.interact()

func _process(delta):
	super._process(delta)
	if floori(time) % 8 == 0:
		sprite.scale.x = sin((time - floori(time) % 8) * -PI) * 2 + 1
