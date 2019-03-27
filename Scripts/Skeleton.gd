extends KinematicBody2D

var move = Vector2()
var gravedad = 600

var ajustar = true # Para que ajuste una vez el offset, flip_h, etc

# Estados
var dead = false


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
	
	move_and_slide(move, Vector2(0, -1))

func Ajustar_Derecha():
	if(!ajustar):
		$AnimatedSprite.offset.x = 0
		$CollisionShape2D.position = Vector2(-18.091, 28.057)
		ajustar = true

func Ajustar_Izquierda():
	if(ajustar):
		$AnimatedSprite.offset.x = -8
		$CollisionShape2D.position = Vector2(-10.08, 28.057)
		ajustar = false