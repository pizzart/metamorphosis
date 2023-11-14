extends Interactable

const DIALOGUE_BOX = preload("res://scenes/dialogue_box.tscn")
#const LINES = preload("res://resources/dialogue_lines/area_1/3.tres")
const CHARACTER_SIZE = 8

var lines: DialogueLines
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
		label.visible_ratio = clampf(label.visible_ratio + delta / label.text.length() * 25, 0, 1)

func _input(event):
	if event.is_action_pressed("use") and (can_interact or current_line > -1):
		current_line += 1
		if current_line >= lines.lines.size():
			dialogue_box.hide()
			current_line = -1
			player.can_move = true
			label.text = ""
			visible_ratio = 0
			return
		
		player.can_move = false
		
		dialogue_box.show()
		label.text = lines.lines[current_line].line.to_upper()
		label.visible_ratio = 0
		dialogue_box.size = Vector2(CHARACTER_SIZE * 12 + 8, 0)
