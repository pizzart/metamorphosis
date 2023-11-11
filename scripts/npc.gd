extends Area2D

const DIALOGUE_BOX = preload("res://scenes/dialogue_box.tscn")
const LINES = preload("res://resources/dialogue_lines/area_1/3.tres")
const CHARACTER_SIZE = 8

var can_start: bool
var player: Player

var current_line: int = -1
var visible_ratio: float

@onready var dialogue_box = DIALOGUE_BOX.instantiate()
@onready var label = dialogue_box.get_node("Text")

func _ready():
	dialogue_box.position = Vector2(8, -6)
	dialogue_box.hide()
	add_child(dialogue_box)

func _process(delta):
	if current_line > -1 and label.visible_ratio < 1:
		label.visible_ratio = clampf(label.visible_ratio + delta / label.text.length() * 20, 0, 1)

func _input(event):
	if event.is_action_pressed("use") and (can_start or current_line > -1):
		current_line += 1
		if current_line >= LINES.lines.size():
			dialogue_box.hide()
			current_line = -1
			player.can_move = true
			label.text = ""
			visible_ratio = 0
			return
		
		player.can_move = false
		
		dialogue_box.show()
		label.text = LINES.lines[current_line].line.to_upper()
		label.visible_ratio = 0
		dialogue_box.size = Vector2(CHARACTER_SIZE * 12 + 8, CHARACTER_SIZE * (ceili(float(label.text.length()) / 12) + label.text.count("\n")) + 8)

func _on_body_entered(body):
	player = body
	can_start = true

func _on_body_exited(body):
	can_start = false
