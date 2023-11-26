class_name Swing
extends Projectile

var timer = Timer.new()

func _init(_damage: int, can_deflect: bool):
	super._init()
	var collision_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(80, 64)
	collision_shape.shape = rect
	var sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = preload("res://resources/slash.tres")
	sprite.play("default")
	sprite.rotation = PI / 2
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
	set_collision_mask_value(3, true) # bullet
	set_collision_mask_value(6, true) # props
	
	timer.timeout.connect(_on_timeout)
	body_entered.connect(_on_body_entered)
	if can_deflect:
		area_entered.connect(_on_area_entered)
	
	damage = _damage

func _on_body_entered(body):
	if body.is_in_group("foe"):
		body.hit(damage, get_parent().direction * 30)
		set_deferred("monitoring", false)
		audio.play()

func _on_area_entered(area):
	if area is Bullet:
		area.set_by_player()
		area.velocity = -area.velocity

func _on_timeout():
	queue_free()
