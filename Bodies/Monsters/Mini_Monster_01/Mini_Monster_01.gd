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

var player
var main
var check = false
var sfx_hit_enemy

func _ready():
	main = get_tree().get_nodes_in_group("Main")[0]
	sfx_hit_enemy = get_tree().get_nodes_in_group("SFX")[0].get_node("Hit_Enemy")

func _physics_process(delta):
	if !is_on_floor():
		move.y += gravity * delta
	else:
		move.y = 15
		if !dead:
			if !check && main.santa_dead:
				Dead_Player()
			
			if is_on_wall():
				if follow_player:
					follow_player = false
					$RayCastReact.enabled = true
					$Idle.start(2)
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
				if player.global_position.x - $Position2D.global_position.x < 15 && player.global_position.x - $Position2D.global_position.x > 0:
					movement = false
					idle = false
				elif player.global_position.x > $Position2D.global_position.x:
					movement = true
					idle = true
					direction = true
				elif player.global_position.x < $Position2D.global_position.x:
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
		$CollisionShape2D.position.x = 2.384
		adjust = false

func Adjust_Left():
	if !adjust:
		$RayCastFloor.position.x = -18
		$AnimatedSprite.flip_h = true
		$RayCastReact.rotation_degrees = 180
		$CollisionShape2D.position.x = -1
		adjust = true

func Change_Modulate():
	if $AnimatedSprite.modulate == Color(1, 1, 1):
		$AnimatedSprite.modulate = Color(10, 10, 10)
		yield(get_tree().create_timer(0.2), "timeout")
		$AnimatedSprite.modulate = Color(1, 1, 1)

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
	if area.is_in_group("Attack") || area.is_in_group("Explosion"):
		Dead()

func Dead():
	Change_Modulate()
	move.x = 0
	dead = true
	$Damage.play()
	sfx_hit_enemy.play()
	$AnimatedSprite.play("Dead")
	Stop_Timers()
	if $AnimatedSprite.flip_h:
		if !idle:
			$AnimationPlayer.play("Dead_Right")
		else:
			$AnimationPlayer.play("Dead_Left")
	else:
		if !idle:
			$AnimationPlayer.play("Dead_Left")
		else:
			$AnimationPlayer.play("Dead_Right")
	yield(get_tree().create_timer(0.1), "timeout")
	$Area2D/CollisionShape2D.disabled = true
	$Area_Attack/CollisionShape2D.disabled = true
	$Timer_Queue.start()

func Dead_Player():
	check = true
	follow_player = false
	movement = true

func _on_Timer_Queue_timeout():
	queue_free()

func _on_Ready_timeout():
	player = get_tree().get_nodes_in_group("Player")[0]
