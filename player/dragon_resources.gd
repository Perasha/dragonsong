extends Node

#@export var stamina_max = 500.0
#var stamina = stamina_max
@export var max_health = 100.0
var health = max_health
var health_to_int = 0

@export var attack_speed = 10
var attack_cooldown = 0

var collected_items = 0
var inventory_size = 40
var remaining_inventory = inventory_size

@onready var dragon_node = get_parent()
#@onready var presence_node = get_parent().get_node("Presence")

@onready var initial_speed = {
	"max_jump_strength" : dragon_node.max_jump_strength,
	"max_fly_speed" : dragon_node.max_fly_speed_base,
	"hover_speed" : dragon_node.hover_speed
}

var injury_multiplier = 1.0
var exhaustion_rate_base = 0.001
var exhaustion_rate = exhaustion_rate_base

func _process(delta: float) -> void:
	exhaustion_rate = exhaustion_rate_base
	if dragon_node.is_flying:
		if dragon_node.is_gliding:
			exhaustion_rate *= 2
		elif dragon_node.is_hovering:
			exhaustion_rate *= 5
		else:
			exhaustion_rate = 0
		
		if dragon_node.direction_x or dragon_node.direction_y:
			exhaustion_rate += exhaustion_rate_base
		if dragon_node.just_jumped:
			health_update(-0.05)
	else:
		exhaustion_rate = 0
	health_update(-exhaustion_rate)

func inventory_update(value):
	collected_items += value
	if collected_items < 0:
		collected_items = 0
	remaining_inventory = inventory_size - collected_items
	print("Collected items: ", collected_items)
	print("Remaining Inventory: ", remaining_inventory)

func health_update(value):
	#print(health)
	#print(value)
	health += value
	dragon_node.hover_speed = initial_speed["hover_speed"]
	if health > max_health:
		health = max_health
	
	if health > 0:
		injury_multiplier = health / max_health
		dragon_node.max_fly_speed = injury_multiplier * initial_speed["max_fly_speed"]
		dragon_node.max_jump_strength = (injury_multiplier * (initial_speed["max_jump_strength"] - dragon_node.jump_strength_base)) + dragon_node.jump_strength_base
		dragon_node.max_fly_speed_base = dragon_node.max_fly_speed
		health = snappedf(health,0.001)
		#print("INJURY: ", max_fly_speed)
	else:
		dragon_node.max_fly_speed = 0
		dragon_node.max_jump_strength = 0
		dragon_node.hover_speed = 0
		health = 0
	#health = float(int(health * 100) / 100)
	


func _on_presence_area_entered(area: Area2D) -> void:
	## If its parent is CaveCovers, hide it.
	var parent = area.get_parent()
	if parent.name == "CaveCovers":
		#print("Hiding!")
		get_node("/root/Main/Map").hide_cave(area)


func _on_presence_area_exited(area: Area2D) -> void:
	## If its parent is CaveCovers, show it.
	var parent = area.get_parent()
	if parent.name == "CaveCovers":
		#print("Showing!")
		get_node("/root/Main/Map").show_cave(area)
