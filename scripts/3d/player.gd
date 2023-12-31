extends CharacterBody3D

signal hit_floor
const MAX_HEALTH = 15

const ACCEL = 1.3
const AIR_ACCEL = 1.0
const MAX_VELOCITY = 7.0
const MAX_AIR_VELOCITY = 6.0
const FRICTION = 0.1

const JUMP_VELOCITY = 4.5
const TILT_AMOUNT = 0.07

var health: int = MAX_HEALTH
var jump_buffered: bool
var was_on_floor: bool
var can_move: bool = false
var can_shoot: bool = true
var shake: float

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $Camera3D

func _ready():
	UI.get_node("Control/M/Bars/Health/Bar").value = health
	UI.get_node("Control/M/Bars/Health/Bar").max_value = MAX_HEALTH
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

	var direction = Vector3.ZERO
	var input_dir = Vector2.ZERO
	if can_move:
		input_dir = Input.get_vector("left", "right", "up", "down")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var prev_velocity = velocity
	var new_velo
	if is_on_floor():
		hit_floor.emit()
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
	
	if (velocity * Vector3(1, 0, 1)).length_squared() < 2:
		get_parent().get_node("CanvasLayer2/Sprite").pause()
		$StepTimer.paused = true
	else:
		get_parent().get_node("CanvasLayer2/Sprite").play()
		if not is_on_floor() and was_on_floor:
			$StepSFX.play()
		$StepTimer.paused = not is_on_floor()
	
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
	
	was_on_floor = is_on_floor()

func _process(delta):
	$Camera3D.h_offset = Global.rng.randf_range(-shake, shake)
	$Camera3D.v_offset = Global.rng.randf_range(-shake, shake)
	shake = maxf(shake - delta, 0)

func accelerate(direction: Vector3, prev_velocity: Vector3, acceleration: float, max_velocity: float):
	var proj_velocity = velocity.dot(direction)
	var accel_vel = acceleration
	if proj_velocity + accel_vel > max_velocity:
		accel_vel = max_velocity - proj_velocity
	return prev_velocity + direction * accel_vel

func damage(amount: int):
	health -= amount
	if health <= 0:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://scenes/pre_ui.tscn")
	UI.get_node("Control/M/Bars/Health/Bar").value = health
	$HitSFX.play()

func shake_cam(amount: float):
	shake += amount

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * Global.mouse_sens
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * Global.mouse_sens, -PI / 2, PI / 2)
	if event.is_action_pressed("attack"):
		if can_shoot:
			if $Camera3D/Ray.is_colliding():
				var col = $Camera3D/Ray.get_collider()
				col.damage(1)
			
			$Camera3D/Revolver/AnimationPlayer.stop()
			$Camera3D/Revolver/AnimationPlayer.play("shoot")
			$ShootSFX.play()
			
			can_shoot = false
			$ShootTimer.start()

func _on_step_timer_timeout():
	$StepSFX.play()

func _on_shoot_timeout():
	can_shoot = true
