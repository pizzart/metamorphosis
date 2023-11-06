class_name SwordSwipe
extends Projectile

var timer = Timer.new()

func _init():
	var collision_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(48, 48)
	collision_shape.shape = rect
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://sprites/bullet.png")
	timer.wait_time = 0.39
	timer.autostart = true
	add_child(collision_shape)
	add_child(sprite)
	add_child(timer)
	
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, false) # enemy
	set_collision_mask_value(2, true) # enemy
	set_collision_mask_value(5, true) # wall
	
	damage = 1
	
	timer.timeout.connect(_on_timeout)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# reads mask layer 2: enemy
	if body.is_in_group("enemy"):
		body.hit(damage)
		queue_free()

func _on_timeout():
	queue_free()
