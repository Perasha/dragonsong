extends Area2D

@onready var dragon_node = get_parent()
@onready var entity_manager = get_node("/root/Main/EntityManager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if dragon_node.resources.attack_cooldown != 0:
		dragon_node.resources.attack_cooldown -= 1

var is_grabbing = false
var grabbed_entity : RigidBody2D

func _input(event: InputEvent) -> void:
	## GRAB
	if Input.is_action_just_pressed("Interact"):
		if not is_grabbing and grabbed_entity == null:
			for body in get_overlapping_bodies():
				if body.is_in_group("entity"):
					print("grabbing ", body)
					#entity_manager.grab_entity(body)
					body.sleeping = false
					body.grabbing_entity = dragon_node
					is_grabbing = true
					grabbed_entity = body
					print("Grabbing Entity", body.grabbing_entity)
					break
		elif is_grabbing:
			#entity_manager.release_entity(grabbed_entity)
			print("Releasing")
			grabbed_entity.grabbing_entity = null
			grabbed_entity.sleeping = false
			is_grabbing = false
			grabbed_entity = null
	
	## BITE
	if Input.is_action_just_pressed("bite") and dragon_node.resources.attack_cooldown == 0:
		#print("Dragon script: ", GlobalData.ambrette_town)
		dragon_node.sprite.play_bite_animation()
		dragon_node.resources.attack_cooldown = dragon_node.resources.attack_speed
		for body in get_overlapping_bodies():
			if body.is_in_group("entity"):
				body.attacking_entity = dragon_node
				body.health_update(-5)
				
	
	## EAT
	if Input.is_action_just_pressed("feed") and not dragon_node.is_flying:
		for body in dragon_node.interact_field.get_overlapping_bodies():
			if body.is_in_group("entity") and body.dead == true and not body.is_grabbed:
				#body.food_amount -= 0.5
				#if body.food_amount < 0:
				#	var food_consumed = 0.5 + body.food_amount
				#body.queue_free()
				#health_update(body.food_amount)
				break
		#if dragon_node.grabbed_entity != null:
		#	if dragon_node.grabbed_entity.is_in_group("entity"):
		#		dragon_node.grabbed_entity.damage(0.5)
		#		health_update(0.15)
		#		pass
			pass
		pass
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#pass
