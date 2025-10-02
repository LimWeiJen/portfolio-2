extends Area2D

func _ready():
	$AnimationPlayer.play_backwards("show sign")

func _on_body_entered(body: Node2D):
	if body is Player:
		$AnimationPlayer.play("show sign")


func _on_body_exited(body: Node2D):
	if body is Player:
		$AnimationPlayer.play_backwards("show sign")
