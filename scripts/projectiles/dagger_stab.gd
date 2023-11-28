class_name DaggerStab
extends Swing

func _init():
	super._init(1, false)
	collision_shape.shape.size = Vector2(64, 32)
	timer.wait_time = 0.25
	sprite.sprite_frames = preload("res://resources/stab.tres")
	sprite.play("default")
