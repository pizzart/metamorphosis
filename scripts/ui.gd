extends CanvasLayer

var help_init_pos: Vector2
var help_hidden_pos: Vector2
var help_cur_pos: Vector2
var pack_help_init_pos: Vector2
var pack_help_hidden_pos: Vector2
var pack_help_cur_pos: Vector2
var dot_count: int = 1

func _ready():
	await get_tree().process_frame
	help_init_pos = $Control/M/Help.position
	help_cur_pos = help_init_pos
	help_hidden_pos = help_init_pos + Vector2(40, 0)
	pack_help_init_pos = $Control/M/Bars/Help.position
	pack_help_cur_pos = pack_help_init_pos
	pack_help_hidden_pos = pack_help_init_pos - Vector2(0, 56)
	hide_help()
	hide_pack_help()

func _process(delta):
	$Control/M/Help.position = lerp($Control/M/Help.position, help_cur_pos, delta * 18)
	$Control/M/Bars/Help.position = lerp($Control/M/Bars/Help.position, pack_help_cur_pos, delta * 18)

func show_help():
	help_cur_pos = help_init_pos

func hide_help():
	help_cur_pos = help_hidden_pos

func show_pack_help():
	pack_help_cur_pos = pack_help_init_pos

func hide_pack_help():
	pack_help_cur_pos = pack_help_hidden_pos

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

func set_progress(progress: float):
	$Control/M/PressProgress.value = progress

func flash_ammo():
	var tween = create_tween()
	for i in range(3):
		tween.tween_callback($Control/M/Bars/Ammo/Bar.set_modulate.bind(Color(2, 2, 2)))
		tween.tween_interval(0.3)
		tween.tween_callback($Control/M/Bars/Ammo/Bar.set_modulate.bind(Color.WHITE))
		tween.tween_interval(0.3)

func flash_health():
	var tween = create_tween()
	for i in range(3):
		tween.tween_callback($Control/M/Bars/Ammo/Bar.set_modulate.bind(Color(2, 1, 1)))
		tween.tween_interval(0.3)
		tween.tween_callback($Control/M/Bars/Ammo/Bar.set_modulate.bind(Color.WHITE))
		tween.tween_interval(0.3)

func update_keys():
	var heal_event
	var use_event
	for i in InputMap.action_get_events("heal"):
		if i is InputEventKey or i is InputEventMouseButton:
			heal_event = i
			break
	for i in InputMap.action_get_events("use"):
		if i is InputEventKey or i is InputEventMouseButton:
			use_event = i
			break
	if heal_event is InputEventKey:
		$Control/M/Bars/Help/Text.text = OS.get_keycode_string(heal_event.physical_keycode)
	else:
		$Control/M/Bars/Help/Text.text = heal_event.as_text()
	
	if use_event is InputEventKey:
		$Control/M/Help/Text.text = OS.get_keycode_string(use_event.physical_keycode)
	else:
		$Control/M/Help/Text.text = use_event.as_text()

func show_gen_text():
	$GenText.show()

func hide_gen_text():
	$GenText.hide()

func set_time(time: float):
	var min = floori(time / 60)
	$Control/M/Time.text = "%s:%s" % [str(min).pad_zeros(2), str(snappedf(time - min * 60, 0.001)).pad_decimals(3).pad_zeros(2)]

func _on_gen_timer_timeout():
	dot_count += 1
	dot_count = dot_count % 4
	$GenText.text = "generating" + ".".repeat(dot_count) + " ".repeat(3 - dot_count)
