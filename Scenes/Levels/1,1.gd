extends Control

var sign_post_01

func _input(_event):
	if Input.is_action_just_pressed("Enter"):
		if sign_post_01:
			$Signposts/Signpost/Instructions.visible = true
			$Signposts/Signpost/Label.visible = false

func _ready():
	$Santa.dead = true
	$Santa/AnimatedSprite.play("Idle")

func _on_AnimationPlayer_animation_finished(_anim_name):
	$Santa.dead = false

func _on_Signpost_area_entered(area):
	if area.is_in_group("Player"):
		sign_post_01 = true
		$Signposts/Signpost/Label.visible = true

func _on_Signpost_area_exited(area):
	if area.is_in_group("Player"):
		sign_post_01 = false
		$Signposts/Signpost/Label.visible = false
		$Signposts/Signpost/Instructions.visible = false


func _on_Area2D_area_entered(area):
	if area.is_in_group("Player"):
		$Santa.can_jump = true

func _on_Area2D_area_exited(area):
	if area.is_in_group("Player"):
		$Santa.can_jump = false

func _on_Area_Intro_area_entered(area):
	if area.is_in_group("Player"):
		$Santa.intro = true
		$Santa/AnimatedSprite.play("Idle")
		$Power_Intro/Animation_Power.play("Intro")

func _on_Animation_Power_animation_finished(_anim_name):
	$Power_Intro.queue_free()
	$Santa.intro = false
	$Santa.can_punch = true

func _on_Door_01_area_entered(area):
	if area.is_in_group("Player"):
		if $Santa.key:
			get_tree().get_nodes_in_group("Main")[0].Hide_Key()
			get_tree().get_nodes_in_group("Main")[0].santa_intro = true
			$Santa.intro = true
			$Santa/AnimatedSprite.play("Idle")
			$Santa.visibily_notifier = true
			get_tree().get_nodes_in_group("Main")[0].Next_Level()
			Global.level = "02"
