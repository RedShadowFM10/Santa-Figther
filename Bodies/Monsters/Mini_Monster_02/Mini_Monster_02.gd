extends KinematicBody2D

var move = Vector2()
var gravity = 600

var dead = false
var follow_player = false

var jump = false
var adjust = false

var player
var sfx_hit_enemy

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	sfx_hit_enemy = get_tree().get_nodes_in_group("SFX")[0].get_node("Hit_Enemy")

func _physics_process(delta):
	if !is_on_floor():
		move.y += gravity * delta
	else:
		move.y = 0
		if !dead:
			if jump:
				$AnimatedSprite.frame = 0
				jump = false
			$AnimatedSprite.play("Idle")
			if follow_player:
				if player.global_position.x > $Position2D.global_position.x:
					Adjust_Right()
				elif player.global_position.x < $Position2D.global_position.x:
					Adjust_Left()
	
	move = move_and_slide(move, Vector2(0, -1))

func Adjust_Right():
	if adjust:
		$AnimatedSprite.flip_h = false
		$React/CollisionShape2D.position.x = 86
		adjust = false

func Adjust_Left():
	if !adjust:
		$AnimatedSprite.flip_h = true
		$React/CollisionShape2D.position.x = -86
		adjust = true

func Change_Modulate():
	if $AnimatedSprite.modulate == Color(1, 1, 1):
		$AnimatedSprite.modulate = Color(10, 10, 10)
		yield(get_tree().create_timer(0.2), "timeout")
		$AnimatedSprite.modulate = Color(1, 1, 1)

# Salto
func _on_React_body_exited(body):
	if body.is_in_group("Player") && player.jump:
		if is_on_floor():
			jump = true
			$AnimatedSprite.stop()
			$AnimatedSprite.frame = 1
			move.y = -401
			move = move_and_slide(move, Vector2(0, -1))

# Detecta al jugador
func _on_React_body_entered(body):
	if !follow_player:
		if body.is_in_group("Player"):
			follow_player = true

# Ataques
func _on_Area2D_area_entered(area):
	if area.is_in_group("Attack") || area.is_in_group("Explosion"):
		Dead()

func Dead():
	Change_Modulate()
	sfx_hit_enemy.play()
	$AnimatedSprite.stop()
	dead = true
	if $AnimatedSprite.flip_h:
		$AnimationPlayer.play("Dead_Left")
	else:
		$AnimationPlayer.play("Dead_Rigth")
	yield(get_tree().create_timer(0.1), "timeout")
	$Area2D/CollisionShape2D.disabled = true
	$React/CollisionShape2D.disabled = true
	$Timer_Queue.start()

func _on_Timer_Queue_timeout():
	queue_free()
