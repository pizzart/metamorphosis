extends Interactable

signal dialogue_finished

const DIALOGUE_BOX = preload("res://scenes/dialogue_box.tscn")
#const LINES = preload("res://resources/dialogue_lines/area_1/3.tres")
const CHARACTER_SIZE = 8
const BOX_OFFSET = Vector2(8, -30)

var current_line: int = -1
var visible_ratio: float
var last_visible_char: int = -1

@export var lines: DialogueLines
@onready var dialogue_box = DIALOGUE_BOX.instantiate()
@onready var label = dialogue_box.get_node("Text")

func _ready():
	dialogue_box.position = BOX_OFFSET
	dialogue_box.hide()
	add_child(dialogue_box)

func _process(delta):
	if current_line > -1 and label.visible_ratio < 1:
		if lines.lines[current_line].speaker == DialogueLine.Speaker.You:
			dialogue_box.position = lerp(dialogue_box.position, to_local(player.global_position) + BOX_OFFSET, delta * 20)
		else:
			dialogue_box.position = lerp(dialogue_box.position, BOX_OFFSET, delta * 20)
		label.visible_ratio = clampf(label.visible_ratio + delta / label.text.length() * 25, 0, 1)
		if last_visible_char < label.visible_characters:
			$TalkSFX.play()
			last_visible_char = label.visible_characters

func _input(event):
	if event.is_action_pressed("use") and (can_interact or current_line > -1):
		current_line += 1
		if current_line >= lines.lines.size():
			dialogue_box.hide()
			current_line = -1
			player.can_move = true
			label.text = ""
			visible_ratio = 0
			dialogue_finished.emit()
			return
		
		player.can_move = false
		
		dialogue_box.show()
		label.text = lines.lines[current_line].line.to_upper()
		label.visible_ratio = 0
		last_visible_char = -1
		dialogue_box.size = Vector2(CHARACTER_SIZE * 12 + 8, 0)
