extends Area2D

var count = 0

var hit_anim = false

var sfx_object_destroy
var sfx_hit_item

func _ready():
	sfx_object_destroy = get_tree().get_nodes_in_group("SFX")[0].get_node("Object_Destroy")
	sfx_hit_item = get_tree().get_nodes_in_group("SFX")[0].get_node("Hit_Item")

func _physics_process(_delta):
	if hit_anim:
		if $AnimatedSprite.frame == 1:
			$Label.margin_top = -22
			$Label.margin_bottom = 28
		elif $AnimatedSprite.frame == 2:
			$Label.margin_top = -32
			$Label.margin_bottom = 18

func _on_Hit_area_entered(area):
	if count < 7 && area.is_in_group("Attack"):
		count += 1
		$AnimatedSprite.frame = 0
		if count <= 5:
			$AnimatedSprite.play("Hit")
			sfx_hit_item.play()
			hit_anim = true
		elif count == 6:
			$AnimatedSprite.play("Destroy")
			sfx_object_destroy.play()
			count = 7
			yield(get_tree().create_timer(0.1), "timeout")
			$CollisionShape2D.disabled = true
			$Hit/CollisionShape2D.disabled = true

func _on_AnimatedSprite_animation_finished():
	hit_anim = false
