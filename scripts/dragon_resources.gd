extends Node

#@export var stamina_max = 500.0
#var stamina = stamina_max
var max_health = 5.0
var health = max_health

@onready var dragon_node = get_parent()
@onready var presence_node = get_parent().get_node("Presence")
@onready var GlobalData = get_node("/root/Main")
#@onready var initial_speeds = {
#	"wingbeat_strength" : dragon_node.wingbeat_strength,
#	"speed" : dragon_node.speed,
#	"jump_strength_base" : dragon_node.jump_strength_base,
#	"max_jump_strength" : dragon_node.max_jump_strength,
#	"hover_speed" : dragon_node.hover_speed
#}

func _ready() -> void:
	pass
#	for i in initial_speeds:
#		print(initial_speeds[i])
#	print(initial_speeds)

func _input(event: InputEvent) -> void:
	pass
	#print(GlobalData.ambrette_town)
	## INTERACT
	if Input.is_action_just_pressed("Interact"):
		if dragon_node.grabbed_entity != null:
			if dragon_node.grabbed_entity.is_in_group("quest_item"):
				pass
			pass
	#	pass
	## BITE - Lowering Opinion
	#if Input.is_action_just_released("bite"):
	#	var human_count = 0
	#	var killed_body = false
		#var living_humans = []
	#	for body in presence_node.get_overlapping_bodies():
			#print(body)
	#		if body.is_in_group("human"):
	#			if body.dead:
	#				killed_body = true
	#			if killed_body and not body.dead:
					#living_humans.append(body)
	#				human_count += 1
	#	if human_count > 1:
	#		GlobalData.ambrette_town["player_opinion"] -= human_count
		
		#for human in living_humans:
		#	human.get_node("Behavior").check_opinion()
