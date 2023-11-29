class_name Sledgehammer
extends Melee

const NAME = "HAMMER"
const TEXTURE = preload("res://sprites/weapons/sledgehammer.png")

func _init():
	super._init(1.0, 2, 1000, TEXTURE, NAME)
	audio.pitch_scale = 0.8

func attack():
	super.attack()
	player.speed_multiplier = 0.2
	player.cam.add_trauma(0.05)
	
	var proj = HammerSwing.new(can_deflect)
	proj.global_rotation = sprite.global_rotation
	proj.hit.connect(_on_projectile_hit)
	add_child(proj)
	player.knockback(direction * knockback)
	
	offset_position = OFFSET_ATTACK
	swing_sprite()
