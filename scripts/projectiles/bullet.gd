class_name Bullet
extends Projectile

enum BulletType {
	PLAYER,
	ENEMY,
}
var type: BulletType
var velocity: Vector2
var acceleration: float

var sprite = Sprite2D.new()

func _init(_velocity: Vector2, _acceleration: float, is_player: bool):
	super._init()
	var collision_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 12)
	collision_shape.shape = rect
	sprite.texture = preload("res://sprites/bullet.png")
	add_child(collision_shape)
	add_child(sprite)
	
	damage = 1
	
	velocity = _velocity
	acceleration = _acceleration
	if is_player:
		set_by_player()
	else:
		set_by_enemy()
	set_collision_layer_value(3, true)
	set_collision_mask_value(5, true)
	
	body_entered.connect(_on_body_entered)

func _physics_process(_delta):
	position += velocity
	rotation = velocity.angle()
	velocity = velocity.limit_length(velocity.length() + acceleration)
#	acceleration -= acceleration_accel
	if velocity.length() <= 1:
		queue_free()

func set_by_player():
	type = BulletType.PLAYER
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	sprite.material = preload("res://misc/outline_mat_player.tres")

func set_by_enemy():
	type = BulletType.ENEMY
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)
	sprite.material = preload("res://misc/outline_mat_enemy.tres")

func _on_body_entered(body):
	# reads mask layer 2: enemy
	if type == BulletType.PLAYER and body.is_in_group("foe"):
		body.hit(damage, velocity.normalized() * 70)
	if type == BulletType.ENEMY and body.is_in_group("player"):
		body.hit(damage, global_position.direction_to(body.global_position))
	await get_tree().physics_frame
	if has_overlapping_bodies():
		set_deferred("monitoring", false)
		audio.play()
		hide()
		await audio.finished
		queue_free()
