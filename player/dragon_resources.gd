extends Node

#@export var stamina_max = 500.0
#var stamina = stamina_max
@export var max_health = 100.0
var health = max_health
#var health_to_int = 0

@export var max_stamina = 20.0
var stamina = max_stamina

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
## These will be used for visuals only. 
## As health gets lower, more visual effects can be apparent.
var health_brackets = {
	"5": [0,20],
	"4": [21,40],
	"3": [41,60],
	"2": [61,80],
	"1": [81,100],
}

var injury_multiplier = 1.0
var exhaustion_rate_base = 0.005
var exhaustion_rate = exhaustion_rate_base

func _ready() -> void:
	## Do all our setup for the health bullshit here. So that we're not trying to update everything during the damn game.
	## 1) Create our Health Brackets
	## 2) Create our Max Speed for each bracket
	## 3) Create our Max Jump Strength for each bracket
	## 4) Create our Max Fly Speed Base for each bracket
	pass


func _physics_process(delta: float) -> void:
	## Rate starts off negative to heal/rest
	exhaustion_rate = -exhaustion_rate_base * 2
	## If we're flying, we're not resting
	if dragon_node.is_flying:
		exhaustion_rate = 0
	if dragon_node.is_hovering:
		exhaustion_rate += exhaustion_rate_base * 5
	if dragon_node.is_running:
		exhaustion_rate += exhaustion_rate_base * 1.5
	stamina_update(-exhaustion_rate)
	
	#if exhaustion_rate == 0 and stamina < max_stamina:
	#	stamina_update(1)

func inventory_update(value):
	collected_items += value
	if collected_items < 0:
		collected_items = 0
	remaining_inventory = inventory_size - collected_items
	print("Collected items: ", collected_items)
	print("Remaining Inventory: ", remaining_inventory)


func stamina_update(value):
	stamina += value
	if stamina > max_stamina:
		stamina = max_stamina
	if stamina < 0:
		stamina = 0
	pass

func health_update(value):
	#current_bracket = health_
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
