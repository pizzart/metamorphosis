class_name Pickup
extends Interactable

var sprite = Sprite2D.new()

func _init(shape: Shape2D, texture: Texture2D):
	super._init()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	sprite.texture = texture
	add_child(collision_shape)
	add_child(sprite)

	add_to_group("pickup")
	
	z_index = -1
