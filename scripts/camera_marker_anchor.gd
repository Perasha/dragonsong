extends Node2D

@onready var dragon_node : RigidBody2D = %dragon
@onready var raycast_anchor : RayCast2D = %RayCastAnchor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _physics_process(delta: float) -> void:
	position.x = dragon_node.position.x
	if raycast_anchor.is_colliding():
		#position.y -= raycast_anchor.get_collision_point().y
		position.y = raycast_anchor.get_collision_point().y
	else:
		position.y = dragon_node.position.y
	#if position.y > -50:
	#	position.y = -50
	#print(dragon_node.position - position)
	pass
