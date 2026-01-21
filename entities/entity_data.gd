extends RigidBody2D

@onready var sprite = get_node("Sprite")
@onready var floor_check = get_node("FloorCheck")

var health = 10
var speed = 100
var food_amount = health

# Pathfinding
var nav_timer = 0
var nav_timeout = 150
var destination : Vector2

var grabbing_entity : RigidBody2D

# Behavior and States
var behavior = "Herd"
var is_running = false
var thought = EntityBehavior.IDLE

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#print("Ooh rah")
	if grabbing_entity:
		reset_physics_interpolation.call_deferred()
		state.transform.origin = grabbing_entity.position
