extends RigidBody2D

var is_grounded = false

@onready var nav_node = get_parent().get_parent().get_node("NavNodes")
var nav_timer = 0
var nav_timeout = 400
var nav_timeout_min = 200
var nav_timeout_max = 600
var max_speed = 100

var destination = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = position
	nav_timer = nav_timeout - 30
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.distance_to(destination) > 30:
		#print(position.distance_to(destination))
		move_to(destination)
	else:
		linear_velocity = Vector2(0,0)
	if nav_timer < nav_timeout:
		nav_timer += 1
	else:
		nav_timer = 0
		#print(nav_node.locations)
		destination = get_destination()
		nav_timeout = randi_range(nav_timeout_min,position.distance_to(destination))
		#print(destination)

func move_to(destination):
	var direction = position.direction_to(destination)
	if abs(linear_velocity.x) < max_speed:
		linear_velocity.x += direction.x * 4
	if abs(linear_velocity.x) > max_speed:
		if linear_velocity.x < 0: linear_velocity.x = -max_speed
		else: linear_velocity.x = max_speed
	#print("Linear Velocity", linear_velocity)

func get_destination():
	return nav_node.locations.pick_random()

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print(body.name)
	if body.name == "MainLayer":
		is_grounded = true
