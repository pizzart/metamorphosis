class_name CoinPickup
extends Pickup

const FONT = preload("res://misc/fontreadable.png")
const WAIT_TIME = 0.5
const LINE_LENGTH = 8

var time: float

func _init():
	var rect = RectangleShape2D.new()
	rect.size = Vector2(18, 18)
	super._init(rect, preload("res://sprites/health.png"))

func _process(delta):
	if Input.is_action_just_pressed("use"):
		if player != null:
			player.can_move = false
	if Input.is_action_pressed("use") and can_pick_up:
		time += delta
		queue_redraw()
		if time >= WAIT_TIME:
			if player != null:
				player.can_move = true
			player.add_coin()
			queue_free()
	if not Input.is_action_pressed("use"):
		time = maxf(time - delta, 0)
		queue_redraw()
	if Input.is_action_just_released("use"):
		if player != null:
			player.can_move = true

func _draw():
	if can_pick_up:
		draw_string(FONT, Vector2(-2, -16), "E")
		draw_line(Vector2(-LINE_LENGTH, -22), Vector2(time / WAIT_TIME * LINE_LENGTH * 2 - LINE_LENGTH, -22), Color.LIGHT_GREEN, 2)

func _on_body_entered(body):
	super._on_body_entered(body)
	queue_redraw()

func _on_body_exited(body):
	super._on_body_exited(body)
	queue_redraw()
