extends Node2D

@export var dragon_node : Node2D
@onready var flight_direction_node = dragon_node.get_node("Direction Pointer")

var anchor = Vector2(0,0)
#var point = Vector2(100,100)
var point_count = 10
var point_array = []

var line_distance = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in point_count:
		point_array.append(Vector2(i,i))
	pass # Replace with function body.

## So, we want an IK rig from the Chest, to the Head.
# Set the Head as its own point, 

## Simplest thing first: a Tail
# Start from the chest, then make points that go outward.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	line_distance = dragon_node.distance_moved * 1.5
	#Set the first link's position to be at the Flight Direction.
	point_array[0] = dragon_node.global_position
	for i in (point_array.size() - 1):
		point_array[i+1] = constrain_distance(point_array[i+1],point_array[i],line_distance)
	queue_redraw()

func _draw() -> void:
	#point_array[0] = Vector2(0,0)
	#var count = 0
	
	for i in (point_array.size()-1):
		# For the Alpha channel, we're actually gonna pass in our Distance Moved (divided by 20) to change the visibility
		# as we fly. This essentially creates streaks as we fly faster! And lets us know if we're going too fast to boost.
		var opacity = 0.0
		opacity += (dragon_node.distance_moved / 20) - 1.0
		draw_line(point_array[i],point_array[i+1],Color(1,0,0,opacity),((point_array.size()-i) + (20 / (i + 1))),true)
		#print(i)
		#print("Starting point:", point_array[i])
		#print("Ending point:", point_array[i+1])



## STEP 1) Distance Constraint
# Draw a vector from the anchor to the desired point,
# Scale that vector to equal the distance desired.

func constrain_distance(point,anchor,distance):
	return ((point - anchor).normalized() * distance) + anchor
