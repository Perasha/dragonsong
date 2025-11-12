extends Node

#@export var stamina_max = 500.0
#var stamina = stamina_max
var max_health = 5.0
var health = max_health

@onready var dragon_node = get_parent()
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
