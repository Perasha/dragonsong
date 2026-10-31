extends Node2D

@onready var dragon_node = get_parent()
@onready var head_node = get_node("Head")
@onready var wing_node = [get_node("WingFront"),get_node("WingBack")]
enum {FRONT, BACK}

@onready var arm_node = [get_node("ArmFront"),get_node("ArmBack")]
@onready var leg_node = [get_node("LegFront"),get_node("LegBack")]

@export var scale_base = 0.165

## Directions to Face:
enum {LEFT = -1,RIGHT = 1, UP = -1, DOWN = 1, NEUTRAL = 0}
var direction = [LEFT,NEUTRAL]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	face_direction()
	
func face_direction():
	if dragon_node.is_flying:
		direction[0] = RIGHT
		if dragon_node.flight_direction.x < 0:
			direction[1] = UP
		else:
			direction[1] = DOWN
		rotation = dragon_node.flight_direction.angle()# * new_direction[0]
	else:
		rotation = 0
		direction[1] = DOWN
		if dragon_node.flight_direction.x < 0: ## Left = -1
			direction[0] = LEFT
		else:
			direction[0] = RIGHT
	
	#print("Direction: ", direction)
	scale.x = -direction[0] * scale_base
	scale.y = direction[1] * scale_base
