class_name DialogueBox
extends Node2D

const FONT = preload("res://misc/font.png")
const LINE_WIDTH = 12
const CHARACTER_SIZE = 8
var text: String
var current_line: int = -1
var visible_ratio: float

func _init():
	z_index = 4

func _process(delta):
	if current_line > -1 and visible_ratio < 1:
		visible_ratio = clampf(visible_ratio + delta / text.length() * 20, 0, 1)
		queue_redraw()

func _draw():
	var drawn_lines = []
	var last_i = -1
	for i in range(text.length()):
		if (text[i] == " " and i >= LINE_WIDTH) or (text[i] == "\n") or (i == text.length() - 1):
			if i != text.length() - 1:
				drawn_lines.append(text.substr(last_i + 1, i - last_i - 1))
			else:
				drawn_lines.append(text.substr(last_i + 1, i - last_i + 1))
			last_i = i
	for i in range(drawn_lines.size()):
		draw_string(FONT, Vector2(0, i * CHARACTER_SIZE), drawn_lines[i].left(drawn_lines[i].length() * visible_ratio))
