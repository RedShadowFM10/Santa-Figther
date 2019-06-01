extends KinematicBody2D

var gravity = 600
var move = Vector2()
var speed = 350

var detect_enemies = false
var visibily_notifier = false # Para evitar que de la señal si se cambia nivel, ejemplo 01 a 1.1
var key = false # Si el jugador tiene la llave
var intro = true

# Estados
var dead = false
var jump = false
var has_jumped = false # Verifica si saltó o solo cae de un precipicio

var anim = false # Para verificar que se ejecute una vez la animación
var anim_jump = false
var adjust = true # Para que ajuste una vez el offset, flip_h, etc

# Ataques
var punch = false
var super_attack = false
var kick = false
var kick_jump = false
var gift01 = false
var gift02 = false

# Si puede o no usar lo ataques
var can_punch = false
var can_super_attack = false
var can_kick = false
var can_gift = false
var can_jump = false

# Verifica el tipo de puñetazo
var punch01_02 = false # false Punch 01 / true Punch 02

# Verifica el tipo de regalo que se lanza
var throw01 = false
var throw02 = false

var offset = 50 # La distancia de dibujado entre cada Sprite del GUI

# Clamp
var clamp_min = 158
var clamp_max = 999999999

# Si sale de la pantalla
var off_screen = false

# Sprites vidas GUI
export (PackedScene) var hp_gui
export (PackedScene) var hp_empty_gui

var lives = 3 # Limite de vidas
var list_lives = [] # Contendrá las vidas instanciadas

# Sprite regalo GUI
export (PackedScene) var gift_gui

var gui_gift = false
var gifts = 3 # Liimite de regalos
var list_gifts = [] # Contrendrá los regalos instanciados

func _ready():
	get_tree().get_nodes_in_group("Main")[0].santa_intro = false
	Create_lives()
	gui_gift = Global.gui_gift
	if gui_gift:
		Create_Gifts()
	# Saber que ataques puede usar
	can_punch = Global.can_punch
	can_super_attack = Global.can_super_attack
	can_kick = Global.can_kick
	can_gift = Global.can_gift

func _physics_process(delta):
	global_position.x = clamp(global_position.x, clamp_min, clamp_max)
	
	if !is_on_floor(): # Si no está en el suelo
		if !off_screen:
			move.y += gravity * delta
		if !jump: # Para evitar que caiga demaisado rapido
			move.y = 1
			jump = true
		if !dead && lives > 0 && !intro: # Si está vivo
			# Ajustar las colisiones
			if kick_jump:
				Kick_Frames()
			
			if Input.is_action_pressed("N") && !anim && can_kick: # Kick
				$SFX_Kick.play()
				$AnimatedSprite.frame = 0
				$AnimatedSprite.play("Kick")
				kick_jump = true
				anim = true
				anim_jump = true
#				Anim_Jump()
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
		if !off_screen:
			move.y = 1000 # Para evitar que rebote
		jump = false
		if !dead && lives > 0 && !intro: # Si está vivo
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
				if Input.is_action_pressed("Space") && can_punch: # Punch
					$SFX_Punch.play()
					move.x = 0
					punch = true
					anim = true
					$AnimatedSprite.frame = 0
					if !punch01_02:
						$AnimatedSprite.play("Punch 01")
					else:
						$AnimatedSprite.play("Punch 02")
				elif Input.is_action_pressed("N") && can_kick: # Kick
					$SFX_Kick.play()
					move.x = 0
					kick = true
					anim = true
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Kick")
				elif Input.is_action_pressed("Down") && can_super_attack: # Super Attack
					move.x = 0
					anim = true
					super_attack = true
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Super Attack")
				elif Input.is_action_pressed("B") && !throw01 && gifts >= 1 && can_gift: # Gift 01
					move.x = 0
					gift01 = true
					anim = true
					Delete_Gifts()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Gift 01")
				elif Input.is_action_pressed("V") && !throw02 && gifts >= 1 && can_gift: # Gift 02
					move.x = 0
					gift02 = true
					anim = true
					Delete_Gifts()
					$AnimatedSprite.frame = 0
					$AnimatedSprite.play("Gift 02")
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
				if Input.is_action_pressed("Up") && !can_jump:
					jump = true
					move.y = -300
					$AnimatedSprite.play("Jump 02")
					has_jumped = true
		else:
			move.x = 0
	move = move_and_slide(move, Vector2(0, -1))

# Crea las tres vidas al iniciar el juego
func Create_lives():
	for i in lives:
		var new_hp = hp_gui.instance()
		$GUI.add_child(new_hp)
		new_hp.global_position.x += offset * i
		list_lives.append(new_hp)

func Add_Lives():
	$SFX_Take_Item.play()
	if lives < 3 && !dead: # Limite
		var new_hp = hp_gui.instance()
		$GUI.add_child(new_hp)
		new_hp.global_position.x += offset * lives
		list_lives[lives].queue_free() # Elimina el corazon vacio en el Array
		list_lives[lives] = new_hp # El Array vacio guarda el corazon nuevo
		lives += 1

func Delete_Lives():
	if lives > 0:
		lives -= 1
		var new_empty = hp_empty_gui.instance()
		$GUI.add_child(new_empty)
		new_empty.global_position.x += offset * lives
		list_lives[lives].queue_free() # Elimina el corazon
		list_lives[lives] = new_empty # El array vacio guarda el corazon nuevo
		if lives == 0:
			dead = true
			Dead()

func Create_Gifts():
	for i in gifts:
		var new_gift = gift_gui.instance()
		$GUI.add_child(new_gift)
		new_gift.global_position.x += offset * i
		list_gifts.append(new_gift)

func Add_Gifts():
	$SFX_Take_Item.play()
	if gifts < 3 && !dead: # Limite
		var new_gift = gift_gui.instance()
		$GUI.add_child(new_gift)
		new_gift.global_position.x += offset * gifts
		list_gifts[gifts] = new_gift
		gifts += 1

func Delete_Gifts():
	if gifts > 0:
		gifts -= 1
		list_gifts[gifts].queue_free()

# Señal al finalizar animacion
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.get_animation() != "Idle":
		anim = false
		# Reinicia variables de ataques
		super_attack = false
		kick = false
		kick_jump = false
		if punch:
			punch01_02 = !punch01_02 # Cambiamos entre golpe 1 y 2
			punch = false
		elif anim_jump:
			anim = false
			if !dead:
				$AnimatedSprite.play("Jump 01")
		elif gift01: # Instancia al regalo cuando acaba la animacion
			get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(true, $Gift_01.global_position, false)
		gift01 = false

# Ajusta la posicion del Sprite y la Colision
func Adjust_Right():
	if !adjust:
		$Area2D/CollisionShape2D.position.x = -124
		$Area_Items/CollisionShape2D.position.x = -124
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
		$Lanzar_01/Right.disabled = false
		$Lanzar_01/Left.disabled = true
		$Lanzar_02/Right.disabled = false
		$Lanzar_02/Left.disabled = true
		adjust = true

# Ajusta la posicion del Sprite y la Colision
func Adjust_Left():
	if adjust:
		$Area2D/CollisionShape2D.position.x = -100
		$Area_Items/CollisionShape2D.position.x = -100
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -64
		$Lanzar_01/Right.disabled = true
		$Lanzar_01/Left.disabled = false
		$Lanzar_02/Right.disabled = true
		$Lanzar_02/Left.disabled = false
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
				$Punch/CollisionShape2D.position.x = -158.495
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true
		else: # 02
			if $AnimatedSprite.frame == 2:
				$Punch/CollisionShape2D.position.x = -147.841
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true
	else:
		if !punch01_02: # 01
			if $AnimatedSprite.frame == 2:
				$Punch/CollisionShape2D.position.x = -65.469
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true
		else: # 02
			if $AnimatedSprite.frame == 2:
				$Punch/CollisionShape2D.position.x = -75.868
				$Punch/CollisionShape2D.disabled = false
			elif $AnimatedSprite.frame == 4:
				$Punch/CollisionShape2D.disabled = true

func Kick_Frames():
	if $AnimatedSprite.flip_h:
		if $AnimatedSprite.frame == 4:
			$Kick/CollisionShape2D.position.x = -136.2
			$Kick/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 7:
			$Kick/CollisionShape2D.disabled = true
	else:
		if $AnimatedSprite.frame == 4:
			$Kick/CollisionShape2D.position.x = -88.134
			$Kick/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 7:
			$Kick/CollisionShape2D.disabled = true

func Super_Attack_Frames():
	if $AnimatedSprite.flip_h:
		if $AnimatedSprite.frame == 3:
			$SFX_Super_Attack.play()
			$Super_Attack/CollisionShape2D.position.x = -131.171
			$Super_Attack/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 4:
			$Super_Attack/CollisionShape2D.position.x = -116.736
		elif $AnimatedSprite.frame == 6:
			$Super_Attack/CollisionShape2D.disabled = true
	else:
		if $AnimatedSprite.frame == 3:
			$SFX_Super_Attack.play()
			$Super_Attack/CollisionShape2D.position.x = -92.718
			$Super_Attack/CollisionShape2D.disabled = false
		elif $AnimatedSprite.frame == 4:
			$Super_Attack/CollisionShape2D.position.x = -105.982
		elif $AnimatedSprite.frame == 6:
			$Super_Attack/CollisionShape2D.disabled = true

# Instanciar los gifts
func Gift_Instance(tipo_gift):
	if tipo_gift:
		if $AnimatedSprite.frame == 5:
			if $AnimatedSprite.flip_h:
				$Gift_01.position.x = -148
			else:
				$Gift_01.position.x = -75
	else:
		if $AnimatedSprite.frame == 1 && gift02:
			if $AnimatedSprite.flip_h:
				$Gift_02.position.x = -113
				get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(false, $Gift_02.global_position, false)
			else:
				$Gift_02.position.x = -110
				get_tree().get_nodes_in_group("Main")[0].Gift_Instaciar(false, $Gift_02.global_position, true)
			gift02 = false

# Deteccion de ataques
func _on_Area2D_area_entered(area):
	if area.is_in_group("Attack_Enemy") && !detect_enemies:
		$SFX_Hit_Player.play()
		Change_Modulate()
		Delete_Lives()
		yield(get_tree().create_timer(0.1), "timeout")
		$Area2D/CollisionShape2D.disabled = true
		$Area2D/Disable_Coll.start()
	if area.is_in_group("Explosion"):
		$SFX_Hit_Player.play()
		Change_Modulate()
		for i in lives:
			Delete_Lives()

func Dead():
	dead = true
	get_tree().get_nodes_in_group("Main")[0].Santa_Dead()
	if is_on_floor():
		move.x = 0
	$AnimatedSprite.play("Dead")
	remove_from_group("Player")
	yield(get_tree().create_timer(0.1), "timeout")
	$Area2D/CollisionShape2D.disabled = true
	$Punch/CollisionShape2D.disabled = true
	$Kick/CollisionShape2D.disabled = true
	$Super_Attack/CollisionShape2D.disabled = true
	$Area_Items/CollisionShape2D.disabled = true

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

func _on_Disable_Coll_timeout():
	if !dead:
		$Area2D/CollisionShape2D.disabled = false

# Si sale de la pantalla
func _on_VisibilityNotifier2D_screen_exited():
	if !visibily_notifier && !intro:
		off_screen = true
		dead = true
		lives = 0
		move.x = 0
		move.y = 0
		get_tree().get_nodes_in_group("Main")[0].Santa_Dead()

# Timer para el notifer
func _on_Timer_timeout():
	intro = false

func _on_Area_Items_body_entered(body):
	if gifts > 0 && body.is_in_group("Platform"):
		can_gift = false

func _on_Area_Items_body_exited(body):
	if gui_gift && body.is_in_group("Platform"):
		can_gift = true
