extends Area2D

@onready var dragon_node = get_parent()
@onready var entity_manager = get_node("/root/Main/EntityManager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var is_grabbing = false
var grabbed_entity : RigidBody2D

func _input(event: InputEvent) -> void:
	## GRAB
	if Input.is_action_just_pressed("Interact"):
		if not is_grabbing and grabbed_entity == null:
			for body in get_overlapping_bodies():
				if body.is_in_group("entity") and not body == dragon_node:
					print("grabbing ", body)
					entity_manager.grab_entity(body)
					body.grabbing_entity = dragon_node
					is_grabbing = true
					grabbed_entity = body
					break
		elif is_grabbing:
			entity_manager.release_entity(grabbed_entity)
			is_grabbing = false
			grabbed_entity = null
	## BITE
	if Input.is_action_just_pressed("bite"):
		#print("Dragon script: ", GlobalData.ambrette_town)
		dragon_node.sprite.play_bite_animation()
		for body in get_overlapping_bodies():
			if body.is_in_group("entity") and not body == dragon_node:
				EntityBehavior.health_update(body,-2)

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#pass
