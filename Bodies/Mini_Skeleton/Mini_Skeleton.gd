extends KinematicBody2D

var move = Vector2()
var gravity = 600
var speed = 275

var direction = true
var adjust = false

var dead = false
var follow_player = false
var movement = false
var idle = false

var player
var check = false
var sfx_hit_enemy

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	sfx_hit_enemy = get_tree().get_nodes_in_group("SFX")[0].get_node("Hit_Enemy")
	movement = true
	idle = true

func _physics_process(delta):
	if !dead:
		if $RayCastReact.is_colliding():
			var coll = $RayCastReact.get_collider()
			if coll.is_in_group("Player"):
				follow_player = true
				$RayCastReact.enabled = false
	
	if !is_on_floor():
		move.y += gravity * delta
		$AnimatedSprite.stop()
	else:
		move.y = 15
		if !dead:
			if player.dead && !check:
				follow_player = false
				check = true
				idle = true
				movement = true
			if is_on_wall():
				if follow_player:
					follow_player = false
					$RayCastReact.enabled = true
				direction = !direction
			if !$RayCastFloor.is_colliding():
				if follow_player:
					follow_player = false
					$RayCastReact.enabled = true
				direction = !direction
			if $RayCastJump2.is_colliding() && !$RayCastJump.is_colliding():
				move.y = -300
			
			if follow_player:
				if player.global_position.x - $Position2D.global_position.x < 15 && player.global_position.x - $Position2D.global_position.x > 0:
					movement = false
					idle = false
				elif player.global_position.x > $Position2D.global_position.x:
					movement = true
					direction = true
					idle = true
				elif player.global_position.x < $Position2D.global_position.x:
					movement = true
					direction = false
					idle = true
			if movement:
				$AnimatedSprite.play("Move")
				if direction:
					move.x = speed
					Adjust_Rigth()
				else:
					move.x = -speed
					Adjust_Left()
			elif !idle:
				move.x = 0
				$AnimatedSprite.stop()
	
	move = move_and_slide(move, Vector2(0, -1))

func Adjust_Rigth():
	if adjust:
		$RayCastFloor.position.x = 23
		$AnimatedSprite.flip_h = false
		$RayCastReact.cast_to.x = 300
		$CollisionShape2D.position.x = 1.617
		$Area2D/CollisionShape2D.position.x = 1.568
		$RayCastJump.cast_to.x = 70
		$RayCastJump2.cast_to.x = 70
		adjust = false

func Adjust_Left():
	if !adjust:
		$RayCastFloor.position.x = -22
		$AnimatedSprite.flip_h = true
		$RayCastReact.cast_to.x = -300
		$CollisionShape2D.position.x = -1.442
		$Area2D/CollisionShape2D.position.x = -1.49
		$RayCastJump.cast_to.x = -70
		$RayCastJump2.cast_to.x = -70
		adjust = true

func Change_Modulate():
	if $AnimatedSprite.modulate == Color(1, 1, 1):
		$AnimatedSprite.modulate = Color(10, 10, 10)
		yield(get_tree().create_timer(0.2), "timeout")
		$AnimatedSprite.modulate = Color(1, 1, 1)

func _on_Area2D_area_entered(area):
	if area.is_in_group("Attack") || area.is_in_group("Explosion"):
		Dead()

func Dead():
	Change_Modulate()
	move.x = 0
	dead = true
	sfx_hit_enemy.play()
	$AnimatedSprite.stop()
	if $AnimatedSprite.flip_h:
		$AnimationPlayer.play("Dead_Left")
	else:
		$AnimationPlayer.play("Dead_Right")
	yield(get_tree().create_timer(0.1), "timeout")
	$Area2D/CollisionShape2D.disabled = true
	$Area_Attack/CollisionShape2D.disabled = true
	$Timer_Queue.start()

func _on_Timer_Queue_timeout():
	queue_free()
