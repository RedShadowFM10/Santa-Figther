extends Control

func _ready():
#	$Santa.dead = true
	$Santa/AnimatedSprite.play("Idle")

func _on_AnimationPlayer_animation_finished(_anim_name):
	$Santa.dead = false
