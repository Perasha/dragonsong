extends Node2D

@onready var dragon_node = get_parent()
@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node = get_parent().get_parent().get_node("Camera2D")
var lag_threshold = 2000
var duration_step = 2.0
var new_position = Vector2(0,0)
var is_looking = false

enum {GROUND, NEAR, FAR, MAX}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var weight = 0.1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.option_hold_to_look:
		if Input.is_action_pressed("look"):
			is_looking = true
		else:
			is_looking = false
	else:
		if Input.is_action_just_pressed("look"):
			if is_looking == true:
				is_looking = false
			else:
				is_looking = true
	
	if is_looking:
		weight = 0.01
		#print("looking!")
		#print(position)
		#print(get_viewport().get_mouse_position())
		var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
		new_position = (get_viewport().get_mouse_position() - (viewport_dimensions / 2))
		if camera_node.current_zoom_level == GROUND:
			new_position *= 1.5
		elif camera_node.current_zoom_level == NEAR:
			new_position *= 3
		elif camera_node.current_zoom_level == FAR:
			new_position *= 6
		else:
			new_position *= 12
		#print(new_position)
		#weight = 0.05
	
	elif dragon_node.is_flying:
		var distance_lag = dragon_node.current_speed / 1.2
		if distance_lag > lag_threshold:
			distance_lag = lag_threshold
		new_position = dragon_node.flight_direction * distance_lag
		#print(dragon_node.current_speed * delta)
		# Our speed is going to range from 1000 to 2000.
		# A slow weight is 0.05, and a fast weight is 0.1
		weight = dragon_node.current_speed * 0.00006
		#print(weight)
		#var weight = pow(log(2.0),2)
		#position = lerp(position, new_position, pow(-weight*delta,3))
		#position = lerp(position, new_position, 0.05)
		## Move the camera down if we're flying very h
		#if camera_node.current_zoom_level == MAX:
		#	var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
			#print(viewport_dimensions)
		#	new_position += Vector2(0,viewport_dimensions.y * 1.5)
		#	weight *= 0.5
		
		#print(dragon_node.distance_moved)
		#if dragon_node.distance_moved < 1:
			#print("Relocate")
		#	new_position = Vector2(0,0)
		#	weight = 0.01
	else:
		new_position = Vector2(0,0)
		weight = 0.05
	
	position = lerp(position, new_position, weight)
