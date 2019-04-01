extends KinematicBody2D

var move = Vector2()
var gravedad = 600
var direccion = true # false izquierda / true derecha

var ajustar = true # Para que ajuste una vez el offset, flip_h, etc

# Estados
var dead = true
var idle = false
var moverse = false
var react = false
var seguir_player = false
var attack = false

var santa # Será igual a las propiedades del Santa
var dead_santa = false # Si santa esta vivo
var verificar = false # Para que verifique una vez

var contador = 0 # Contador para los golpes recibidos

func _ready():
	santa = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	if(!is_on_floor()):
		move.y += gravedad * delta
	else:
		move.y = 15 # Para evitar que rebote
		
		if(!dead_santa):
			dead_santa = santa.dead
		elif(dead_santa && !verificar):
			seguir_player = false
			moverse = false
			idle = false
			$Move.start()
			verificar = true
		
		if(!dead):
			if(!$RayCastSuelo.is_colliding()): # Deteccion de precipicios
				if(seguir_player):
					seguir_player = false
					moverse = true
					$Idle2.start()
					$React.enabled = true
				if(direccion):
					Ajustar_Izquierda()
				else:
					Ajustar_Derecha()
			
			if(is_on_wall()): # Deteccion de paredes
				seguir_player = false
				if($AnimatedSprite.flip_h):
					Ajustar_Derecha()
				else:
					Ajustar_Izquierda()
				moverse = true
				$Idle2.start()
			
			# RayCasts
			if($Attack.is_colliding() && !attack): # Attack
				var coll = $Attack.get_collider()
				if(coll.is_in_group("Player")):
					move.x = 0
					seguir_player = false
					moverse = false
					attack = true
					idle = true
					Stop_Timers()
					$React.enabled = false
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Attack")
					anim()
			elif($React.is_colliding()): # React
				var coll = $React.get_collider()
				if(coll.is_in_group("Player")):
					move.x = 0
					react = true
					idle = true
					moverse = false
					Stop_Timers()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("React")
					anim()
					$React.enabled = false
			
			# Ataque
			if(attack):
				Attack_Frames()
			
			if(seguir_player && !dead_santa):
				if(santa.global_position.x > $Position2D.global_position.x):
					Ajustar_Derecha()
					Mover_Derecha()
				elif(santa.global_position.x < $Position2D.global_position.x):
					Ajustar_Izquierda()
					Mover_Izquierda()
			elif(moverse):
				if(direccion):
					Mover_Derecha()
				else:
					Mover_Izquierda()
			else:
				if(!idle):
					$AnimatedSprite.play("Idle")
					move.x = 0
	
	move_and_slide(move, Vector2(0, -1))

func Mover_Derecha():
	move.x = 200
	$AnimatedSprite.play("Move")

func Mover_Izquierda():
	move.x = -200
	$AnimatedSprite.play("Move")

func Ajustar_Derecha():
	if(!ajustar):
		direccion = true
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
		$CollisionShape2D.position = Vector2(-18.091, 28.057)
		# Ajustar RayCasts
		$RayCastSuelo.position = Vector2(-0.05, 76.153)
		$React.position = Vector2(112.57, -2.86)
		$React.rotation_degrees = -90
		$Attack.position = Vector2(4.841, 3.634)
		$Attack.rotation_degrees = -90
		ajustar = true

func Ajustar_Izquierda():
	if(ajustar):
		direccion = false
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -8
		$CollisionShape2D.position = Vector2(-10.08, 28.057)
		# Ajustar RayCasts
		$RayCastSuelo.position = Vector2(-28.084, 76.153)
		$React.position = Vector2(-141.941, -2.86)
		$React.rotation_degrees = 90
		$Attack.position = Vector2(-37.413, 3.634)
		$Attack.rotation_degrees = 90
		ajustar = false

func anim():
	yield($AnimatedSprite, "animation_finished")
	if(attack):
		attack = false
		seguir_player = true
	elif(react):
		seguir_player = true
		react = false
	
	if(dead):
		if($AnimatedSprite.flip_h):
			$Area_Muerte/CollisionShape2D.position = Vector2(3.284, 70.533)
			$Area_Muerte/CollisionShape2D.disabled = false
		else:
			$Area_Muerte/CollisionShape2D.position = Vector2(-30.06, 70.533)
			$Area_Muerte/CollisionShape2D.disabled = false
		$Revivir.start()

func Attack_Frames():
	if($AnimatedSprite.flip_h):
		if($AnimatedSprite.frame == 7):
			$Ataque/Izquierda.disabled = false
		if($AnimatedSprite.frame == 8):
			$Ataque/Izquierda.disabled = true
	else:
		if($AnimatedSprite.frame == 7):
			$Ataque/Derecha.disabled = false
		if($AnimatedSprite.frame == 8):
			$Ataque/Derecha.disabled = true

# Detener Timers
func Stop_Timers():
	$Idle.stop()
	$Move.stop()
	$Idle2.stop()

# Timer para que entre al estado de Idle
func _on_Idle_timeout():
	$Move.start()
	idle = false
	moverse = false

# Timer para que entre al estado de Idle (Dura menos que el Idle)
func _on_Idle2_timeout():
	idle = false
	moverse = false
	$Move.start()

# Timer para que entre al estado de movimiento
func _on_Move_timeout():
	$Idle.start()
	idle = true
	moverse = true

# Timer para revivir
func _on_Revivir_timeout():
	$Area_Muerte/CollisionShape2D.disabled = true
	contador = 0
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("Revive")
	yield($AnimatedSprite, "animation_finished")
	$Area2D/CollisionShape2D.disabled = false
	dead = false
	seguir_player = false
	idle = false
	$React.enabled = true
	$Move.start()

# Deteccion de ataques
func _on_Area2D_area_entered(area):
	if(area.is_in_group("Ataque") && !attack):
		if(!seguir_player):
			seguir_player = true
			$React.enabled = false
	
	if(area.is_in_group("Regalo")):
		morir()
	
	if(area.is_in_group("Punch")):
		Ataques_Recibidos(0.5)
	elif(area.is_in_group("Kick")):
		Ataques_Recibidos(2)
	elif(area.is_in_group("Super Attack")):
		Ataques_Recibidos(3)

# Area cuando cae al suelo
func _on_Area_Muerte_area_entered(area):
	if(area.is_in_group("Super Attack")):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("Hit Dead")
		Ataques_Recibidos(3)
	
	if(area.is_in_group("Regalo")):
		morir2()

# Funcion para los golpes recibidos
func Ataques_Recibidos(numero):
	contador += numero
	if(contador >= 5):
		contador = 0
		Stop_Timers()
		if(dead):
			morir2()
		else:
			morir()

func morir():
	dead = true
	move.x = 0
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("Dead")
	yield(get_tree().create_timer(0.1), "timeout")
	$Area2D/CollisionShape2D.disabled = true
	anim()

func morir2():
	$Area_Muerte.queue_free()
	$Revivir.stop()
	yield(get_tree().create_timer(2), "timeout")
	queue_free()
