extends Control

var sign_post_01 = false

func _input(event):
	if Input.is_action_just_pressed("Enter"):
		if sign_post_01:
			$Signposts/Signpost/Instructions.visible = true
			$Signposts/Signpost/Label.visible = false

func _ready():
	if Global.intro:
		$Santa.visible = false
		$Santa.dead = true
		$Intro/AnimationPlayer.play("Intro")
		Global.intro = false
	else:
		$Intro.queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	Fade_In_Out.effect()
	$Intro/Timer_Intro.start()

func _on_Timer_Intro_timeout():
	$Santa.visible = true
	$Santa.dead = false
	$Intro.queue_free()

func _on_Signpost_area_entered(area):
	if area.is_in_group("Player"):
		sign_post_01 = true
		$Signposts/Signpost/Label.visible = true

func _on_Signpost_area_exited(area):
	if area.is_in_group("Player"):
		sign_post_01 = false
		$Signposts/Signpost/Label.visible = false
		$Signposts/Signpost/Instructions.visible = false

func _on_Area2D_3_body_entered(body):
	if body.is_in_group("Player"):
		$Platforms/Platform3/AnimationPlayer.play("Nueva animación")

func _on_Area_Platform_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().get_nodes_in_group("Main")[0].santa_intro = true
		$Santa.intro = true
		$Santa/AnimatedSprite.play("Idle")
		$Santa.Adjust_Right()
		$Santa.visibily_notifier = true
		$Platforms/Platform4/Area_Platform.queue_free()
		$Platforms/Platform4/AnimationPlayer.play("Nueva animación")
		$Platforms/Platform4/Timer_Platform4.start()

func _on_Timer_Platform4_timeout():
	Global.level = "1,1"
	Fade_In_Out.effect_change_level()
	$Platforms/Platform4/Timer_Fade_Effect.start()

func _on_Timer_Fade_Effect_timeout():
	get_tree().get_nodes_in_group("Main")[0].Deleted_Add_Child()
