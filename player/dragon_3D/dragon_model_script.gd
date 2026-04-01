extends Node3D

enum {LEFT, RIGHT}

@export var bone_simulation : PhysicalBoneSimulator3D
@export var dragon_node : RigidBody2D

## Legs
@onready var HindLeg_L = get_node("HindlegL")
@onready var HindLeg_R = get_node("HindlegR")
@onready var ForeLeg_L = get_node("ForelegL")
@onready var ForeLeg_R = get_node("ForelegR")

## Wings
@onready var Membrane_L = get_node("Membrane")
@onready var Deltoid_L = get_node("Deltoid")
@onready var Forearm_L = get_node("Forearm")
@onready var Membrane_R = get_node("Membrane_001")
@onready var Deltoid_R = get_node("Deltoid_001")
@onready var Forearm_R = get_node("Forearm_001")

@export var wing_membrane_offset = Vector3(0.0, -0.38, 0.0)
@onready var membrane_initial_pos = Membrane_L.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_children())
	#print(Membrane_L.position)
	#print(Membrane_R.position)
	Deltoid_L.hide()
	Forearm_L.hide()
	Deltoid_R.hide()
	Forearm_R.hide()
	
	wing_membrane_offset.z += membrane_initial_pos.z
	#bone_simulation.physical_bones_start_simulation()
	pass # Replace with function body.

var last_x_direction = 0.0

var target_rotation_left = 0
var target_rotation_right = 180
var target_rotation = 0.0
var facing = LEFT
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragon_node.is_flying:
		HindLeg_L.rotation.x = 70
		HindLeg_R.rotation.x = 70
		ForeLeg_L.rotation.x = 70
		ForeLeg_R.rotation.x = 70
		Membrane_L.rotation_degrees.z = 80
		Membrane_L.position = wing_membrane_offset
		Membrane_L.position.x *= -1
		Membrane_R.position = wing_membrane_offset
		Membrane_R.rotation_degrees.z = -80
	else:
		HindLeg_L.rotation.x = 0
		HindLeg_R.rotation.x = 0
		ForeLeg_L.rotation.x = 0
		ForeLeg_R.rotation.x = 0
		Membrane_L.position = membrane_initial_pos
		Membrane_R.position = membrane_initial_pos
		Membrane_L.rotation_degrees.z = 0
		Membrane_R.rotation_degrees.z = 0
	
	#if dragon_node.direction_x != 0:
	#	last_x_direction = dragon_node.direction_x
	if dragon_node.flight_direction.x > 0:
		last_x_direction = 1.0
	elif dragon_node.flight_direction.x < 0:
		last_x_direction = -1.0
		
	if last_x_direction == 1.0:# and rotation_degrees.y < target_rotation_right:
		target_rotation = target_rotation_right
		#rotation_degrees.y += 5
		#rotation_degrees.z -= 5
		facing = RIGHT
		#if target_rotation_right - rotation_degrees.y < 2:
		#	rotation_degrees.y = target_rotation_right
	if last_x_direction == -1.0:# and rotation_degrees.y > target_rotation_left:
		target_rotation = target_rotation_left
		facing = LEFT
		#print("Margin Check:", target_rotation_left - rotation_degrees.y)
		#if target_rotation_left - rotation_degrees.y < 2:
		#	rotation_degrees.y = target_rotation_left
	rotation_degrees.y = lerpf(rotation_degrees.y,target_rotation,0.05)
	
	#print(rotation_degrees.x)
	#print(dragon_node.flight_direction.angle())
	rotation.x = 0
	if dragon_node.is_flying and not dragon_node.is_hovering:
		rotation.x = dragon_node.flight_direction.angle() #- rotation.y# + (PI / 2)
		#rotation.z = dragon_node.flight_direction.angle()
		if rotation_degrees.x < -90 or rotation_degrees.x > 90:
			rotation.x *= -1
			rotation.x += PI
		#if rotation_degrees.y == target_rotation_right:
		#	rotation.x = dragon_node.flight_direction.angle()
		
	
	#Membrane_L.rotation_degrees.z -= 4
	#print(rotation_degrees.y)
