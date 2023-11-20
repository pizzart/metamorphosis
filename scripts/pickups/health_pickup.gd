class_name HealthPickup
extends SimplePickup

func _init():
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	super._init(rect, preload("res://sprites/battery.png"))

func interact():
	player.add_health_pack()
