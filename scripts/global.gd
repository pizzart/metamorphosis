extends Node

const DIALOGUES = {
	0: [
		preload("res://resources/dialogue_lines/area_1/1.tres"),
		preload("res://resources/dialogue_lines/area_1/2.tres"),
		preload("res://resources/dialogue_lines/area_1/3.tres"),
	],
	1: [
		preload("res://resources/dialogue_lines/area_2/1.tres"),
		preload("res://resources/dialogue_lines/area_2/2.tres"),
	]
}

var current_area: Generator.Area = Generator.Area.Sky
var weapon_pool = [
	Pistol,
	Glock,
	Rifle,
	Shotgun,
	Sledgehammer,
	Sword,
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func freeze_frame():
	get_tree().paused = true
	await get_tree().create_timer(0.09).timeout
	get_tree().paused = false

func set_shader_param(value, _name: String):
	RenderingServer.global_shader_parameter_set(_name, value)
