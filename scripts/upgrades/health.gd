class_name HealthUpgrade
extends Upgrade

func _init():
	weight = 1

func _ready():
	player.max_health = 12
