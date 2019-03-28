extends KinematicBody2D

var move = Vector2()
var gravedad = 600

var dimension
var ajustar = true # Para que ajuste una vez el offset, flip_h, etc

# Estados
var dead = false
var direccion = true # false izquierda / true derecha

var santa # Será igual a las propiedades del Santa

func _ready():
	santa = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	if(!is_on_floor()):
		move.y += gravedad * delta
		if(!dead):
			$AnimatedSprite.play("Fall")
	else:
		move.y = 0
		if(!dead):
			if(is_on_wall()): # Deteccion de paredes
				if($AnimatedSprite.flip_h):
					Ajustar_Derecha()
				else:
					Ajustar_Izquierda()
			
			if(direccion):
				move.x = 200
			else:
				move.x = -200
#
#			dimension = transform
#			dimension[2].x += 55 / 2
#
#			if(!test_move(dimension, Vector2(0, 1))):
#				direccion = false
	
	move_and_slide(move, Vector2(0, -1))

func Ajustar_Derecha():
	if(!ajustar):
		direccion = true
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.offset.x = 0
		$CollisionShape2D.position = Vector2(-18.091, 28.057)
		ajustar = true

func Ajustar_Izquierda():
	if(ajustar):
		direccion = false
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.offset.x = -8
		$CollisionShape2D.position = Vector2(-10.08, 28.057)
		ajustar = false