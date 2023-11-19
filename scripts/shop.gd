extends Control

enum ItemType {
	Hat,
	Item,
}

var selected_dict: Dictionary
var selected: int
var selected_type: ItemType

func _ready():
	$M/H/Disk.visible = Global.coins > 0
	for i in range(Global.coins - 1):
		$M/H.add_child($M/H/Disk.duplicate())
	
	for item in Global.ITEMS.keys():
		if item == 0:
			continue
		$M/ItemList.add_icon_item(Global.ITEMS[item][1])
	for hat in Global.HATS.keys():
		if hat == 0:
			continue
		$M/ItemList.add_icon_item(Global.HATS[hat][2])

func _on_buy_pressed():
	if selected_type == ItemType.Hat:
		Global.purchasable_hats.erase(selected)
		Global.unlocked_hats.append(selected)
	else:
		Global.purchasable_items.erase(selected)
		Global.unlocked_items.append(selected)
	
	$M/V/Disks.hide()
	$M/V/Buy.disabled = true
	
	for i in range(Global.coins - 1, Global.coins - selected_dict[selected][0] - 1, -1):
		$M/H.get_child(i).queue_free()
	
	Global.coins -= selected_dict[selected][0]
	
	selected = 0

func _on_item_list_item_selected(index):
	selected_dict = Global.ITEMS
	var idx = index + 1
	var can_buy = false
	if idx >= Global.ITEMS.size():
		idx -= Global.ITEMS.size() - 1
		selected_dict = Global.HATS
		selected_type = ItemType.Hat
		can_buy = idx in Global.purchasable_hats
	else:
		selected_type = ItemType.Item
		can_buy = idx in Global.purchasable_items
	selected = idx
	
	$M/V/Buy.disabled = Global.coins < selected_dict[selected][0] or not can_buy
	
	$M/V/Disks.show()
	$M/V/Disks/Disk.hide()
	for i in $M/V/Disks.get_child_count():
		if i != 0:
			$M/V/Disks.get_child(i).queue_free()
	$M/V/Disks/Disk.show()
	for i in range(selected_dict[selected][0] - 1):
		$M/V/Disks.add_child($M/V/Disks/Disk.duplicate())
