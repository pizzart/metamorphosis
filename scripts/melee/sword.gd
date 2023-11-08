class_name Sword
extends Weapon

const NAME = "SWORD"
const TEXTURE = preload("res://sprites/weapon/sword.png")
const TIMEOUT_BIG = 1
const TIMEOUT_SMALL = 0.4
const TIMEOUT_COMBO = 0.6
const OFFSET_ATTACK = 40

var combo_counter: int = 0
var combo_lost_timer = Timer.new()

func _init():
	super._init(TIMEOUT_BIG, 1, 800, TEXTURE, NAME)
	combo_lost_timer.wait_time = TIMEOUT_COMBO
	combo_lost_timer.timeout.connect(_on_combo_lost)
	combo_lost_timer.one_shot = true
	add_child(combo_lost_timer)

func attack():
	can_attack = false
	combo_counter += 1
	
	if combo_counter <= 2:
		timer.start(TIMEOUT_SMALL)
	else:
		combo_counter = 0
		timer.start(recharge_speed)
	combo_lost_timer.start(recharge_speed)
	
	var projectile = SwordSwipe.new()
	projectile.global_rotation = sprite.global_rotation
	projectile.body_entered.connect(_on_projectile_hit)
	add_child(projectile)
	player.knockback(player.global_position.direction_to(get_global_mouse_position()) * knockback / 2)
	player.speed_multiplier = 0.2
	
	offset_position = OFFSET_ATTACK
	swing_sprite()

func swing_sprite():
	var tween = create_tween()
	offset_rotation = PI / 3
	tween.tween_property(self, "offset_rotation", -PI / 3, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_rotation", 0, 0.3).set_trans(Tween.TRANS_CUBIC)

func _on_timer_timeout():
	super._on_timer_timeout()
	player.speed_multiplier = 1
#	player.knockback(-player.global_position.direction_to(get_global_mouse_position()) * knockback / 5)

func _on_combo_lost():
	combo_counter = 0
	timer.start(recharge_speed)

func _on_projectile_hit(body):
	player.knockback(-player.global_position.direction_to(body.global_position) * knockback / 4)
	player.add_ammo(10)