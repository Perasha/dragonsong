extends RigidBody2D

@onready var sprite = get_node("Sprite")
@onready var floor_check = get_node("FloorCheck")

var health = 10
var speed = 100
var food_amount = health
var behavior = "Herd"

# Pathfinding
var nav_timer = 0
var nav_timeout = 400
var nav_timeout_min = 200
var nav_timeout_max = 1400
var destination = Vector2(0,0)

# Bools
var is_running = false
var thought = EntityBehavior.IDLE
