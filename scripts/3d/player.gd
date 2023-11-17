extends CharacterBody3D

const MAX_HEALTH = 15

const ACCEL = 1.3
const AIR_ACCEL = 1.0
const MAX_VELOCITY = 7.0
const MAX_AIR_VELOCITY = 6.0
const FRICTION = 0.1

const JUMP_VELOCITY = 4.5
const MOUSE_ACCEL = 0.003
const TILT_AMOUNT = 0.07

var health: int = MAX_HEALTH
var jump_buffered: bool

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $Camera3D

func _ready():
	UI.get_node("Control/M/V/HealthBar").value = health
	UI.get_node("Control/M/V/HealthBar").max_value = MAX_HEALTH
	
	UI.get_node("Control/M/V/WeightBar").hide()
#	UI.get_node("Control/M/V/AmmoBar").value = ammo
#	UI.get_node("Control/M/V/AmmoBar").max_value = max_ammo

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		if Input.is_action_just_pressed("jump"):
			jump_buffered = true
	elif jump_buffered or Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		jump_buffered = false
	
	if Input.is_action_just_released("jump"):
		jump_buffered = false

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var prev_velocity = velocity
	var new_velo
	if is_on_floor():
		var speed = prev_velocity.length()
		if speed != 0:
			var drop = speed * FRICTION
			prev_velocity *= max(speed - drop, 0) / speed
		new_velo = accelerate(direction, prev_velocity, ACCEL, MAX_VELOCITY)
	else:
		new_velo = accelerate(direction, prev_velocity, AIR_ACCEL, MAX_AIR_VELOCITY)
	
	velocity.x = new_velo.x
	velocity.z = new_velo.z

	move_and_slide()
	
	if velocity.length_squared() < 2:
		get_parent().get_node("CanvasLayer2/Sprite").pause()
	else:
		get_parent().get_node("CanvasLayer2/Sprite").play()
	
	if velocity.length() > 25:
		get_parent().get_node("CanvasLayer2/Sprite").speed_scale = 3
	elif velocity.length() > 15:
		get_parent().get_node("CanvasLayer2/Sprite").speed_scale = 2
	else:
		get_parent().get_node("CanvasLayer2/Sprite").speed_scale = 1
	
	if input_dir.y > 0:
		get_parent().get_node("CanvasLayer2/Sprite").animation = "front"
	if input_dir.y < 0:
		get_parent().get_node("CanvasLayer2/Sprite").animation = "back"
	
	camera.rotation.z = lerpf(camera.rotation.z, -input_dir.x * TILT_AMOUNT, 0.1)
	camera.fov = lerpf(camera.fov, 60 * clampf(velocity.length() / MAX_VELOCITY / 3 + 1, 1, 2), 0.05)

func accelerate(direction: Vector3, prev_velocity: Vector3, acceleration: float, max_velocity: float):
	var proj_velocity = velocity.dot(direction)
	var accel_vel = acceleration
	if proj_velocity + accel_vel > max_velocity:
		accel_vel = max_velocity - proj_velocity
	return prev_velocity + direction * accel_vel

func damage(amount: int):
	health -= amount
	if health <= 0:
		get_tree().reload_current_scene()
	UI.get_node("Control/M/V/HealthBar").value = health

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * MOUSE_ACCEL
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * MOUSE_ACCEL, -PI / 2, PI / 2)
	if event.is_action_pressed("attack"):
		if $Camera3D/Ray.is_colliding():
			var col = $Camera3D/Ray.get_collider()
			col.damage(1)
		
		$Camera3D/Revolver/AnimationPlayer.stop()
		$Camera3D/Revolver/AnimationPlayer.play("shoot")
