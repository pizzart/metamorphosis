extends CharacterBody2D

const BULLET = preload("res://scenes/bullet.tscn")
const SPEED = 150.0
const SHOOT_TIMEOUT = 0.2
var hand_position: Vector2
var can_shoot: bool = true
@onready var cam = $Camera

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED

	move_and_slide()

func _process(delta):
	cam.offset = (get_global_mouse_position() - global_position) / 4
	hand_position = (get_global_mouse_position() - global_position).limit_length(20)
	$HandSprite.position = hand_position

func _input(event):
	if event.is_action_pressed("attack") and can_shoot:
		var bullet = BULLET.instantiate()
		bullet.velocity = global_position.direction_to(get_global_mouse_position()) * 15
		bullet.acceleration = -0.01
		bullet.global_position = to_global(hand_position)
		bullet.set_by_player()
		get_parent().add_child(bullet)
		
		can_shoot = false
		$ShootTimer.start(SHOOT_TIMEOUT)

func _on_shoot_timer_timeout():
	can_shoot = true
