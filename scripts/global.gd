extends Node

enum Item {
	None,
	Wings,
	Watch,
	Teleport,
}

enum Hat {
	None,
	Top,
	Niko,
}

enum Modifier {
	Ammo,
	Health,
	Regen,
	Deflect,
}

const HATS = {
	Hat.None: [0, null, preload("res://sprites/shop/icons/shop_icon_0.png"), null],
	Hat.Top: [1, preload("res://sprites/hats/top_hat.png"), preload("res://sprites/shop/icons/shop_icon_2.png"), preload("res://sprites/shop/previews/shop_preview_1.png")],
	Hat.Niko: [2, preload("res://sprites/hats/niko_hat.png"), preload("res://sprites/shop/icons/shop_icon_1.png"), preload("res://sprites/shop/previews/shop_preview_0.png")],
}

var ITEMS = {
	Item.None: [0, preload("res://sprites/shop/icons/shop_icon_0.png"), null, null],
	Item.Wings: [2, preload("res://sprites/shop/icons/shop_icon_3.png"), WingsUpgrade, preload("res://sprites/shop/previews/shop_preview_2.png")],
	Item.Watch: [3, preload("res://sprites/shop/icons/shop_icon_4.png"), WatchUpgrade, preload("res://sprites/shop/previews/shop_preview_3.png")],
	Item.Teleport: [1, preload("res://sprites/shop/icons/shop_icon_4.png"), TeleportUpgrade, null]
}

var MODIFIERS = {
	Modifier.Ammo: AmmoModifier,
	Modifier.Health: HealthModifier,
	Modifier.Regen: RegenerationModifier,
	Modifier.Deflect: DeflectModifier,
}

const DIALOGUES = {
	0: [
		preload("res://resources/dialogue_lines/area_1/1.tres"),
		preload("res://resources/dialogue_lines/area_1/2.tres"),
		preload("res://resources/dialogue_lines/area_1/3.tres"),
		preload("res://resources/dialogue_lines/area_1/4.tres"),
	],
	1: [
		preload("res://resources/dialogue_lines/area_2/1.tres"),
		preload("res://resources/dialogue_lines/area_2/2.tres"),
		preload("res://resources/dialogue_lines/area_2/3.tres"),
		preload("res://resources/dialogue_lines/area_2/4.tres"),
	],
	2: []
}

const IMAGE: PackedByteArray = [
	0x01, 0x16, 0x54, 0x80, 0x7d, 0xc7, 0x5b, 0xbe, 0x45, 0xbb, 0xf0, 0xa2, 0x45, 0x15, 0x2d, 0xa2, 
	0x45, 0x51, 0x07, 0xa2, 0x7d, 0x5d, 0x92, 0xbe, 0x01, 0x55, 0xaa, 0x80, 0xff, 0x0c, 0x71, 0xff, 
	0x74, 0x1f, 0x51, 0x06, 0x9f, 0x90, 0xe5, 0x73, 0x34, 0x8e, 0x65, 0xb5, 0x43, 0x04, 0x30, 0x7e, 
	0x34, 0xd0, 0x86, 0x85, 0x42, 0x23, 0xd9, 0x33, 0x81, 0xa3, 0x18, 0x35, 0xdf, 0x8d, 0x43, 0x0f, 
	0xd7, 0x7c, 0x1d, 0xf3, 0x3d, 0xac, 0xac, 0x15, 0xca, 0x74, 0xf4, 0x5d, 0x05, 0x40, 0xd7, 0x07, 
	0x73, 0xe9, 0x88, 0xd1, 0xc4, 0xd2, 0x25, 0xa1, 0xe7, 0x80, 0x77, 0x6f, 0x34, 0xef, 0xc4, 0x0c, 
	0xff, 0x61, 0x9c, 0xeb, 0x01, 0x36, 0x62, 0xa7, 0x7d, 0xb6, 0x32, 0xed, 0x45, 0x0f, 0xae, 0x05, 
	0x45, 0x8d, 0x55, 0x8f, 0x45, 0xe1, 0x9e, 0x87, 0x7d, 0x8b, 0x07, 0x7f, 0x01, 0x6e, 0x68, 0xfe
]

const VIGNETTE_OPACITY = 0.035
const WINDOW_SIZE = Vector2i(320, 240)

var current_area: Generator.Area = Generator.Area.City
var after_boss: bool = false

var coins: int = 0
var equipped_hat: int = Hat.None
var equipped_item: int = Item.None
var unlocked_items: Array[Item] = []
var unlocked_hats: Array[Hat] = []
var purchasable_items: Array[Item] = []
var purchasable_hats: Array[Hat] = []
var timer: float

var mouse_sens: float = 0.003
var shake_strength: float = 1
var aberration_enabled: bool = true

var player_state: Player
var loop: int = 0
var condition: bool = true
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var modifier_pool = MODIFIERS.keys()
var weapon_pool = {
	"gun": [
		Glock,
		Rifle,
		Shotgun,
		Minigun,
		Sniper,
		Charger,
	],
	"melee": [
		Sledgehammer,
		Sword,
		Dagger,
	]
}
var enemy_pool = {
	0: {
		Birdie: 5,
		BigBird: 2,
		FlyingBird: 3,
		Worm: 5,
	},
	1: {
		Birdie: 2,
		BigBird: 2,
		FlyingBird: 3,
		Policeman: 5,
		Rat: 5,
		Worm: 1,
	},
	2: {
		Birdie: 3,
		BigBird: 3,
		FlyingBird: 3,
		Policeman: 3,
		Rat: 2,
		Worm: 1,
	},
}

func _ready():
	if not OS.has_feature("editor"):
		current_area = Generator.Area.Sky
		after_boss = false
	rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS

func freeze_frame():
	Engine.time_scale = 0.01
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = 1

func set_shader_param(value, _name: String):
	RenderingServer.global_shader_parameter_set(_name, value)

func set_menu_cursor():
	Input.set_custom_mouse_cursor(preload("res://sprites/cursor_menu.png"))

func set_game_cursor():
	Input.set_custom_mouse_cursor(preload("res://sprites/cursor.png"), 0, Vector2(16, 16))

func save_image():
	var buffer: PackedByteArray = []
	for hex in IMAGE:
		for i in range(8):
			var bit = (hex & (128 >> i)) >> 7 - i
			buffer.append(bit * 255)
	var image = Image.new()
	image.set_data(32, 32, false, Image.FORMAT_L8, buffer)
	image.save_png("./image.png")
