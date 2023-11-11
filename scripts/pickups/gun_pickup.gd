class_name GunPickup
extends Pickup

const FONT = preload("res://misc/font.png")
var pickup_name: String
var item: Gun

func _init(_pickup_name: String, _item: Gun):
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	super._init(rect, _item.texture)
	pickup_name = _pickup_name
	item = _item

func _draw():
	if can_pick_up:
		draw_string(FONT, Vector2(-pickup_name.length() * 4, -24), pickup_name)

func _on_body_entered(body):
	super._on_body_entered(body)
	queue_redraw()

func _on_body_exited(body):
	super._on_body_exited(body)
	queue_redraw()

func _input(event):
	if event.is_action_pressed("use") and can_pick_up:
		if player.is_less_gun_weight(item.weight):
			var gun = player.replace_gun(item)
			var new_pickup = GunPickup.new(gun.weapon_name, gun)
			new_pickup.global_position = player.global_position
			get_parent().add_child(new_pickup)
			queue_free()
