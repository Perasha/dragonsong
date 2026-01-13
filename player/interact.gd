extends Area2D

@onready var dragon_node = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var is_grabbing = false
var grabbed_entity : RigidBody2D

func _input(event: InputEvent) -> void:
	## INTERACT
	if Input.is_action_just_pressed("Interact"):
		if not is_grabbing and grabbed_entity == null:
			for body in get_overlapping_bodies():
				if not body.is_in_group("player"):
					#if body.can_be_grabbed:
						#body.is_grabbed = true
						#body.grabbing_entity = self
					is_grabbing = true
					grabbed_entity = body
					#body.linear_velocity.y -= 1
					break
		elif is_grabbing:
			grabbed_entity.just_released = true
			is_grabbing = false
			grabbed_entity = null
	## BITE
	if Input.is_action_just_pressed("bite"):
		#print("Dragon script: ", GlobalData.ambrette_town)
		dragon_node.sprite.play_bite_animation()
		for body in get_overlapping_bodies():
			if body.is_in_group("entity"):
				body.damage(0.5)
