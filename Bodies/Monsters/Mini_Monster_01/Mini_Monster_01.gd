extends KinematicBody2D

var move = Vector2()
var gravity = 600
var speed = 250

var direction = true
var adjust = false

var dead = false
var idle = false
var follow_player = false
var movement = false

var santa

func _ready():
	santa = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	if !is_on_floor():
		move.y += gravity * delta
	else:
		move.y = 15
		if !dead:
			if is_on_wall():
				direction = !direction
			if !$RayCastFloor.is_colliding():
				if follow_player:
					follow_player = false
					$RayCastReact.enabled = true
					$Idle.start(2)
				direction = !direction
			if $RayCastReact.is_colliding():
				var coll = $RayCastReact.get_collider()
				if coll.is_in_group("Player"):
					follow_player = true
					movement = true
					idle = true
					Stop_Timers()
					$RayCastReact.enabled = false
			
			if follow_player:
				if santa.global_position.x - $Position2D.global_position.x < 15 && santa.global_position.x - $Position2D.global_position.x > -0:
					movement = false
					idle = false
				elif santa.global_position.x > $Position2D.global_position.x:
					movement = true
					idle = true
					direction = true
				elif santa.global_position.x < $Position2D.global_position.x:
					movement = true
					idle = true
					direction = false
			if movement:
				if direction:
					move.x = speed
					$AnimatedSprite.play("Run")
					Adjust_Rigth()
				else:
					move.x = -speed
					$AnimatedSprite.play("Run")
					Adjust_Left()
			elif !idle:
				move.x = 0
				$AnimatedSprite.play("Idle")
	
	move = move_and_slide(move, Vector2(0, -1))

func Adjust_Rigth():
	if adjust:
		$RayCastFloor.position.x = 23
		$AnimatedSprite.flip_h = false
		$RayCastReact.rotation_degrees = 0
		adjust = false

func Adjust_Left():
	if !adjust:
		$RayCastFloor.position.x = -18
		$AnimatedSprite.flip_h = true
		$RayCastReact.rotation_degrees = 180
		adjust = true

func _on_Idle_timeout():
	idle = false
	movement = false
	$Move.start()

func _on_Move_timeout():
	idle = true
	movement = true
	$Idle.start(5)

func Stop_Timers():
	$Idle.stop()
	$Move.stop()

func _on_Area2D_area_entered(area):
	if area.is_in_group("Player") && !idle:
		follow_player = true
		movement = true
		idle = true
		$RayCastReact.enabled = false
	elif area.is_in_group("Attack"):
		Dead()

func Dead():
	dead = true
	Stop_Timers()
