extends Node

#@export var stamina_max = 500.0
#var stamina = stamina_max
var max_health = 5.0
var health = max_health

@onready var dragon_node = get_parent()
@onready var presence_node = get_parent().get_node("Presence")
@onready var global_data = get_node("/root/Main")
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
	print(global_data.ambrette_town)
	## INTERACT
	#if Input.is_action_just_pressed("Interact"):
	#	pass
	## BITE - Lowering Opinion
	if Input.is_action_just_pressed("bite"):
		var human_count = 0
		for body in presence_node.get_overlapping_bodies():
			print(body)
			if body.is_in_group("entity"):
				if not body.dead:
					human_count += 1
					if human_count > 1:
						break
		if human_count > 1:
			global_data.ambrette_town["player_opinion"] -= 1
		#presence_node.scale = Vector2(0,0)
		#presence_node.scale = Vector2(1.0,1.0)
