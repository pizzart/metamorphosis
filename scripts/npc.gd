extends Area2D

const FONT = preload("res://misc/font.png")
var lines = preload("res://resources/dialogues.tres")
var can_start: bool
var current_line: int = -1
var text: String
var visible_ratio: float
var player: Player

func _draw():
	draw_string(FONT, Vector2(2, -2), text.left(text.length() * visible_ratio))

func _process(delta):
	if current_line > -1:
		visible_ratio = clampf(visible_ratio + delta / text.length() * 20, 0, 1)
		queue_redraw()
#		$Text.visible_ratio += delta / $Text.text.length() * 20

func _input(event):
	if event.is_action_pressed("use") and (can_start or current_line > -1):
		current_line += 1
		if current_line >= lines.lines.size():
			current_line = -1
			player.can_move = true
			text = ""
			visible_ratio = 0
			queue_redraw()
			return
		
		player.can_move = false
		
		text = lines.lines[current_line].line.to_upper()
		visible_ratio = 0
		
#		$Text.text = lines.lines[current_line].line.to_upper()
#		$Text.visible_ratio = 0

func _on_body_entered(body):
	player = body
	can_start = true

func _on_body_exited(body):
	can_start = false
