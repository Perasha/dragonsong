extends Node

#@export var stamina_max = 500.0
#var stamina = stamina_max
var max_health = 5.0
var health = max_health

@onready var dragon_node = get_parent()
@onready var presence_node = get_parent().get_node("Presence")

@onready var initial_speed = {
	"max_jump_strength" : dragon_node.max_jump_strength,
	"max_fly_speed" : dragon_node.max_fly_speed_base,
	"hover_speed" : dragon_node.hover_speed
}

var injury_multiplier = 1.0

func _ready() -> void:
	pass
#	for i in initial_speeds:
#		print(initial_speeds[i])
#	print(initial_speeds)

func health_update(value):
	health += value
	dragon_node.hover_speed = initial_speed["hover_speed"]
	if health > max_health:
		health = max_health
	
	if health > 0:
		injury_multiplier = health / max_health
		dragon_node.max_fly_speed = injury_multiplier * initial_speed["max_fly_speed"]
		dragon_node.max_jump_strength = (injury_multiplier * (initial_speed["max_jump_strength"] - dragon_node.jump_strength_base)) + dragon_node.jump_strength_base
		dragon_node.max_fly_speed_base = dragon_node.max_fly_speed
		#print("INJURY: ", max_fly_speed)
	else:
		dragon_node.max_fly_speed = 0
		dragon_node.max_jump_strength = 0
		dragon_node.hover_speed = 0
		health = 0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("feed") and not dragon_node.is_flying:
		for body in dragon_node.interact_field.get_overlapping_bodies():
			if body.is_in_group("entity") and body.dead == true and not body.is_grabbed:
				#body.food_amount -= 0.5
				#if body.food_amount < 0:
				#	var food_consumed = 0.5 + body.food_amount
				body.queue_free()
				health_update(body.food_amount)
				break
		#if dragon_node.grabbed_entity != null:
		#	if dragon_node.grabbed_entity.is_in_group("entity"):
		#		dragon_node.grabbed_entity.damage(0.5)
		#		health_update(0.15)
		#		pass
			pass
		pass
	


func _on_presence_area_entered(area: Area2D) -> void:
	## If its parent is CaveCovers, hide it.
	var parent = area.get_parent()
	if parent.name == "CaveCovers":
		print("Hiding!")
		get_node("/root/Main/Map").hide_cave(area)


func _on_presence_area_exited(area: Area2D) -> void:
	## If its parent is CaveCovers, show it.
	var parent = area.get_parent()
	if parent.name == "CaveCovers":
		print("Showing!")
		get_node("/root/Main/Map").show_cave(area)
