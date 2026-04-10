extends Node3D

enum {LEFT, RIGHT}

@export var wing_dive : PackedScene
@export var wing_flap_top : PackedScene
@export var wing_flap_mid : PackedScene
@export var wing_flap_bottom : PackedScene
@export var wing_folded : PackedScene
@export var wing_glide : PackedScene

@export var dragon_node : RigidBody2D

## Legs
@onready var HindLeg_L = get_node("body/HindlegL")
@onready var HindLeg_R = get_node("body/HindlegR")
@onready var ForeLeg_L = get_node("body/ForelegL")
@onready var ForeLeg_R = get_node("body/ForelegR")

## Wings
@onready var wing_skeleton = get_node("wings/Armature_R/Skeleton3D")

	## Wing Poses
@onready var wing_up_pose = wing_flap_top.instantiate().get_node("Armature_R/Skeleton3D")
@onready var wing_dive_pose = wing_dive.instantiate().get_node("Armature_R/Skeleton3D")
@onready var wing_glide_pose = wing_glide.instantiate().get_node("Armature_R/Skeleton3D")
@onready var wing_rest_pose = wing_folded.instantiate().get_node("Armature_R/Skeleton3D")
@onready var wing_down_pose = wing_flap_bottom.instantiate().get_node("Armature_R/Skeleton3D")

## Tail
@onready var tail = get_node("tail/Armature/Skeleton3D")

#@onready var Membrane_L = get_node("wings/Membrane")
#@onready var Deltoid_L = get_node("Deltoid")
#@onready var Forearm_L = get_node("Forearm")
#@onready var Membrane_R = get_node("Membrane_001")
#@onready var Deltoid_R = get_node("Deltoid_001")
#@onready var Forearm_R = get_node("Forearm_001")

#@export var wing_membrane_offset = Vector3(0.0, -0.38, 0.0)
#@onready var membrane_initial_pos = Membrane_L.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_children())
	print(wing_skeleton.get_bone_count())
	for bone in wing_skeleton.get_bone_count():
		print(wing_skeleton.get_bone_pose_position(bone))
		print(wing_skeleton.get_bone_pose_rotation(bone))
	print(wing_dive_pose)
	#print(wing_dive.get_children())
	#print(Membrane_L.position)
	#print(Membrane_R.position)
	#Deltoid_L.hide()
	#Forearm_L.hide()
	#Deltoid_R.hide()
	#Forearm_R.hide()
	
	#wing_membrane_offset.z += membrane_initial_pos.z
	#bone_simulation.physical_bones_start_simulation()
	pass # Replace with function body.

var last_x_direction = 0.0

var target_pose# = wing_rest_pose

var target_rotation_left = 0
var target_rotation_right = 180
var target_rotation = 0.0
var facing = LEFT
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#target_pose = wing_rest_pose
	
	if dragon_node.is_flying:
		if dragon_node.wingbeat_afterburner > 3:
			target_pose = wing_down_pose
		elif dragon_node.is_flap_held:
			target_pose = wing_up_pose
		elif dragon_node.is_gliding: 
			target_pose = wing_glide_pose
		else:
			target_pose = wing_dive_pose
		HindLeg_L.rotation_degrees.x = -30
		HindLeg_R.rotation_degrees.x = -30
		ForeLeg_L.rotation_degrees.x = -30
		ForeLeg_R.rotation_degrees.x = -30
		#Membrane_L.rotation_degrees.z = 80
		#Membrane_L.rotation_degrees.x = -10
		#Membrane_L.position = wing_membrane_offset
		#Membrane_L.position.x *= -1
		#Membrane_R.position = wing_membrane_offset
		#Membrane_R.rotation_degrees.z = -80
		#Membrane_R.rotation_degrees.x = -10
	else:
		target_pose = wing_rest_pose
		HindLeg_L.rotation_degrees.x = -90
		HindLeg_R.rotation_degrees.x = -90
		ForeLeg_L.rotation_degrees.x = -90
		ForeLeg_R.rotation_degrees.x = -90
		#Membrane_L.position = membrane_initial_pos
		#Membrane_R.position = membrane_initial_pos
		#Membrane_L.rotation_degrees.z = 0
		#Membrane_R.rotation_degrees.z = 0
	
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
		
	## Setting our Wing poses	
	change_pose(target_pose)
	
	#Membrane_L.rotation_degrees.z -= 4
	#print(rotation_degrees.y)
	
## The pose is passed in as the skeleton that we need.
func change_pose(new_pose):
	for bone in wing_skeleton.get_bone_count():
		#wing_skeleton.set_bone_pose_position(bone,new_pose.get_bone_pose_position(bone))
		wing_skeleton.set_bone_pose_rotation(bone,new_pose.get_bone_pose_rotation(bone))
		#print(wing_skeleton.get_bone_pose_position(bone))
		#print(wing_skeleton.get_bone_pose_rotation(bone))
