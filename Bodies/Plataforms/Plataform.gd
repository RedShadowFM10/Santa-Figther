extends KinematicBody2D

var move = Vector2()
var target = false
var speed = 100

func _physics_process(delta):
	if target:
		move.y = speed
	else:
		move.y = -speed
	
	if global_position.y < get_parent().get_node("Up").global_position.y && !target:
		target = true
	elif global_position.y > get_parent().get_node("Down").global_position.y && target:
		target = false
	
	move = move_and_slide(move)
