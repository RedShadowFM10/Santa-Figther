extends StaticBody2D

var count = 0

var player

export (PackedScene) var heart_item
export (PackedScene) var gift_item

var sfx_object_destroy
var sfx_hit_item

func _on_Area2D_area_entered(area):
	if area.is_in_group("Attack"):
		count += 1
		if count < 6:
			$AnimatedSprite.frame = 0
			$AnimatedSprite.play("Hit")
			sfx_hit_item.play()
		elif count == 6:
			count = 7
			if player.lives <= player.gifts || player.lives == 1:
				var new_heart = heart_item.instance()
				get_tree().get_nodes_in_group("Level")[0].call_deferred("add_child", new_heart)
				new_heart.global_position = $Position2D.global_position
			else:
				var new_gift = gift_item.instance()
				get_tree().get_nodes_in_group("Level")[0].call_deferred("add_child", new_gift)
				new_gift.global_position = $Position2D.global_position
			$AnimatedSprite.play("Destroy")
			sfx_object_destroy.play()
			yield(get_tree().create_timer(0.1), "timeout")
			$Area2D/CollisionShape2D.disabled = true

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.get_animation() == "Destroy":
		queue_free()

func _on_Ready_timeout():
	player = get_tree().get_nodes_in_group("Player")[0]
	sfx_object_destroy = get_tree().get_nodes_in_group("SFX")[0].get_node("Object_Destroy")
	sfx_hit_item = get_tree().get_nodes_in_group("SFX")[0].get_node("Hit_Item")
