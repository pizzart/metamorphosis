class_name RegenerationModifier
extends Upgrade

const WEIGHT = 1
const CHANCE = 0.02

func _init():
	super._init()
	weight = WEIGHT

func _ready():
	connect_enemies()
	player.get_parent().generator.generated.connect(_on_generated)

func _on_generated():
	await get_tree().process_frame
	connect_enemies()

func connect_enemies():
	for enemy in get_tree().get_nodes_in_group("foe"):
		enemy.dead.connect(_on_enemy_dead)

func _on_enemy_dead():
	if player.rng.randf() <= CHANCE:
		player.heal(1)
