extends KinematicBody2D

var move = Vector2()
var gravity = 600
var direction = true # false izquierda / true derecha

var adjust = true # Para que ajuste una vez el offset, flip_h, etc

var sfx_hit_enemy

# Estados
var dead = false
var idle = false
var movement = false
var react = false
var follow_player = false
var attack = false

var player # Será igual a las propiedades del Santa
var dead_santa = false # Si player esta vivo
var check = false # Para que verifique una vez

var counter = 0 # Contador para los golpes recibidos

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	sfx_hit_enemy = get_tree().get_nodes_in_group("SFX")[0].get_node("Hit_Enemy")

func _physics_process(delta):
	if !is_on_floor():
		move.y += gravity * delta
	else:
		move.y = 15 # Para evitar que rebote
		
		if !dead_santa:
			dead_santa = player.dead
		elif dead_santa && !check:
			follow_player = false
			movement = false
			$Move.start()
			Anim()
			check = true
		
		if !dead:
			if !$RayCastFloor.is_colliding(): # Deteccion de precipicios
				if follow_player:
					follow_player = false
					movement = true
					$Idle2.start()
					$React.enabled = true
				if direction:
					Adjust_Left()
				else:
					Adjust_Right()
			
			if is_on_wall(): # Deteccion de paredes
				follow_player = false
				if $AnimatedSprite.flip_h:
					Adjust_Right()
				else:
					Adjust_Left()
				movement = true
				$Idle2.start()
			
			# RayCasts
			if $Attack.is_colliding() && !attack: # Attack
				var coll = $Attack.get_collider()
				if coll.is_in_group("Player"):
					move.x = 0
					follow_player = false
					movement = false
					attack = true
					idle = true
					Stop_Timers()
					$React.enabled = false
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Attack")
					Anim()
			elif $React.is_colliding(): # React
				var coll = $React.get_collider()
				if coll.is_in_group("Player"):
					move.x = 0
					react = true
					idle = true
					movement = false
					Stop_Timers()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("React")
					Anim()
					$React.enabled = false
			
			# Ataque
			if attack:
				Attack_Frames()
			
			if follow_player && !dead_santa:
				if player.global_position.x > $Position2D.global_position.x:
					Adjust_Right()
					Move_Right()
				elif player.global_position.x < $Position2D.global_position.x:
					Adjust_Left()
					Move_Left()
			elif movement:
				if direction:
					Move_Right()
				else:
					Move_Left()
			else:
				if !idle:
					$AnimatedSprite.play("Idle")
					move.x = 0
	
	move = move_and_slide(move, Vector2(0, -1))

func Move_Right():
	move.x = 200
	$AnimatedSprite.play("Move")

func Move_Left():
	move.x = -200
	$AnimatedSprite.play("Move")

func Adjust_Right():
	if !adjust:
		direction = true
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
		$CollisionShape2D.position.x = -18.091
		# Ajustar RayCasts
		$RayCastFloor.position.x = -0.05
		$React.position.x = 112.57
		$React.rotation_degrees = -90
		$Attack.position.x = 4.841
		$Attack.rotation_degrees = -90
		adjust = true

func Adjust_Left():
	if adjust:
		direction = false
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -8
		$CollisionShape2D.position.x = -10.08
		# Ajustar RayCasts
		$RayCastFloor.position.x = -28.084
		$React.position.x = -141.941
		$React.rotation_degrees = 90
		$Attack.position.x = -37.413
		$Attack.rotation_degrees = 90
		adjust = false

func Change_Modulate():
	if $AnimatedSprite.modulate == Color(1, 1, 1):
		$AnimatedSprite.modulate = Color(10, 10, 10)
		yield(get_tree().create_timer(0.2), "timeout")
		$AnimatedSprite.modulate = Color(1, 1, 1)

func Anim():
	yield($AnimatedSprite, "animation_finished")
	if attack:
		attack = false
		follow_player = true
		if dead_santa:
			idle = false
			$Attack_Area/Right.disabled = true
			$Attack_Area/Left.disabled = true
	elif react:
		follow_player = true
		react = false
	
	if dead:
		if $AnimatedSprite.flip_h:
			$Area_Dead/CollisionShape2D.position.x = 3.284
			$Area_Dead/CollisionShape2D.disabled = false
		else:
			$Area_Dead/CollisionShape2D.position.x = -30.06
			$Area_Dead/CollisionShape2D.disabled = false
		$Revive.start()

func Attack_Frames():
	if $AnimatedSprite.frame == 4:
		$SFX_Attack.play()
	
	if $AnimatedSprite.flip_h:
		if $AnimatedSprite.frame == 7:
			$Attack_Area/Left.disabled = false
		if $AnimatedSprite.frame == 8:
			$Attack_Area/Left.disabled = true
	else:
		if $AnimatedSprite.frame == 7:
			$Attack_Area/Right.disabled = false
		if $AnimatedSprite.frame == 8:
			$Attack_Area/Right.disabled = true

# Detener Timers
func Stop_Timers():
	$Idle.stop()
	$Move.stop()
	$Idle2.stop()

# Timer para que entre al estado de Idle
func _on_Idle_timeout():
	$Move.start()
	idle = false
	movement = false

# Timer para que entre al estado de Idle (Dura menos que el Idle)
func _on_Idle2_timeout():
	idle = false
	movement = false
	$Move.start()

# Timer para que entre al estado de movimiento
func _on_Move_timeout():
	$Idle.start()
	idle = true
	movement = true

# Timer para revivir
func _on_Revive_timeout():
	$Area_Dead/CollisionShape2D.disabled = true
	counter = 0
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("Revive")
	yield($AnimatedSprite, "animation_finished")
	$Area2D/CollisionShape2D.disabled = false
	dead = false
	follow_player = false
	idle = false
	$React.enabled = true
	$Move.start()

# Deteccion de ataques
func _on_Area2D_area_entered(area):
	if area.is_in_group("Attack") && !attack:
		sfx_hit_enemy.play()
		if !follow_player:
			follow_player = true
			$React.enabled = false
	
	if area.is_in_group("Explosion"):
		Dead()
	
	if area.is_in_group("Punch"):
		Attacks_Received(0.5)
	elif area.is_in_group("Kick"):
		Attacks_Received(2)
	elif area.is_in_group("Super_Attack"):
		Attacks_Received(3)

# Area cuando cae al suelo
func _on_Area_Dead_area_entered(area):
	if area.is_in_group("Super_Attack"):
		Attacks_Received(3)
	
	if area.is_in_group("Gift"):
		Change_Modulate()
		Dead2()
	elif area.is_in_group("Explosion"):
		Change_Modulate()
		Dead2()

# Funcion para los golpes recibidos
func Attacks_Received(numero):
	sfx_hit_enemy.play()
	Change_Modulate()
	counter += numero
	if counter >= 5:
		counter = 0
		Stop_Timers()
		if dead:
			Dead2()
		else:
			Dead()

func Dead():
	sfx_hit_enemy.play()
	dead = true
	move.x = 0
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("Dead")
	yield(get_tree().create_timer(0.1), "timeout")
	$Area2D/CollisionShape2D.disabled = true
	Anim()

func Dead2():
	sfx_hit_enemy.play()
	$Area_Dead.queue_free()
	$Revive.stop()
	yield(get_tree().create_timer(2), "timeout")
	queue_free()
