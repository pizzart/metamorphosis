class_name Pickup
extends Area2D

var can_pick_up: bool
var player: Player

func _init(shape: Shape2D, texture: Texture2D):
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	var sprite = Sprite2D.new()
	sprite.texture = texture
	add_child(collision_shape)
	add_child(sprite)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	add_to_group("pickup")
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, true)
	z_index = -1

func _on_body_entered(_body):
	pass

func _on_body_exited(_body):
	pass
