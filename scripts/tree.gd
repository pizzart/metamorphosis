extends StaticBody2D

func hit():
	$HitParticles.emitting = true
	var tween = create_tween()
	tween.tween_property($Sprite, "modulate", Color.WHITE, 0.3).from(Color(2, 2, 2))
