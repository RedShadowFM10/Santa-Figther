extends KinematicBody2D

var move = Vector2()
var gravity = 600
var direction = true # false izquierda / true derecha

var adjust = false # Para que ajuste una vez el flip_h, offset, etc

var player # Será igual a las propiedades del player

var sfx_frog

export (PackedScene) var heart_item
export (PackedScene) var gift_item

func _ready():
	sfx_frog = get_tree().get_nodes_in_group("SFX")[0].get_node("Frog")

func _physics_process(delta):
	if !is_on_floor():
		if !$RayCastFloor.is_colliding():
			direction = !direction
			Adjust()
			Move_Direction()
		move.y += gravity * delta
	else:
		move.y = 0
		move.x = 0
	
	if is_on_wall():
		direction = !direction
		Adjust()
		Move_Direction()
	
	move = move_and_slide(move, Vector2(0, -1))

func Adjust():
	if adjust:
		$AnimatedSprite.flip_h = false
		$RayCastFloor.position.x = 55
		adjust = false
	else:
		$AnimatedSprite.flip_h = true
		$RayCastFloor.position.x = -55
		adjust = true

func _on_Jump_timeout():
	move.y = -150
	Move_Direction()
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("Jump")

func Move_Direction():
	if direction:
		move.x = 150
	else:
		move.x = -150
	move = move_and_slide(move)

func _on_Area2D_area_entered(area):
	if area.is_in_group("Attack") || area.is_in_group("Explosion") || area.is_in_group("Attack_Enemy2"):
		sfx_frog.play()
		if player.lives <= player.gifts || player.lives == 1:
			var new_heart = heart_item.instance()
			get_tree().get_nodes_in_group("Level")[0].call_deferred("add_child", new_heart)
			new_heart.global_position = global_position
		else:
			var new_gift = gift_item.instance()
			get_tree().get_nodes_in_group("Level")[0].call_deferred("add_child", new_gift)
			new_gift.global_position = global_position
		queue_free()

func _on_Ready_timeout():
	player = get_tree().get_nodes_in_group("Player")[0]
