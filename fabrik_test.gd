
extends Node2D

#@export var dragon_node : Node2D
#@onready var flight_direction_node = dragon_node.get_node("Direction Pointer")

@export var segment_length = 100.0
@export var segment_width = 4.0
@export var max_angle = 30.0
@export var opacity = 1.0
@export var target_position = Vector2(0,0)
@export var gravity = Vector2(0,5)

@export var anchor = Vector2(0,0)
var toggle_tracking = true
#var point = Vector2(100,100)
var point_count = 3
var point_array = []
var point_array_length = 0

#var line_distance = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in point_count:
		point_array.append(Vector2(i,i))
	point_array_length = point_array.size() - 1
	pass # Replace with function body.

## So, we want an IK rig from the Chest, to the Head.
# Set the Head as its own point, 

## Simplest thing first: a Tail
# Start from the chest, then make points that go outward.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#line_distance = segment_length
	
	#Set the first link's position to be at the mouse
	if toggle_tracking == true:
		point_array[0] = to_local(get_global_mouse_position())
	var i = 1
	while (i < point_array.size()):
		#point_array[i] += gravity
		point_array[i] = constrain_distance(point_array[i],point_array[i-1],segment_length)
		i += 1
	
	## Set the base position to an anchor
	point_array[point_array.size()-1] = anchor
	i = point_array.size()-1
	while (i > 0):
		#point_array[i] += gravity
		point_array[i-1] = constrain_distance(point_array[i-1],point_array[i],segment_length)
		point_array[i] += gravity
		i -= 1
		
	queue_redraw()

func _input(event: InputEvent) -> void:
	## BITE
	if Input.is_action_pressed("bite"):
		toggle_tracking = true
	else: 
		toggle_tracking = false

func _draw() -> void:
	for i in (point_array.size()-1):
		draw_line(point_array[i],point_array[i+1],Color(1,0,0,opacity),segment_width,true)



## STEP 1) Distance Constraint
# Draw a vector from the anchor to the desired point,
# Scale that vector to equal the distance desired.

func constrain_distance(point,anchor_val: Vector2,distance):
	return ((point - anchor_val).normalized() * distance) + anchor_val

## Constrain Angles
func constrain_angle(angle, anchor, constraint):
	if abs(relative_angle_diff(angle,anchor)) <= constraint:
		return simplify_angle(angle)
	
	if relative_angle_diff(angle, anchor) > constraint:
		return simplify_angle(anchor - constraint)
	
	return simplify_angle(anchor + constraint)

func relative_angle_diff(angle,anchor):
	angle = simplify_angle(angle + PI - anchor)
	anchor = PI
	return (anchor - angle)
	
func simplify_angle(angle):
	while (angle >= (PI * 2)):
		angle -= (PI * 2)

	while (angle < 0):
		angle += (PI * 2)
		
	return angle;
