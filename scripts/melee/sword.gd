class_name Sword
extends Melee

const NAME = "SWORD"
const TEXTURE = preload("res://sprites/weapons/sword.png")
const TIMEOUT_BIG = 1
const TIMEOUT_SMALL = 0.4
const TIMEOUT_COMBO = 0.6

var combo_counter: int = 0
var combo_lost_timer = Timer.new()

func _init():
	super._init(TIMEOUT_BIG, 1, 500, TEXTURE, NAME)
	combo_lost_timer.wait_time = TIMEOUT_COMBO
	combo_lost_timer.timeout.connect(_on_combo_lost)
	combo_lost_timer.one_shot = true
	add_child(combo_lost_timer)

func _process(delta):
	super._process(delta)
	if not is_equipped:
		combo_counter = 0

func attack():
	can_attack = false
	combo_counter += 1
	player.speed_multiplier = 0.05
	audio.play()
#	player.cam.add_trauma(0.05)
	
	if combo_counter <= 2:
		timer.start(TIMEOUT_SMALL)
	else:
		combo_counter = 0
		timer.start(recharge_speed)
		delayed_reset_speed()
	combo_lost_timer.start(recharge_speed)
	
	var proj = SwordSwing.new(can_deflect)
	proj.global_rotation = sprite.global_rotation
	proj.hit.connect(_on_projectile_hit)
	add_child(proj)
	player.knockback(direction * knockback)
	
	offset_position = OFFSET_ATTACK
	swing_sprite()

func delayed_reset_speed():
	await get_tree().create_timer(TIMEOUT_SMALL).timeout
	player.speed_multiplier = 1

func _on_combo_lost():
	combo_counter = 0
	timer.start(recharge_speed)
