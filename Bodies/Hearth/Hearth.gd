extends KinematicBody2D

var move = Vector2()
var gravity = 600

func _physics_process(delta):
	if !is_on_floor():
		move.y += gravity * delta
	else:
		move.y = 0
	
	move = move_and_slide(move, Vector2(0, -1))

func _on_Area2D_area_entered(area):
	if area.is_in_group("Player"):
		queue_free()