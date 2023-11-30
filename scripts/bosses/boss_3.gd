class_name Boss3
extends Foe

const SPEED = 40.0
const PARTICLES = preload("res://scenes/particles/hit_enemy_particles.tscn")

@onready var attack_timer = $Timer

func _init():
	super._init()
	health = 20

func _ready():
	sprite = $Sprite2D

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED

	move_and_slide()

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
	
#	hit_audio.play()
	
	attack_timer.paused = true
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	attack_timer.paused = false
	sprite.modulate = Color.WHITE

func die():
	super.die()
	queue_free()

func _on_timer_timeout():
	var time = rng.randf_range(3, 5)
	attack_timer.start(time)
	
	global_position = player.global_position + [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].pick_random() * 32
	
#	sprite.animation = "attack"
	await get_tree().create_timer(0.5).timeout
	
	for j in range(2):
#		shoot_audio.play()
		for i in range(15):
			var bullet = Bullet.new(global_position.direction_to(player.global_position).rotated((float(i) / 14 - 0.5) * 3 + rng.randf_range(-0.2, 0.2)) * 6, -0.05, false)
			bullet.global_position = global_position
			get_parent().add_child(bullet)
			await get_tree().create_timer(0.007).timeout
		await get_tree().create_timer(0.3).timeout
	
	await get_tree().create_timer(0.1).timeout
