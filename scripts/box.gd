class_name Box
extends Interactable

var sprite = Sprite2D.new()
var item: Weapon

func _init(_item):
	super._init()
	item = _item
	
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 36)
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = rect
	
	if item is Gun:
		sprite.texture = preload("res://sprites/props/box_gun.png")
	else:
		sprite.texture = preload("res://sprites/props/box_melee.png")
	
	add_child(sprite)
	add_child(collision_shape)
	
	set_collision_layer_value(6, true)
	set_collision_mask_value(6, true)

func _process(delta):
	if not get_overlapping_areas().is_empty():
		for area in get_overlapping_areas():
			position += (global_position - area.global_position).limit_length() * delta * 100

func _input(event):
	if event.is_action_pressed("use") and can_interact:
		var pickup = WeaponPickup.new(item.weapon_name, item)
		pickup.global_position = global_position
		get_parent().add_child(pickup)
		queue_free()

#func _on_body_entered(body):
#	super._on_body_entered(body)
#	modulate = Color(2, 2, 2)

#func unfocus():
#	can_interact = false
#	modulate = Color.WHITE
