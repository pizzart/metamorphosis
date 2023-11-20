class_name Pickup
extends Interactable

const LIGHT = preload("res://scenes/pickup_light.tscn")
var sprite = Sprite2D.new()

func _init(shape: Shape2D, texture: Texture2D):
	super._init()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	sprite.texture = texture
	add_child(collision_shape)
	add_child(sprite)
	
	sprite.add_child(LIGHT.instantiate())

	add_to_group("pickup")
	
	z_index = -1
