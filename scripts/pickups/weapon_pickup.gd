class_name WeaponPickup
extends Pickup

signal picked_up

enum Type {
	Gun,
	Melee,
}

var pickup_name: String
var item: Weapon
var drawer = TextDraw.new()

func _init(_pickup_name: String, _item: Weapon):
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	super._init(rect, _item.texture)
	pickup_name = _pickup_name
	item = _item
	
	drawer.position = Vector2(-pickup_name.length() * 4, -24)
	drawer.text = pickup_name
	add_child(drawer)
	drawer.hide()

func _ready():
	sprite.rotation = (global_position.x + global_position.y) / PI

func _process(delta):
	drawer.visible = can_interact

func _input(event):
	if event.is_action_pressed("use") and can_interact:
		var check
		if item is Gun:
			check = player.is_less_gun_weight(item.weight)
		else:
			check = player.is_less_melee_weight(item.weight)
		
		if check:
			var weapon = player.replace_weapon(item)
			if weapon != null:
				var new_pickup = WeaponPickup.new(weapon.weapon_name, weapon)
				new_pickup.global_position = player.global_position
				get_parent().add_child(new_pickup)
			picked_up.emit()
			queue_free()
