extends Node

enum Items {
	Wings,
	Watch,
}

enum Hat {
	None,
	Top,
	Niko,
}

const HATS = {
	Hat.None: ["none", null],
	Hat.Top: ["top hat", preload("res://sprites/hats/top_hat.png")],
	Hat.Niko: ["niko", preload("res://sprites/hats/niko_hat.png")],
}

const DIALOGUES = {
	0: [
		preload("res://resources/dialogue_lines/area_1/1.tres"),
		preload("res://resources/dialogue_lines/area_1/2.tres"),
		preload("res://resources/dialogue_lines/area_1/3.tres"),
	],
	1: [
		preload("res://resources/dialogue_lines/area_2/1.tres"),
		preload("res://resources/dialogue_lines/area_2/2.tres"),
	],
	2: []
}

var coins: int
var current_area: Generator.Area = Generator.Area.Sky
var equipped_hat: int
var unlocked_items: Array = []

var weapon_pool = {
	"gun": [
		Pistol,
		Glock,
		Rifle,
		Shotgun,
	],
	"melee": [
		Sledgehammer,
		Sword,
	]
}
var enemy_pool = {
	0: [Birdie, BigBird, FlyingBird],
	1: [Birdie, BigBird, FlyingBird],
	2: [Birdie, BigBird, FlyingBird],
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func freeze_frame():
	get_tree().paused = true
	await get_tree().create_timer(0.09).timeout
	get_tree().paused = false

func set_shader_param(value, _name: String):
	RenderingServer.global_shader_parameter_set(_name, value)
