extends CharacterBody3D

signal damaged
signal killed

const BULLET = preload("res://scenes/3d/bullet.tscn")

const SPEED = 8.0

var health: int = 30
var override_velocity: Vector3
var was_on_wall: bool

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player = get_tree().get_first_node_in_group("player_3d")

func _ready():
	$FloorParticles.restart()

func _physics_process(delta):
#	if not is_on_floor():
#		velocity.y -= gravity * delta

	if Global.rng.randf() <= 0.005 and not $Talk1SFX.playing:
		$Talk1SFX.play()
	
	if override_velocity:
		velocity = override_velocity
	else:
		var direction = position.direction_to(player.position + Vector3(0, 8, 0))
		velocity = lerp(velocity, direction * SPEED, 0.1)

	move_and_slide()
	
	if is_on_wall():
		if not was_on_wall:
			$FloorParticles.restart()
			if player.is_on_floor():
				player.velocity.y = 12
			if global_position.distance_to(player.global_position) < 25:
				var velo = (player.global_position - global_position).limit_length() * (10 - (player.global_position - global_position).limit_length(10).length())
				if player.is_on_floor():
					velo *= Vector3(1, 0, 1)
				player.velocity += velo
			player.shake_cam(0.2)
	was_on_wall = is_on_wall()

func damage(dmg: int):
	health -= dmg
	damaged.emit()
	if health <= 0:
		killed.emit()
		var sfx = $DeathSFX
		remove_child(sfx)
		get_parent().add_child(sfx)
		sfx.global_position = global_position
		sfx.play()
		queue_free()
	$HitSFX.play()

func attack_1():
	for i in range(3):
		var bullet = BULLET.instantiate()
		bullet.velocity = global_position.direction_to(player.global_position) * 0.6
		bullet.acceleration = -global_position.direction_to(player.global_position) * 0.001
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		$ShootSFX.play()
		await get_tree().create_timer(0.08).timeout
	$AttackTimer.start(0.8)

func attack_2():
	$Area.set_deferred("monitoring", true)
	var tween = create_tween()
	tween.tween_property(self, "override_velocity", Vector3.DOWN * 100, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	override_velocity = Vector3.UP * SPEED
	await get_tree().create_timer(0.15).timeout
	$Area.set_deferred("monitoring", false)
	override_velocity = Vector3.ZERO
	$AttackTimer.start(1.2)

func _on_attack_timer_timeout():
	if ((global_position - player.global_position) * Vector3(1, 0, 1)).length() < 8:
		attack_2()
	else:
		attack_1()

func _on_area_body_entered(body):
	body.damage(3)
