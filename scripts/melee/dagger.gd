class_name Dagger
extends Melee

const NAME = "DAGGER"
const TEXTURE = preload("res://sprites/weapons/dagger.png")

func _init():
	super._init(0.4, 1, 400, TEXTURE, NAME)
	audio.pitch_scale = 1.1

func attack():
	super.attack()
	player.speed_multiplier = 0.6
#	player.cam.add_trauma(0.05)
	
	var proj = DaggerStab.new()
	proj.global_rotation = sprite.global_rotation
	proj.body_entered.connect(_on_projectile_hit)
	add_child(proj)
	player.knockback(direction * knockback)
	
	offset_position = OFFSET_ATTACK
#	swing_sprite()

func swing_sprite():
	swipe_particles.emitting = true
	var tween = create_tween()
	offset_rotation = PI / 3
	tween.tween_property(self, "offset_rotation", -PI / 3, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_rotation", 0, 0.3).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	swipe_particles.emitting = false
