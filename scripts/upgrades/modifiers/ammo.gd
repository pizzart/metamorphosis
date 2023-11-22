class_name AmmoModifier
extends Upgrade

func _init():
	super._init()
	weight = 1

func _ready():
	player.max_ammo = 150
