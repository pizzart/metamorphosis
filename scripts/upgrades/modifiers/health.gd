class_name HealthModifier
extends Upgrade

const WEIGHT = 1

func _init():
	super._init()
	weight = WEIGHT

func _ready():
	player.max_health = 12
