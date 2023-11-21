class_name SpeedUpgrade
extends Upgrade

func _init():
	super._init()
	weight = 1

func _ready():
	player.speed *= 1.25
