extends Node2D

@onready var dragon_node = get_parent()
@onready var dragon_resources = get_parent().get_node("Resources")
@onready var camera_node = get_parent().get_parent().get_node("Camera2D")
var lag_threshold = 2000
var duration_step = 2.0
var new_position = Vector2(0,0)

enum {GROUND, NEAR, FAR, MAX}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragon_node.is_flying:
		var distance_lag = dragon_node.current_speed / 1.2
		if distance_lag > lag_threshold:
			distance_lag = lag_threshold
		new_position = dragon_node.flight_direction * distance_lag
		#print(dragon_node.current_speed * delta)
		# Our speed is going to range from 1000 to 2000.
		# A slow weight is 0.05, and a fast weight is 0.1
		var weight = dragon_node.current_speed * 0.00006
		#print(weight)
		#var weight = pow(log(2.0),2)
		#position = lerp(position, new_position, pow(-weight*delta,3))
		#position = lerp(position, new_position, 0.05)
		
		if camera_node.current_zoom_level == MAX:
			var viewport_dimensions: Vector2 = get_viewport().get_visible_rect().size
			#print(viewport_dimensions)
			new_position += Vector2(0,viewport_dimensions.y * 1.5)
			weight *= 0.5
		
		position = lerp(position, new_position, weight)
	else:
		position = Vector2(0,0)
