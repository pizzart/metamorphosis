class_name Projectile
extends Area2D

var damage: int = 0

var audio = AudioStreamPlayer2D.new()

func _init():
	z_index = 1
	add_to_group("projectile")
	
	var stream = AudioStreamRandomizer.new()
	stream.add_stream(0, preload("res://audio/sfx/bonk.wav"))
	audio.stream = stream
	audio.bus = "sfx"
	add_child(audio)
