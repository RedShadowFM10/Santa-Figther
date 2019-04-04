extends KinematicBody2D

var gravity = 600
var move = Vector2()
var speed = 350

# Estados
var dead = false
var jump = false
var has_jumped = false # Verifica si saltó o solo cae de un precipicio

var anim = false # Para verificar que se ejecute una vez la animación
var adjust = true # Para que ajuste una vez el offset, flip_h, etc

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
var throw01 = false
var throw02 = false

var offset = 50 # La distancia de dibujado entre cada Sprite del GUI

# Sprites vidas GUI
export (PackedScene) var hp_gui
export (PackedScene) var hp_empty_gui

var lives = 3 # Limite de vidas
var list_lives = [] # Contendrá las vidas instanciadas

# Sprite regalo GUI
export (PackedScene) var gift_gui

var gifts = 3 # Liimite de regalos
var list_gifts = [] # Contrendrá los regalos instanciados

func _ready():
	Create_lives()
	Create_Gifts()

func _physics_process(delta):
	if !is_on_floor(): # Si no está en el suelo
		move.y += gravity * delta
		jump = false
		if !dead: # Si está vivo
			# Ajustar las colisiones
			if kick_jump:
				Kick_Frames()
			
			if Input.is_action_pressed("N") && !anim: # Kick
				$AnimatedSprite.frame = 0
				$AnimatedSprite.play("Kick")
				kick_jump = true
				anim = true
				Anim_Jump()
			# Movimiento
			elif !has_jumped && !anim:
				$AnimatedSprite.play("Jump 01")
			if Input.is_action_pressed("Right"):
				move.x = speed
				Adjust_Right() # Llama a la funcion y ajusta
			elif Input.is_action_pressed("Left"):
				move.x = -speed
				Adjust_Left() # Llama a la funcion y ajusta
	else:
		move.y = 15 # Para evitar que rebote
		jump = true
		if !dead: # Si está vivo
			if has_jumped:
				has_jumped = false
			
			if anim: # Si está en el aire y toca el suelo depues de hacer una patada
				move.x = 0
				if kick_jump:
					Kick_Frames()
			# Ajustar las colisiones
			if punch:
				Punch_Frames()
			elif super_attack:
				Super_Attack_Frames()
			elif kick:
				Kick_Frames()
			elif gift01:
				Gift_Instance(true)
			elif gift02:
				Gift_Instance(false)
			
			if !anim: # Si no se está ejecutando una animación
				if Input.is_action_pressed("Space") && !anim: # Punch
					move.x = 0
					punch = true
					anim = true
					$AnimatedSprite.frame = 0
					if !punch01_02:
						$AnimatedSprite.play("Punch 01")
					else:
						$AnimatedSprite.play("Punch 02")
					Anim()
				elif Input.is_action_pressed("N") && !anim: # Kick
					move.x = 0
					kick = true
					anim = true
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Kick")
					Anim()
				elif Input.is_action_pressed("Down") && !anim: # Super Attack
					move.x = 0
					anim = true
					super_attack = true
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Super Attack")
					Anim()
				elif Input.is_action_pressed("B") && !anim && !throw01 && gifts >= 1: # Gift 01
					move.x = 0
					gift01 = true
					anim = true
					Delete_Gifts()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Gift 01")
					Anim()
				elif Input.is_action_pressed("V") && !anim && !throw02 && gifts >= 1: # Gift 02
					move.x = 0
					gift02 = true
					anim = true
					Delete_Gifts()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Gift 02")
					Anim()
				# Movimiento
				elif Input.is_action_pressed("Right"):
					move.x = speed
					Adjust_Right() # Llama la funcion y ajusta
					$AnimatedSprite.play("Move")
				elif Input.is_action_pressed("Left"):
					move.x = -speed
					Adjust_Left() # Llama a la funcion y ajusta
					$AnimatedSprite.play("Move")
				else:
					move.x = 0
					$AnimatedSprite.play("Idle")
				# Salto
				if Input.is_action_pressed("Up") && jump:
					move.y = -300
					$AnimatedSprite.play("Jump 02")
					has_jumped = true
	
	move = move_and_slide(move, Vector2(0, -1))

# Crea las tres vidas al iniciar el juego
func Create_lives():
	for i in lives:
		var new_hp = hp_gui.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(new_hp)
		new_hp.global_position.x += offset * i
		list_lives.append(new_hp)

func Add_Lives():
	if !lives == 3: # Limite
		var new_hp = hp_gui.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(new_hp)
		new_hp.global_position.x += offset * lives
		list_lives[lives].queue_free() # Elimina el corazon vacio en el Array
		list_lives[lives] = new_hp # El Array vacio guarda el corazon nuevo
		lives += 1

func Delete_Lives():
	if !lives == 0:
		lives -= 1
		var new_empty = hp_empty_gui.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(new_empty)
		new_empty.global_position.x += offset * lives
		list_lives[lives].queue_free() # Elimina el corazon
		list_lives[lives] = new_empty # El array vacio guarda el corazon nuevo
		if lives == 0:
			dead = true
			Dead()

func Create_Gifts():
	for i in gifts:
		var new_gift = gift_gui.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(new_gift)
		new_gift.global_position.x += offset * i
		list_gifts.append(new_gift)

func Add_Gifts():
	if !gifts == 3: # Limite
		var new_gift = gift_gui.instance()
		get_tree().get_nodes_in_group("GUI")[0].add_child(new_gift)
		new_gift.global_position.x += offset * gifts
		list_gifts[gifts] = new_gift
		gifts += 1

func Delete_Gifts():
	if !gifts == 0:
		gifts -= 1
		list_gifts[gifts].queue_free()

func Anim():
	yield($AnimatedSprite, "animation_finished")
	anim = false
	# Reinicia variables de ataques
	super_attack = false
	kick = false
	kick_jump = false
	if punch: 
		if !punch01_02: # Cambiamos entre golpe 1 y 2
			punch01_02 = true
		else:
			punch01_02 = false
		punch = false
	if gift01: # Instancia al regalo cuando acaba la animacion
		get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(true, $"Gift 01".global_position, false)
	gift01 = false

# Cuando acaba de hacer la patada en el aire
func Anim_Jump():
	yield($AnimatedSprite, "animation_finished")
	anim = false
	if !dead:
		$AnimatedSprite.play("Jump 01")

# Ajusta la posicion del Sprite y la Colision
func Adjust_Right():
	if !adjust:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
		$"Lanzar 01/Derecha".disabled = false
		$"Lanzar 01/Izquierda".disabled = true
		$"Lanzar 02/Derecha".disabled = false
		$"Lanzar 02/Izquierda".disabled = true
		adjust = true

# Ajusta la posicion del Sprite y la Colision
func Adjust_Left():
	if adjust:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -64
		$"Lanzar 01/Derecha".disabled = true
		$"Lanzar 01/Izquierda".disabled = false
		$"Lanzar 02/Derecha".disabled = true
		$"Lanzar 02/Izquierda".disabled = false
		adjust = false

func Change_Modulate():
	if $AnimatedSprite.modulate == Color(1, 1, 1):
		$AnimatedSprite.modulate = Color(10, 10, 10)
		yield(get_tree().create_timer(0.2), "timeout")
		$AnimatedSprite.modulate = Color(1, 1, 1)

func Punch_Frames():
	if $AnimatedSprite.flip_h:
		if !punch01_02: # 01
			if $AnimatedSprite.frame == 2:
				$Punch/CollisionShape2D.position = Vector2(-158.495, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true
		else: # 02
			if $AnimatedSprite.frame == 2:
				$Punch/CollisionShape2D.position = Vector2(-147.841, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true
	else:
		if !punch01_02: # 01
			if $AnimatedSprite.frame == 2:
				$Punch/CollisionShape2D.position = Vector2(-65.469, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true
		else: # 02
			if $AnimatedSprite.frame == 2:
				$Punch/CollisionShape2D.position = Vector2(-75.868, 7.108)
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true

func Kick_Frames():
	if $AnimatedSprite.flip_h:
		if $AnimatedSprite.frame == 6:
			$Kick/CollisionShape2D.position = Vector2(-148.878, 17.967)
			$Kick/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 7:
			$Kick/CollisionShape2D.disabled = true
	else:
		if $AnimatedSprite.frame == 6:
			$Kick/CollisionShape2D.position = Vector2(-74.976, 17.967)
			$Kick/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 7:
			$Kick/CollisionShape2D.disabled = true

func Super_Attack_Frames():
	if $AnimatedSprite.flip_h:
		if $AnimatedSprite.frame == 3:
			$"Super Attack/CollisionShape2D".position = Vector2(-131.171, 29.302)
			$"Super Attack/CollisionShape2D".disabled = false
		elif $AnimatedSprite.frame == 5:
			$"Super Attack/CollisionShape2D".disabled = true
	else:
		if $AnimatedSprite.frame == 3:
			$"Super Attack/CollisionShape2D".position = Vector2(-92.718, 29.302)
			$"Super Attack/CollisionShape2D".disabled = false
		elif $AnimatedSprite.frame == 5:
			$"Super Attack/CollisionShape2D".disabled = true

# Instanciar los gifts
func Gift_Instance(tipo_gift):
	if tipo_gift:
		if $AnimatedSprite.frame == 5:
			if $AnimatedSprite.flip_h:
				$"Gift 01".position = Vector2(-148, -17)
			else:
				$"Gift 01".position = Vector2(-75, -17)
	else:
		if $AnimatedSprite.frame == 1 && gift02:
			if $AnimatedSprite.flip_h:
				$"Gift 02".position = Vector2(-113, -61)
				get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(false, $"Gift 02".global_position, false)
			else:
				$"Gift 02".position = Vector2(-110, -61)
				get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(false, $"Gift 02".global_position, true)
			gift02 = false

# Deteccion de ataques e items
func _on_Area2D_area_entered(area):
	if area.is_in_group("Hearth"):
		Add_Lives()
	if area.is_in_group("Gift"):
		Add_Gifts()
	if area.is_in_group("Attack_Enemy"):
		Change_Modulate()
		Delete_Lives()
	if area.is_in_group("Explosion"):
		Change_Modulate()
		for i in lives:
			Delete_Lives()

func Dead():
	dead = true
	move.x = 0
	$AnimatedSprite.play("Dead")
	$Area2D/CollisionShape2D.disabled = true
	$Punch/CollisionShape2D.disabled = true
	$Kick/CollisionShape2D.disabled = true
	$"Super Attack/CollisionShape2D".disabled = true
	remove_from_group("Player")

# Evita que Santa lance gifts dentro de paredes
func _on_Lanzar_01_body_entered(body):
	if body.is_in_group("Floor"):
		throw01 = true

func _on_Lanzar_01_body_exited(body):
	if body.is_in_group("Floor"):
		throw01 = false

func _on_Lanzar_02_body_entered(body):
	if body.is_in_group("Floor"):
		throw02 = true

func _on_Lanzar_02_body_exited(body):
	if body.is_in_group("Floor"):
		throw02 = false
