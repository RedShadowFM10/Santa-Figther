extends KinematicBody2D

var gravedad = 600
var move = Vector2()
var speed = 350

# Estados
var dead = false
var jump = false
var ha_saltado = false # Verifica si saltó o solo cae de un precipicio

var anim = false # Para verificar que se ejecute una vez la animación
var ajustar = true # Para que ajuste una vez el offset, flip_h, etc

# Ataques
var punch = false
var super_attack = false
var kick = false
var kick_jump = false
var gift01 = false
var gift02 = false

# Verifica el tipo de puñetazo
var punch01_02 = false # false Punch 01 / true Punch 02

# Verifica el tipo de regalo que se lanza
var lanzar01 = false
var lanzar02 = false

var offset = 50 # La distancia de dibujado entre cada Sprite

# Sprites vidas
export (PackedScene) var Sprite_Vidas
export (PackedScene) var Sprite_Empty

var vidas = 3 # Limite de vidas
var lista_vidas = [] # Contendrá las vidas instanciadas

# Sprite regalo
export (PackedScene) var regalo_gui

var regalos = 3
var lista_regalos = []

func _ready():
	crear_vidas()
	crear_regalos()

func _physics_process(delta):
	if !is_on_floor()): # Si no está en el suelo
		move.y += gravedad * delta
		jump = false
		if !dead): # Si está vivo
			# Ajustar las colisiones
			if(kick_jump):
				Kick_Frames()
			
			if(Input.is_action_pressed("N") && !anim): # Kick
				$AnimatedSprite.frame = 0
				$AnimatedSprite.play("Kick")
				kick_jump = true
				anim = true
				anim_salto()
			# Movimiento
			elif !ha_saltado && !anim):
				$AnimatedSprite.play("Jump 01")
			if(Input.is_action_pressed("Derecha")):
				move.x = speed
				Ajustar_Derecha() # Llama la funcion
			elif(Input.is_action_pressed("Izquierda")):
				move.x = -speed
				Ajustar_Izquierda() # Llama a la funcion
	else:
		move.y = 15 # Para evitar que rebote
		jump = true
		if !dead): # Si está vivo
			if(ha_saltado):
				ha_saltado = false
			
			if(anim): # Si está en el aire y toca el suelo depues de hacer una patada
				move.x = 0
				if(kick_jump):
					Kick_Frames()
			# Ajustar las colisiones
			if(punch):
				Punch_Frames()
			elif(super_attack):
				Super_Attack_Frames()
			elif(kick):
				Kick_Frames()
			elif(gift01):
				Gift_Instanciar(true)
			elif(gift02):
				Gift_Instanciar(false)
			
			if !anim): # Si no se está ejecutando una animación
				if(Input.is_action_pressed("Space") && !anim): # Punch
					move.x = 0
					punch = true
					anim = true
					$AnimatedSprite.frame = 0
					if !punch01_02):
						$AnimatedSprite.play("Punch 01")
					else:
						$AnimatedSprite.play("Punch 02")
					anim()
				elif(Input.is_action_pressed("N") && !anim): # Kick
					move.x = 0
					kick = true
					anim = true
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Kick")
					anim()
				elif(Input.is_action_pressed("Abajo") && !anim): # Super Attack
					move.x = 0
					anim = true
					super_attack = true
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Super Attack")
					anim()
				elif(Input.is_action_pressed("B") && !anim && !lanzar01 && regalos >= 1): # Gift 01
					move.x = 0
					gift01 = true
					anim = true
					eliminar_regalos()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Gift 01")
					anim()
				elif(Input.is_action_pressed("V") && !anim && !lanzar02 && regalos >= 1): # Gift 02
					move.x = 0
					gift02 = true
					anim = true
					eliminar_regalos()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Gift 02")
					anim()
				# Movimiento
				elif(Input.is_action_pressed("Derecha")):
					move.x = speed
					Ajustar_Derecha() # Llama la funcion
					$AnimatedSprite.play("Move")
				elif(Input.is_action_pressed("Izquierda")):
					move.x = -speed
					Ajustar_Izquierda() # Llama a la funcion
					$AnimatedSprite.play("Move")
				else:
					move.x = 0
					$AnimatedSprite.play("Idle")
				# Salto
				if(Input.is_action_pressed("Arriba") && jump):
					move.y = -300
					$AnimatedSprite.play("Jump 02")
					ha_saltado = true
	
	move_and_slide(move, Vector2(0, -1))

# Crea las tres vidas al iniciar el juego
func crear_vidas():
	for i in vidas:
		var newVida = Sprite_Vidas.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(newVida)
		newVida.global_position.x += offset * i
		lista_vidas.append(newVida)

func agregar_vidas():
	if !vidas == 3): # Limite
		var newVida = Sprite_Vidas.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(newVida)
		newVida.global_position.x += offset * vidas
		lista_vidas[vidas].queue_free() # Elimina el corazon vacio en el Array
		lista_vidas[vidas] = newVida # El Array vacio guarda el corazon nuevo
		vidas += 1

func eliminar_vidas():
	if !vidas == 0):
		vidas -= 1
		var newEmpty = Sprite_Empty.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(newEmpty)
		newEmpty.global_position.x += offset * vidas
		lista_vidas[vidas].queue_free() # Elimina el corazon
		lista_vidas[vidas] = newEmpty # El array vacio guarda el corazon nuevo
		if(vidas == 0):
			dead = true
			dead()

func crear_regalos():
	for i in regalos:
		var newRegalo = regalo_gui.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(newRegalo)
		newRegalo.global_position.x += offset * i
		lista_regalos.append(newRegalo)

func agregar_regalos():
	if !regalos == 3): # Limite
		var newRegalo = regalo_gui.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(newRegalo)
		newRegalo.global_position.x += offset * regalos
		lista_regalos[regalos] = newRegalo
		regalos += 1

func eliminar_regalos():
	if !regalos == 0):
		regalos -= 1
		lista_regalos[regalos].queue_free()

func anim():
	yield($AnimatedSprite, "animation_finished")
	anim = false
	# Reinicia variables de ataques
	super_attack = false
	kick = false
	kick_jump = false
	if(punch): 
		if !punch01_02): # Cambiamos entre golpe 1 y 2
			punch01_02 = true
		else:
			punch01_02 = false
		punch = false
	if(gift01): # Instancia al regalo cuando acaba la animacion
		get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(true, $"Gift 01".global_position, false)
	gift01 = false

# Cuando acaba de hacer la patada en el aire
func anim_salto():
	yield($AnimatedSprite, "animation_finished")
	anim = false
	$AnimatedSprite.play("Jump 01")

# Ajusta la posicion del Sprite y la Colision
func Ajustar_Derecha():
	if !ajustar):
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
		$"Lanzar 01/Derecha".disabled = false
		$"Lanzar 01/Izquierda".disabled = true
		$"Lanzar 02/Derecha".disabled = false
		$"Lanzar 02/Izquierda".disabled = true
		ajustar = true

# Ajusta la posicion del Sprite y la Colision
func Ajustar_Izquierda():
	if(ajustar):
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -64
		$"Lanzar 01/Derecha".disabled = true
		$"Lanzar 01/Izquierda".disabled = false
		$"Lanzar 02/Derecha".disabled = true
		$"Lanzar 02/Izquierda".disabled = false
		ajustar = false

func cambiar_modulate():
	if $AnimatedSprite.modulate == Color(1, 1, 1)):
		$AnimatedSprite.modulate = Color(10, 10, 10)
		yield(get_tree().create_timer(0.2), "timeout")
		$AnimatedSprite.modulate = Color(1, 1, 1)

func Punch_Frames():
	if $AnimatedSprite.flip_h):
		if !punch01_02): # 01
			if $AnimatedSprite.frame == 2):
				$Punch/CollisionShape2D.position = Vector2(-158.495, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4):
				$Punch/CollisionShape2D.disabled = true
		else: # 02
			if $AnimatedSprite.frame == 2):
				$Punch/CollisionShape2D.position = Vector2(-147.841, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4):
				$Punch/CollisionShape2D.disabled = true
	else:
		if !punch01_02): # 01
			if $AnimatedSprite.frame == 2):
				$Punch/CollisionShape2D.position = Vector2(-65.469, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4):
				$Punch/CollisionShape2D.disabled = true
		else: # 02
			if $AnimatedSprite.frame == 2):
				$Punch/CollisionShape2D.position = Vector2(-75.868, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4):
				$Punch/CollisionShape2D.disabled = true

func Kick_Frames():
	if $AnimatedSprite.flip_h):
		if $AnimatedSprite.frame == 6):
			$Kick/CollisionShape2D.position = Vector2(-148.878, 17.967)
			$Kick/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 7):
			$Kick/CollisionShape2D.disabled = true
	else:
		if $AnimatedSprite.frame == 6):
			$Kick/CollisionShape2D.position = Vector2(-74.976, 17.967)
			$Kick/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 7):
			$Kick/CollisionShape2D.disabled = true

func Super_Attack_Frames():
	if $AnimatedSprite.flip_h):
		if $AnimatedSprite.frame == 3):
			$"Super Attack/CollisionShape2D".position = Vector2(-131.171, 29.302)
			$"Super Attack/CollisionShape2D".disabled = false
		elif $AnimatedSprite.frame == 5):
			$"Super Attack/CollisionShape2D".disabled = true
	else:
		if $AnimatedSprite.frame == 3):
			$"Super Attack/CollisionShape2D".position = Vector2(-92.718, 29.302)
			$"Super Attack/CollisionShape2D".disabled = false
		elif $AnimatedSprite.frame == 5):
			$"Super Attack/CollisionShape2D".disabled = true

# Instanciar los regalos
func Gift_Instanciar(var tipo_gift):
	if(tipo_gift):
		if $AnimatedSprite.frame == 5):
			if $AnimatedSprite.flip_h):
				$"Gift 01".position = Vector2(-148, -17)
			else:
				$"Gift 01".position = Vector2(-75, -17)
	else:
		if $AnimatedSprite.frame == 1 && gift02):
			if $AnimatedSprite.flip_h):
				$"Gift 02".position = Vector2(-113, -61)
				get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(false, $"Gift 02".global_position, false)
			else:
				$"Gift 02".position = Vector2(-110, -61)
				get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(false, $"Gift 02".global_position, true)
			gift02 = false

# Deteccion de ataques e items
func _on_Area2D_area_entered(area):
	if(area.is_in_group("HP")):
		agregar_vidas()
	if(area.is_in_group("Gift")):
		agregar_regalos()
	if(area.is_in_group("Ataque Enemigo")):
		cambiar_modulate()
		eliminar_vidas()
	if(area.is_in_group("Explosion")):
		cambiar_modulate()
		for i in vidas:
			eliminar_vidas()

func dead():
	dead = true
	move.x = 0
	$AnimatedSprite.play("Dead")
	$Area2D/CollisionShape2D.disabled = true
	$Punch/CollisionShape2D.disabled = true
	$Kick/CollisionShape2D.disabled = true
	$"Super Attack/CollisionShape2D".disabled = true
	remove_from_group("Player")

# Evita que Santa lance regalos dentro de paredes
func _on_Lanzar_01_body_entered(body):
	if(body.is_in_group("Suelo")):
		lanzar01 = true

func _on_Lanzar_01_body_exited(body):
	if(body.is_in_group("Suelo")):
		lanzar01 = false

func _on_Lanzar_02_body_entered(body):
	if(body.is_in_group("Suelo")):
		lanzar02 = true

func _on_Lanzar_02_body_exited(body):
	if(body.is_in_group("Suelo")):
		lanzar02 = false
