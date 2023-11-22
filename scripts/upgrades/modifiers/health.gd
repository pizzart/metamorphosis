class_name HealthModifier
extends Upgrade

func _init():
	super._init()
	weight = 1

func _ready():
	player.max_health = 12
