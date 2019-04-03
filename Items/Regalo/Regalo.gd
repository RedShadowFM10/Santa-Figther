extends KinematicBody2D

var move = Vector2()
var gravedad = 600
var gift01_02 = true # True 01 / False 02
var detener = false
var direccion = false # False izquierda / True derecha

var explotar = false

func _ready():
	gift01_02 = get_tree().get_nodes_in_group("Main")[0].gift01_02
	if(!gift01_02):
		direccion = get_tree().get_nodes_in_group("Main")[0].gift_direccion
		detener = true
		yield(get_tree().create_timer(0.1), "timeout")
		detener = false

func _physics_process(delta):
	if(!is_on_floor() && !detener):
		move.y += gravedad * delta
		if(!gift01_02 && direccion):
			move.x = 600
		elif(!gift01_02 && !direccion):
			move.x = -600
	else:
		move.y = 0
		move.x = 0
	
	if($AnimatedSprite.frame == 3):
		$Area_Explosion/CollisionShape2D.disabled = false
	
	move_and_slide(move, Vector2(0, -1))

# Deteccion de enemigos
func _on_Area2D_area_entered(area):
	if(area.is_in_group("Enemigo")):
		explotar()

func explotar():
	detener = true
	$Timer.stop()
	move.x = 0
	move.y = 0
	$Sprite.visible = false
	$AnimatedSprite.play("Explosion")
	yield($AnimatedSprite, "animation_finished")
	queue_free()

func _on_Timer_timeout():
	explotar()
