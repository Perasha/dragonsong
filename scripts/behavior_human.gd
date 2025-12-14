extends Node

@onready var entity = get_parent()
#@onready var entity_floorcheck = get_parent().get_node("FloorCheck")
@onready var GlobalData = get_node("/root/Main")
@onready var tick_timer = get_node("/root/Main/TickTimer")
@onready var dragon_node = get_node("/root/Main/dragon")
#@onready var village_nav_node = get_parent().get_parent().get_node("NavNodes")

var nav_timer = 0
var nav_timeout = 400
var nav_timeout_min = 200
var nav_timeout_max = 1400
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tick_timer.timeout.connect(_on_tick_timer_timeout)
	nav_timer = nav_timeout - 30
	pass # Replace with function body.



func _physics_process(delta: float) -> void:
	# Humans wander through town by picking a random town node, and going through it.
	if nav_timer < nav_timeout and entity.active_threat == null:
		nav_timer += 1
	elif entity.active_threat == null:
		nav_timer = 0
		#print(village_nav_node.locations)
		entity.destination = entity.get_destination()
		nav_timeout = randi_range(nav_timeout_min,entity.position.distance_to(entity.destination))
	
	# Have people try and avoid eachother if they overlap too much
	if entity.floor_check.get_overlapping_areas().size() > 6:
		var choice = [-200,200,0]
		#var temp_speed = entity.max_speed - randi_range(entity.max_speed / 4,entity.max_speed / 2)
		var temp_direction = choice.pick_random()
		if temp_direction == 0:
			pass
		else:
			entity.destination = entity.position + Vector2(temp_direction,0)
	# If there's an active threat, run
	if entity.active_threat != null:
		entity.is_running = true
		entity.move_away_from(entity.active_threat)

func _on_tick_timer_timeout():
	#if not entity.dead and entity.floor_check.has_overlapping_areas():
	#	for area in entity.floor_check.get_overlapping_areas():
	#		if area.name == "Presence":
	#			check_memory(area.get_parent())
	pass
	#check_memory()

func check_memory(body):
	for threat in GlobalData.ambrette_town["threats"]:
		pass
		#print(body)
		#print(threat)
	#if GlobalData.ambrette_town["player_opinion"] < 0:
	#	entity.active_threat = dragon_node
	#else:
	#	entity.active_threat = null

func _on_floor_check_area_entered(area: Area2D) -> void:
	# If there's a nearby corpse, find the nearest non-human body and mark it as a threat.
	# If the only thing nearby *is* a human... mark the corpse as a threat
	#if area.name == "DeathAura":
	#	for area_found in entity.floor_check.get_overlapping_areas():
	#		var body = area_found.get_parent()
	#		if body.is_in_group("player"):
	#			GlobalData.ambrette_town["player_opinion"] -= 10
	#			GlobalData.ambrette_town["threats"].append(body)
	#		elif body.is_in_group("monster"):
	#			entity.active_threat = body
	#	pass
	#if area.name == "Presence":
	#	check_memory(area.get_parent())
	pass # Replace with function body.


func _on_floor_check_area_exited(area: Area2D) -> void:
	if area.name == "Presence":
		#print("Safe")
		entity.active_threat = null
	pass # Replace with function body.
