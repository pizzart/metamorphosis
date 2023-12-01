class_name Boss0
extends Foe

const SPEED = 50.0
const PARTICLES = preload("res://scenes/particles/hit_enemy_particles.tscn")

@onready var hit_audio = $HitSFX
@onready var shoot_audio = $ShootSFX
@onready var death_audio = $DeathSFX
@onready var attack_timer = $Timer

func _init():
	super._init()
	health = 20

func _ready():
	sprite = $AnimatedSprite2D
	sprite.play("attack")

func hit(damage: int, force: Vector2):
	health -= damage
	if health <= 0:
		die()
	
	velocity += force * 2
	
	var particles = PARTICLES.instantiate()
	particles.global_position = global_position
	particles.rotation = force.angle()
	particles.emitting = true
	get_parent().add_child(particles)
	
	hit_audio.play()
	
	attack_timer.paused = true
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	attack_timer.paused = false
	sprite.modulate = Color.WHITE

func die():
	super.die()
	queue_free()

func _on_timer_timeout():
	var time = rng.randf_range(2, 4)
	attack_timer.start(time)
	
#	sprite.animation = "attack"
	$PrepSFX.play()
	await get_tree().create_timer(0.7).timeout
	
	sprite.play("attack")
	for j in range(2):
		shoot_audio.play()
		for i in range(15):
			var bullet = Bullet.new(global_position.direction_to(player.global_position).rotated((float(i) / 14 - 0.5) * 3 + rng.randf_range(-0.2, 0.2)) * 6, -0.05, false)
			bullet.global_position = global_position
			get_parent().add_child(bullet)
			await get_tree().create_timer(0.007).timeout
		await get_tree().create_timer(0.3).timeout
	
	await get_tree().create_timer(0.1).timeout
#	sprite.animation = "idle"
