extends Area2D

@onready var dragon_node = get_node("/root/Main/dragon")
@onready var weather = get_parent()
@onready var wind_mote = preload("res://Weather/wind_mote.tscn")

var wind_direction = Vector2(0,0)
var wind_strength = 1.0
var wind_motes = []
var entities_in_wind = []

var timer = 100
var timer_base = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if timer == 0:
		create_mote(dragon_node.position)
		timer = timer_base
	else:
		timer -= 1
	
	## Applying wind to entities within
	for object in get_overlapping_bodies():
		if object.is_in_group("entity") or object.name == "dragon":
			object.linear_velocity.x += (wind_direction.x * wind_strength)
		if object.name == "dragon":
			object.flight_direction.x += wind_direction.x
	
	## Slowly shrinking the wind motes, 
	for mote in wind_motes:
		mote.scale -= Vector2(0.01,0.01)
	var i = 0
	for mote in wind_motes:
		if mote.scale.x <= 0.0:
			GlobalData.array_swapback(wind_motes,i,"wind motes")
			mote.queue_free()
		i += 1

func create_mote(spawn_position):
	var new_mote = wind_mote.instantiate()
	add_child(new_mote)
	wind_motes.append(new_mote)
	new_mote.scale = Vector2(5.0,5.0)
	new_mote.position = spawn_position
	if wind_direction.x < 0:
		new_mote.rotation_degrees = 90

func set_wind(state):
	wind_direction = Vector2(randf_range(-1.0,1.0),0)
	
	if state == weather.FOG or state == weather.CALM:
		wind_strength = randi_range(5,20)
	if state == weather.STORM:
		wind_strength = randi_range(20,50)
	
	if wind_direction.x < 0:
		for mote in wind_motes:
			mote.rotation_degrees = 90
	else:
		for mote in wind_motes:
			mote.rotation_degrees = -90
