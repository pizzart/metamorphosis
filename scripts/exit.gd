class_name Exit
extends Area2D

signal moved
signal arrived

const WAIT_TIME = 0.5
const HOLD_TIME = 0.2

var elevation: int = 0
var counter: int
var can_interact: bool
var enemies_gone: bool
var hold_wait_timer: float
var moving: bool = true
var timer: float
var intended_pos: Vector2
var tween
@export var override_wait: float

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready():
	end_descent()

func _process(delta):
	if can_interact:
		if Input.is_action_pressed("use"):
			timer += delta
			if timer >= WAIT_TIME:
				timer = 0
				Input.action_release("use")
				start_descent()
		else:
			timer = 0
		UI.set_progress(timer / WAIT_TIME)
	elif Global.skip_enabled and moving:
		if Input.is_action_just_pressed("use"):
			UI.show_help()
		if Input.is_action_just_released("use"):
			UI.hide_help()
		if Input.is_action_pressed("use"):
			hold_wait_timer += delta
			if hold_wait_timer >= HOLD_TIME:
				hold_wait_timer = 0
				if elevation == 0:
					end_apply()
				else:
					start_apply()
				global_position = intended_pos
				player.global_position = intended_pos
				tween.stop()
		else:
			hold_wait_timer = 0
		UI.set_progress(hold_wait_timer / HOLD_TIME)

func start_descent():
	intended_pos = global_position + Vector2(0, 200)
	moving = true
	
	elevation = 1
	can_interact = false
	set_deferred("monitoring", false)
	player.can_move = false
	player.global_position = global_position
	player.sprite.animation = "front"
	player.z_index = -5
	z_index = -5
	player.sprite.pause()
	player.change_emotion(Player.Emotion.Waiting)
	$Start.play()
	tween = create_tween().set_parallel()
	tween.tween_property(self, "global_position", global_position + Vector2(0, 50), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(player, "global_position", global_position + Vector2(0, 50), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(UI.transition_in)
	tween.tween_callback($Loop.play)
	tween.tween_property(self, "global_position", global_position + Vector2(0, 200), 1.0)
	tween.tween_property(player, "global_position", global_position + Vector2(0, 200), 1.0)
	await tween.finished
	start_apply()

func start_apply():
	player.z_index = 1
	z_index = 0
	player.change_emotion(Player.Emotion.None)
	player.sprite.play()
	moving = false
	moved.emit()

func end_descent():
	var end_position = global_position
	intended_pos = end_position
	moving = true
	
	if override_wait:
		global_position = end_position - Vector2(0, override_wait * 200)
	else:
		global_position = end_position - Vector2(0, 200)
	player.can_move = false
	player.global_position = global_position
	player.sprite.animation = "front"
	player.sprite.pause()
	player.change_emotion(Player.Emotion.Waiting)
	$Loop.play()
	tween = create_tween().set_parallel()
	tween.tween_callback(UI.transition_out)
	var time = 1.0
	if override_wait:
		time = override_wait
	tween.tween_property(self, "global_position", end_position - Vector2(0, 50), time)
	tween.tween_property(player, "global_position", end_position - Vector2(0, 50), time)
	tween.chain().tween_callback($Loop.stop)
	tween.tween_callback($End.play)
	tween.tween_property(self, "global_position", end_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "global_position", end_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	end_apply()

func end_apply():
	moving = false
	set_deferred("monitoring", true)
	$Timer.start()
	player.can_move = true
	player.change_emotion(Player.Emotion.None)
	player.sprite.play()
	arrived.emit()

func play_fin_sound():
	$Finished.play()

func _input(event):
	if event.is_action_pressed("use"):
#		if can_interact:
#			start_descent()
		if not can_interact and overlaps_body(player):
			$ErrorSFX.play()

func _on_body_entered(_body):
	counter += 1
	if counter > 1 and enemies_gone:
		can_interact = true
		UI.show_help()

func _on_body_exited(_body):
	can_interact = false
	UI.hide_help()

func _on_timer_timeout():
	if overlaps_body(player) and enemies_gone:
		can_interact = true
		UI.show_help()
