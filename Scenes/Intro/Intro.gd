extends Node

var count = 0

func _input(event):
	if Input.is_action_just_pressed("Enter"):
		count += 1
		if count == 1:
			$Press.queue_free()
			$House.visible = true
			$AnimationPlayer.play("Scene")
