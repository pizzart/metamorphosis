class_name Teleporter
extends Area2D

const TIMEOUT = 5
var next_position: Vector2
var inside: bool
var can_interact: bool = true
var player: Player

func _init(_next_position):
	var collision_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(40, 40)
	collision_shape.shape = rect
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	sprite.modulate = Color.RED
	sprite.scale = Vector2(0.3, 0.3)
	add_child(collision_shape)
	add_child(sprite)
	z_index = -1
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("teleporter")
	
	next_position = _next_position

func _input(event):
	if event.is_action_pressed("use") and inside and can_interact:
		player.global_position = next_position
		get_tree().call_group("teleporter", "make_inactive")

func make_inactive():
	can_interact = false
	await get_tree().create_timer(TIMEOUT).timeout
	can_interact = true

func _on_body_entered(body):
	player = body
	inside = true

func _on_body_exited(body):
	inside = false