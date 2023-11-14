class_name Melee
extends Weapon

const OFFSET_ATTACK = 40

var buffered: bool

func _init(_recharge_speed: float, _weight: int, _knockback: float, _texture: Texture2D, _weapon_name: String):
	super._init(_recharge_speed, _weight, _knockback, _texture, _weapon_name)

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
	var tween = create_tween()
	offset_rotation = PI / 3
	tween.tween_property(self, "offset_rotation", -PI / 3, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_rotation", 0, 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_timer_timeout():
	super._on_timer_timeout()
	player.speed_multiplier = 1

func _on_projectile_hit(body):
	player.knockback(-direction * knockback / 4)
	player.add_ammo(10)
	player.cam.add_trauma(0.2)
