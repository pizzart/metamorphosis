class_name DeflectModifier
extends Upgrade

const WEIGHT = 2

func _init():
	super._init()
	weight = WEIGHT

func _ready():
	player.melee.can_deflect = true
	player.weapon_changed.connect(_on_weapon_changed)

func _on_weapon_changed(weapon: Weapon):
	if weapon is Melee:
		weapon.can_deflect = true
