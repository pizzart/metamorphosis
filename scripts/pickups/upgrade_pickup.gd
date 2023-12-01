class_name UpgradePickup
extends Pickup

signal picked_up

func _init():
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	super._init(rect, preload("res://sprites/battery.png"))
	modulate = Color.RED

func _input(event):
	if event.is_action_pressed("use") and can_interact:
		player.add_upgrade(DashUpgrade.new())
		picked_up.emit()
		queue_free()
