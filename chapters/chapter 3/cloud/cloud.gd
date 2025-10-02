extends StaticBody2D

func _on_area_2d_body_entered(body: Node2D):
	if body is Player:
		if body.velocity.y >= 0:
			$AnimationPlayer.play("bounce")
			$AudioStreamPlayer2D.play()
			await get_tree().create_timer(0.25).timeout
			body.velocity.y = -200
