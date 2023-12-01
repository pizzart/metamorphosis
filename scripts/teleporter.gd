class_name Teleporter
extends Area2D

const ARROW = preload("res://sprites/arrow.png")
const TIMEOUT = 1.8
const WAIT_TIME = 0.25
var next_position: Vector2
var inside: bool
var can_interact: bool = true
var timer: float
var player: Player

func _init(_position, _next_position):
	var collision_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(40, 40)
	collision_shape.shape = rect
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://sprites/props/teleporter.png")
	var arrow_sprite = Sprite2D.new()
	var direction = _position.direction_to(_next_position)
	arrow_sprite.texture = ARROW
#	arrow_sprite.position = direction * 25
	arrow_sprite.rotation = direction.angle()
	arrow_sprite.z_index = 1
	add_child(collision_shape)
	add_child(sprite)
	add_child(arrow_sprite)
	z_index = -2
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("teleporter")
	
	next_position = _next_position
	global_position = _position

func _process(delta):
	if inside:
		if Input.is_action_pressed("use") and can_interact:
				timer += delta
				UI.set_progress(timer / WAIT_TIME)
				if timer >= WAIT_TIME:
					timer = 0
					player.global_position = next_position
					get_tree().call_group("teleporter", "make_inactive")
					player.invincible = true
					await get_tree().create_timer(0.4)
					player.invincible = false
		else:
			timer = 0
			UI.set_progress(timer / WAIT_TIME)

func make_inactive():
	can_interact = false
	modulate = Color.GRAY
	await get_tree().create_timer(TIMEOUT).timeout
	can_interact = true
	if inside:
		UI.show_help()
	modulate = Color.WHITE

func _on_body_entered(body):
	player = body
	inside = true
	UI.show_help()

func _on_body_exited(_body):
	inside = false
	UI.hide_help()
