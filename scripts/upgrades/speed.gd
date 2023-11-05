class_name SpeedUpgrade
extends Upgrade

func _init():
	weight = 100

func _ready():
	player.speed *= 1.25
