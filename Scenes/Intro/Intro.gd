extends Node

var count = 0

func _input(event):
	if Input.is_action_just_pressed("Esc"):
		$Timer.stop()
		Fade_In_Out.change_scene("res://Scenes/Main/Main.tscn")
	elif Input.is_action_just_pressed("Enter"):
		count += 1
		if count == 1:
			$Text_01.queue_free()
			$Text_02.visible = true
		elif count == 2:
			$Text_02.queue_free()
			$Press.queue_free()
			
			Fade_In_Out.effect()
			$Timer.start()

func _on_Timer_timeout():
	$House.visible = true
	$AnimationPlayer.play("Scene")

func _on_AnimationPlayer_animation_finished(anim_name):
	Fade_In_Out.change_scene("res://Scenes/Main/Main.tscn")
