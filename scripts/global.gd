extends Node

var after_3d: bool
var weapon_pool = [
	Pistol,
	Glock,
	Shotgun,
	Rifle,
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func freeze_frame():
	get_tree().paused = true
	await get_tree().create_timer(0.05).timeout
	get_tree().paused = false
