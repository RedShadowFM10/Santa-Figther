extends Node

var count = 0

func _input(event):
	if Input.is_action_just_pressed("Esc"):
		$Timer.stop()
		$Timer_Text.stop()
		$Music/Timer_Music.stop()
		count = 2
		Fade_In_Out.change_scene("res://Scenes/Main/Main.tscn")
	elif Input.is_action_just_pressed("Enter"):
		count += 1
		if count == 1:
			$Music.play()
			$Music/Timer_Music.start()
			$Text_01.queue_free()
			$Text_02.visible = true
			$Press.queue_free()

func _on_Timer_Text_timeout():
	$Text_02.queue_free()
	Fade_In_Out.effect()
	$Timer.start()

func _on_Timer_timeout():
	$House.visible = true
	$AnimationPlayer.play("Scene")

func _on_AnimationPlayer_animation_finished(anim_name):
	Fade_In_Out.change_scene("res://Scenes/Main/Main.tscn")
	Global.intro = true

func _on_Timer_Music_timeout():
	$Music.stop()
	$Music.play()
	$Timer_Text.start()
