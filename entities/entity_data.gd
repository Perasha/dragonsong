extends RigidBody2D

## Loadable Statistics -------------------------------
var health = 10
var speed = 100
var food_amount = health
var behavior = EntityBehavior.HERD

## Process Variables ---------------------------------

@onready var sprite = get_node("Sprite")
@onready var floor_check = get_node("FloorCheck")

## Pathfinding
var nav_timer = 0
var nav_timeout = 150
var destination : Vector2

var grabbing_entity : RigidBody2D

## States
var is_running = false
var thought = EntityBehavior.IDLE
var prev_thought = null
var array_key = 0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if grabbing_entity:
		print(grabbing_entity)
		reset_physics_interpolation.call_deferred()
		state.transform.origin = grabbing_entity.position

## When we receive a "THINK" signal,
## We choose a behavior that we have?

## 
