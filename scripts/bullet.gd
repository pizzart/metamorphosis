extends Area2D

enum BulletType {
	PLAYER,
	ENEMY,
}
var type: BulletType
var velocity: Vector2
var acceleration: float
var acceleration_accel: float = 0

func _physics_process(delta):
	position += velocity
	rotation = velocity.angle()
	velocity = velocity.limit_length(velocity.length() - acceleration)
	acceleration -= acceleration_accel
	if velocity.length() <= 0.01:
		queue_free()

func set_by_player():
	type = BulletType.PLAYER
	set_collision_mask_value(2, true)

func set_by_enemy():
	type = BulletType.ENEMY
	set_collision_mask_value(1, true)

func _on_body_entered(body):
	# reads mask layer 2: enemy
	if type == BulletType.PLAYER and body.is_in_group("enemy"):
		body.hit(1)
	if type == BulletType.ENEMY and body.is_in_group("player"):
		body.hit(1)
	queue_free()
