extends Area2D

@onready var dragon_node = get_parent()
@onready var object_manager = get_node("/root/Main/ObjectManager")
@onready var resources = dragon_node.get_node("Resources")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if dragon_node.resources.attack_cooldown != 0:
		dragon_node.resources.attack_cooldown -= 1

func _input(event: InputEvent) -> void:
	## COLLECT
	if Input.is_action_just_pressed("Interact"):
		if highlighted_object:
			if highlighted_object.is_in_group("collectible"):
				pick_up(highlighted_object)
			elif highlighted_object.is_in_group("item_pile"):
				gather(highlighted_object)
			if get_tree().get_nodes_in_group("select_choice").size() >= 1:
				highlighted_object = get_tree().get_nodes_in_group("select_choice")[0]
				object_manager.highlight(highlighted_object,true)
	## VOMIT
	if Input.is_action_just_pressed("vomit"):
		if resources.collected_items >= 1:
			#print("Vomitting")
			var found_pile = null
			if highlighted_object:
				if highlighted_object.is_in_group("item_pile"):
					found_pile = highlighted_object
			vomit(found_pile)
	
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
	
	if Input.is_action_just_pressed("select_next_object"):
		selectable_object_count = get_tree().get_nodes_in_group("select_choice").size()-1
		#print(selectable_objects.size())
		if selectable_object_count >= 1:
			cycle_selectable_objects(selectable_object_count)
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#pass

## When we have multiple objects selected, this is used to tab between them
var highlighted_object = null
var highlighted_object_index = 0
var selectable_object_count = 0
func cycle_selectable_objects(object_array):
	if highlighted_object_index + 1 <= selectable_object_count:
		highlighted_object_index += 1
	else:
		highlighted_object_index = 0
	if not highlighted_object == null:
		object_manager.highlight(highlighted_object,false)
		print("Highlighted object: ", highlighted_object)
		highlighted_object = get_tree().get_nodes_in_group("select_choice")[highlighted_object_index]
	print("Highlighted object: ", highlighted_object)
	object_manager.highlight(highlighted_object,true)

@onready var thought_bubble = get_node("/root/Main/HUD/PlayerStats/Thought")#.get_node("%Thought")
var item_pile = preload("res://objects/item_pile.tscn")
var gather_amount = 10

func thought_gather(amount,item_type):
	thought_bubble.thought_start("+" + str(amount) + " " + str(item_type))

func gather(object):
	print(object.size)
	if resources.remaining_inventory >= 1:
		var amount_to_collect# = gather_amount - object.size
		if object.size >= gather_amount:
			amount_to_collect = gather_amount
		else:
			amount_to_collect = object.size
		
		if amount_to_collect > resources.remaining_inventory:
			amount_to_collect = resources.remaining_inventory
		
		print("Amount to collect: ", amount_to_collect)
		resources.inventory_update(amount_to_collect)
		object.size -= amount_to_collect
		#thought_gather(amount_to_collect, object.type)
		
		if object.size <= 0:
			#print(object)
			object.remove_from_group("select_choice")
			object.queue_free()
			#print(object)
		else:
			object_manager.pile_update_size(object)
		thought_gather(amount_to_collect,object.type)
	else:
		if GlobalData.first_full_inventory == false:
			thought_bubble.thought_start("You can't hold any more items. Press V to empty your inventory.")
			GlobalData.first_full_inventory = true
		else:
			thought_bubble.thought_start("You can't hold any more items.")

func pick_up(object):
	if object.size <= resources.remaining_inventory:
		resources.inventory_update(object.size)
		#thought_gather(object.size, object.type)
		object.remove_from_group("select_choice")
		object.queue_free()
		thought_gather(object.size,object.type)
	else:
		if GlobalData.first_full_inventory == false:
			thought_bubble.thought_start("You can't hold this item. Press V to empty your inventory.")
			GlobalData.first_full_inventory = true
		else:
			thought_bubble.thought_start("You can't hold this item.")

## Note: 
## As of now, we dump *all* our inventory into one gold pile.
## If the pile we have selected is already full or will be too full, we make ONE new one.
## Consider adding functionality in the future that lets us make multiple piles all at once if we need to.
func vomit(current_pile):
	var create_pile = false
	var amount_to_add = resources.collected_items
	## If the size of the pile plus what we would add exceeds the max size,
	## we overflow and create a new pile.	
	if current_pile == null:
		create_pile = true
	else:
		if current_pile.size + resources.collected_items > object_manager.max_pile_size:
			create_pile = true
			amount_to_add = object_manager.max_pile_size - current_pile.size 
			current_pile.size = object_manager.max_pile_size
			object_manager.pile_update_size(current_pile)
			## After adding to the current pile, update our inventory to get ready to make the *new* pile.
			resources.inventory_update(-amount_to_add)
			amount_to_add = resources.collected_items
	
		## If there is no pile selected OR that pile is already at max size, we're gonna make a new pile
		if current_pile.size == object_manager.max_pile_size:
			create_pile = true
	
	if create_pile:
		GlobalData.created_piles += 1
		current_pile = item_pile.instantiate()
		current_pile.name = "player_pile_" + str(GlobalData.created_piles)
		object_manager.add_object(dragon_node.position,current_pile)
	
	current_pile.size += amount_to_add
	#resources.collected_items -= amount_to_add
	
	object_manager.pile_update_size(current_pile)
	resources.inventory_update(-resources.collected_items)
