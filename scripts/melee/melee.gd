class_name Melee
extends Weapon

const SWIPE_PARTICLES = preload("res://scenes/particles/swipe_particles.tscn")
const OFFSET_ATTACK = 40

var buffered: bool
var can_deflect: bool = false
var swipe_particles: CPUParticles2D

func _init(_recharge_speed: float, _weight: int, _knockback: float, _texture: Texture2D, _weapon_name: String):
	super._init(_recharge_speed, _weight, _knockback, _texture, _weapon_name)
	
	swipe_particles = SWIPE_PARTICLES.instantiate()
	sprite.add_child(swipe_particles)
	var stream = AudioStreamRandomizer.new()
	stream.add_stream(0, preload("res://audio/sfx/swoop.wav"))
	audio.stream = stream

func _process(delta):
	super._process(delta)
	if buffered and can_attack_fr():
		attack()
		buffered = false

func _input(event):
	if event.is_action_pressed("attack"):
		buffered = true
	if event.is_action_released("attack"):
		buffered = false

func swing_sprite():
	swipe_particles.emitting = true
	var tween = create_tween()
	offset_rotation = PI / 3
	tween.tween_property(self, "offset_rotation", -PI / 3, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_rotation", 0, 0.3).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	swipe_particles.emitting = false

func _on_timer_timeout():
	super._on_timer_timeout()
	player.speed_multiplier = 1

func _on_projectile_hit(object):
	if object.is_in_group("foe"):
		player.knockback(-direction * knockback / 4)
		player.add_ammo(10)
		player.cam.add_trauma(0.2)
	if object.is_in_group("tree") or object is Box:
		player.add_ammo(5)
