extends Area2D

@onready var dragon_node = get_parent()
@onready var object_manager = get_node("/root/Main/ObjectManager")
@onready var resources = dragon_node.get_node("Resources")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if dragon_node.resources.attack_cooldown != 0:
		dragon_node.resources.attack_cooldown -= 1

var is_grabbing = false
var grabbed_entity : RigidBody2D

func _input(event: InputEvent) -> void:
	## COLLECT
	if Input.is_action_just_pressed("Interact"):
		for body in get_overlapping_bodies():
			if body.is_in_group("collectible"):
				print(body.name)
				pick_up(body)
				break
			elif body.is_in_group("item_pile"):
				gather(body)
				break
	## VOMIT
	if Input.is_action_just_pressed("vomit"):
		if resources.collected_items >= 1:
			print("Vomitting")
			var found_pile = null
			for body in get_overlapping_bodies():
				if body.is_in_group("item_pile"):
					found_pile = body
					break
			vomit(found_pile)
				
		#if not is_grabbing and grabbed_entity == null:
			#for body in get_overlapping_bodies():
				#if body.is_in_group("object_grabbable"):# body.is_in_group("entity") or 
					#print("grabbing ", body)
					##entity_manager.grab_entity(body)
					#body.sleeping = false
					#body.grabbing_entity = dragon_node
					#is_grabbing = true
					#grabbed_entity = body
					#print("Grabbing Entity", body.grabbing_entity)
					#break
					#
		#elif is_grabbing:
			##entity_manager.release_entity(grabbed_entity)
			#if grabbed_entity.is_in_group("object_grabbable"):
				#grabbed_entity.just_released = true
			#print("Releasing")
			#grabbed_entity.grabbing_entity = null
			#grabbed_entity.sleeping = false
			#is_grabbing = false
			#grabbed_entity = null
	
	## BITE
	if Input.is_action_just_pressed("bite") and dragon_node.resources.attack_cooldown == 0:
		#print("Dragon script: ", GlobalData.ambrette_town)
		#dragon_node.sprite.play_bite_animation()
		dragon_node.resources.attack_cooldown = dragon_node.resources.attack_speed
		for body in get_overlapping_bodies():
			if body.is_in_group("entity"):
				body.attacking_entity = dragon_node
				body.health_update(-5)
				
	
	## EAT
	#if Input.is_action_just_pressed("feed") and not dragon_node.is_flying:
		#for body in dragon_node.interact_field.get_overlapping_bodies():
			#if body.is_in_group("entity") and body.dead == true and not body.is_grabbed:
				##body.food_amount -= 0.5
				##if body.food_amount < 0:
				##	var food_consumed = 0.5 + body.food_amount
				##body.queue_free()
				##health_update(body.food_amount)
				#break
		##if dragon_node.grabbed_entity != null:
		##	if dragon_node.grabbed_entity.is_in_group("entity"):
		##		dragon_node.grabbed_entity.damage(0.5)
		##		health_update(0.15)
		##		pass
			#pass
		#pass
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#pass

@onready var thought_bubble = get_node("/root/Main/HUD/PlayerStats/Thought")#.get_node("%Thought")
var item_pile = preload("res://objects/item_pile.tscn")

func gather(object):
	if (resources.collected_items + 1) <= resources.inventory_size:
		resources.collected_items += 1
		object.size -= 1
		if object.size == 0:
			object.queue_free()
		else:
			object_manager.update_size(object)
	else:
		thought_bubble.thought_start("You can't hold any more items.")

func pick_up(object):
	if (resources.collected_items + object.size) <= resources.inventory_size:
		resources.collected_items += object.size
		object.queue_free()
	else:
		thought_bubble.thought_start("You can't hold any more items.")

func vomit(current_pile):
	if current_pile == null:
		current_pile = item_pile.instantiate()
		object_manager.add_object(dragon_node.position,current_pile)
		current_pile.size = resources.collected_items
	else:
		current_pile.size += resources.collected_items
	object_manager.update_size(current_pile)
	resources.collected_items = 0
