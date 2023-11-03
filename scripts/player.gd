extends CharacterBody2D

const HEALTH_TO_WEIGHT = 100
const SHOOT_TIMEOUT = 0.2
var speed = 100
var max_health: int = 10
var health: int = max_health
var weight: int = 0
var speed_multiplier: float = 1

@onready var cam = $Camera
@onready var gun = $Gun

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed * speed_multiplier
	if direction.y > 0:
		$Sprite.animation = "front"
	if direction.y < 0:
		$Sprite.animation = "back"
	if direction.x > 0:
		$Sprite.animation = "side"
		$Sprite.flip_h = true
	if direction.x < 0:
		$Sprite.animation = "side"
		$Sprite.flip_h = false
	
	move_and_slide()
	
func _process(delta):
	var offset = get_global_mouse_position() - global_position
	cam.offset = offset / 4
	gun.position = offset.limit_length(20)
	weight = gun.weight
	UI.get_node("Control/MarginContainer/Label").text = "%s/%s" % [weight, health * HEALTH_TO_WEIGHT]
	if weight > health * HEALTH_TO_WEIGHT:
		speed_multiplier = 0.5
	else:
		speed_multiplier = 1

func _input(event):
	if event.is_action_pressed("change_gun"):
		gun.queue_free()
		gun = Rifle.new()
		add_child(gun)
		add_child(SpeedUpgrade.new())

func hit(damage: int):
	health -= damage
