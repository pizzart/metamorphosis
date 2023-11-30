class_name Swing
extends Projectile

signal hit(object)
var can_deflect: bool
var timer = Timer.new()
var sprite = AnimatedSprite2D.new()
var collision_shape = CollisionShape2D.new()

func _init(_damage: int, _can_deflect: bool):
	super._init()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(80, 64)
	collision_shape.shape = rect
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
	area_entered.connect(_on_area_entered)
	
	damage = _damage
	can_deflect = _can_deflect

func _on_body_entered(body):
	hit.emit(body)
	if body.is_in_group("foe"):
		body.hit(damage, get_parent().direction * 30)
		set_deferred("monitoring", false)
		audio.play()
	if body.is_in_group("tree"):
		body.hit()

func _on_area_entered(area):
	if area is Bullet and can_deflect:
		area.set_by_player()
		area.velocity = -area.velocity
	if area is Box:
		hit.emit(area)

func _on_timeout():
	queue_free()
