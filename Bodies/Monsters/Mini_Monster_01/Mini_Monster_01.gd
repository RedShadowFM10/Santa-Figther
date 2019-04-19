extends KinematicBody2D

var move = Vector2()
var gravity = 600
var speed = 150

var direction = false
 
func _ready():
	$AnimatedSprite.play("Run")

func _physics_process(delta):
	if !is_on_floor():
		move.y += gravity * delta
	else:
		move.y = 15
		if !direction:
			move.x = -speed
			$AnimatedSprite.flip_h = true
		else:
			move.x = speed
			$AnimatedSprite.flip_h = false
	
	move = move_and_slide(move, Vector2(0, -1))



func _on_Timer_timeout():
	direction = !direction
