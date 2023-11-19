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

const ITEMS = {
	Item.None: [0, preload("res://sprites/shop/cross.png")],
	Item.Wings: [2, preload("res://sprites/shop/wings_shop.png")],
	Item.Watch: [3, preload("res://sprites/shop/wings_shop.png")],
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
var current_area: Generator.Area = Generator.Area.Sky
var equipped_hat: int = Hat.None
var unlocked_items: Array[Item] = []
var unlocked_hats: Array[Hat] = []
var purchasable_items: Array[Item] = [Item.Wings]
var purchasable_hats: Array[Hat] = [Hat.Top, Hat.Niko]
var timer: float

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
