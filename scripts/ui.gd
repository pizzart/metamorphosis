extends CanvasLayer

var help_init_pos: Vector2
var help_hidden_pos: Vector2
var help_cur_pos: Vector2

func _ready():
	await get_tree().process_frame
	help_init_pos = $Control/M/Help.position
	help_cur_pos = help_init_pos
	help_hidden_pos = help_init_pos + Vector2(40, 0)
	hide_help()

func _process(delta):
	$Control/M/Help.position = lerp($Control/M/Help.position, help_cur_pos, delta * 18)

func show_help():
	help_cur_pos = help_init_pos

func hide_help():
	help_cur_pos = help_hidden_pos

func set_health_packs(amount: int):
	for c in $Control/M/Bars/Packs.get_children():
		c.texture = preload("res://sprites/ui/energy_pack_empty.png")
	for i in range(amount):
		$Control/M/Bars/Packs.get_child(i).texture = preload("res://sprites/ui/energy_pack.png")

func blink_packs():
	var tween = create_tween()
	$Control/M/Bars/Packs.modulate = Color.RED
	tween.tween_property($Control/M/Bars/Packs, "modulate", Color.WHITE, 1.0)

func transition_in(time: float = 1):
	var tween = create_tween()
	tween.tween_property($Black, "color", Color.BLACK, time)

func transition_out(time: float = 1):
	var tween = create_tween()
	tween.tween_property($Black, "color", Color(0, 0, 0, 0), time)
