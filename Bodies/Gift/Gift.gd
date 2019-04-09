extends KinematicBody2D

var move = Vector2()
var gravity = 600
var gift01_02 = true # True 01 / False 02
var stop = false # Para detener la gravedad
var direction = false # False izquierda / True derecha

var sfx_explosion # Igual al nodo que contendra el sonido

func _ready():
	sfx_explosion = get_tree().get_nodes_in_group("SFX")[0].get_node("Explosion")
	
	gift01_02 = get_tree().get_nodes_in_group("Main")[0].gift01_02
	if !gift01_02:
		direction = get_tree().get_nodes_in_group("Main")[0].gift_direction
		stop = true
		yield(get_tree().create_timer(0.1), "timeout")
		$SFX_Gift_Launch.play()
		stop = false

func _physics_process(delta):
	if !is_on_floor() && !stop:
		move.y += gravity * delta
		if(!gift01_02 && direction):
			move.x = 600
		elif(!gift01_02 && !direction):
			move.x = -600
	else:
		move.y = 0
		move.x = 0
	
	if $AnimatedSprite.frame == 2:
		$Area_Explosion/CollisionShape2D.disabled = false
	
	move = move_and_slide(move, Vector2(0, -1))

# Deteccion de enemigos
func _on_Area2D_area_entered(area):
	if area.is_in_group("Enemy"):
		Explosion()
	if area.is_in_group("Explosion"):
		Explosion()

func Explosion():
	$Sprite.visible = false
	sfx_explosion.play()
	$AnimatedSprite.visible = true
	$AnimatedSprite.play("Explosion")
	stop = true
	$Timer.stop()
	move.x = 0
	move.y = 0
	yield($AnimatedSprite, "animation_finished")
	queue_free()

func _on_Timer_timeout():
	Explosion()
