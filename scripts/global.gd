extends Node

enum Item {
	None,
	Wings,
	Watch,
}

enum Hat {
	None,
	Top,
	Niko,
}

const HATS = {
	Hat.None: [0, null, preload("res://sprites/shop/cross.png")],
	Hat.Top: [1, preload("res://sprites/hats/top_hat.png"), preload("res://sprites/shop/top_hat_shop.png")],
	Hat.Niko: [2, preload("res://sprites/hats/niko_hat.png"), preload("res://sprites/shop/niko_hat_shop.png")],
}

var ITEMS = {
	Item.None: [0, preload("res://sprites/shop/cross.png"), null],
	Item.Wings: [2, preload("res://sprites/shop/wings_shop.png"), WingsUpgrade],
	Item.Watch: [3, preload("res://sprites/shop/wings_shop.png"), WatchUpgrade],
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

const VIGNETTE_OPACITY = 0.035

var coins: int = 5
var current_area: Generator.Area = Generator.Area.City
var after_boss: bool
var equipped_hat: int = Hat.None
var equipped_item: int = Item.Watch
var unlocked_items: Array[Item] = []
var unlocked_hats: Array[Hat] = []
var purchasable_items: Array[Item] = []
var purchasable_hats: Array[Hat] = []
var timer: float

var player_state: Player

var weapon_pool = {
	"gun": [
		Pistol,
		Glock,
		Rifle,
		Shotgun,
		Minigun,
	],
	"melee": [
		Sledgehammer,
		Sword,
	]
}
var enemy_pool = {
	0: {
		Birdie: 5,
		BigBird: 2,
		FlyingBird: 3,
	},
	1: {
		Birdie: 2,
		BigBird: 2,
		FlyingBird: 3,
		Policeman: 5,
	},
	2: {
		Birdie: 3,
		BigBird: 3,
		FlyingBird: 3,
		Policeman: 3,
	},
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func freeze_frame():
	Engine.time_scale = 0.01
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1

func set_shader_param(value, _name: String):
	RenderingServer.global_shader_parameter_set(_name, value)
