extends Node

@export var stamina_max = 500.0
var stamina = stamina_max

@onready var dragon_node = get_parent()

#@warning_ignore("unused_parameter")
#func _process(delta: float) -> void:
	#if stamina < stamina_max:
	#	if dragon_node.is_flying:
	#		if dragon_node.toggle_glide:
	#			stamina -= 0.04
	#		if dragon_node.direction_x != 0:
	#			stamina -= 0.05
	#		if dragon_node.direction_y < 0:
	#			stamina -= 0.05
# Every time we flap our wings, it'll deplete that much stamina.
# If we try to flap without stamina, we can't fly.
#func consume_stamina(value):
#	if value > stamina:
#		value = stamina
#	stamina -= value
#	return value

#func rest():
#	stamina += 250
#	if stamina > stamina_max:
#		stamina = stamina_max
