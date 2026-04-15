extends Node3D

enum {LEFT, RIGHT}

@export var wing_dive : PackedScene
@export var wing_flap_top : PackedScene
#@export var wing_flap_mid : PackedScene
@export var wing_flap_bottom : PackedScene
@export var wing_folded : PackedScene
@export var wing_glide : PackedScene

@export var dragon_node : RigidBody2D

@onready var flight_rotation_timer = get_node("FlightPositionChange")
var is_flight_pos_timer_enabled = false

## Body
@onready var body = get_node("body")

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
@onready var wing_folded_pose = wing_folded.instantiate().get_node("Armature_R/Skeleton3D")
@onready var wing_down_pose = wing_flap_bottom.instantiate().get_node("Armature_R/Skeleton3D")

## Tail
#@onready var tail = get_node("tail/TailArmature/Skeleton3D")
#var tail_dist_constraints = []
#var tail_bone_iterations

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
	#print(get_children())
	
	#tail_bone_iterations = tail.get_bone_count() - 1
	#for bone in (tail_bone_iterations):
	#	tail_dist_constraints.append(tail.get_bone_pose_position(bone).distance_to(tail.get_bone_pose_position(bone+1)))
	#print(tail_dist_constraints)
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

var target_pose# = wing_folded_pose
var target_z_rotation = 0.0

var target_rotation_left = 0
var target_rotation_right = 180
var target_rotation = 0.0
var facing = LEFT
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#target_pose = wing_folded_pose
	if dragon_node.is_flap_held:
		target_pose = wing_up_pose
	elif dragon_node.is_flying:
		if is_flight_pos_timer_enabled == false:
			flight_rotation_timer.start()
			is_flight_pos_timer_enabled = true
		if dragon_node.wingbeat_afterburner > dragon_node.wingbeat_reset_num:
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
	else:
		if is_flight_pos_timer_enabled == true:
			flight_rotation_timer.stop()
			is_flight_pos_timer_enabled = false
			target_z_rotation = 0
		target_pose = wing_folded_pose
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
	#print("target Z Rotation", target_z_rotation)
	rotation_degrees.y = lerpf(rotation_degrees.y,target_rotation,0.05)
	rotation_degrees.z = lerpf(rotation_degrees.z,target_z_rotation,0.05)
	
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
	change_wing_pose(target_pose)
	
	## Tail Movement
	#tail_IK()
	#Membrane_L.rotation_degrees.z -= 4
	#print(rotation_degrees.y)
	
	#var new_rotation = Quaternion()
	#var prev_rotation = Quaternion()
## The pose is passed in as the skeleton that we need.
func change_wing_pose(new_pose):
	for bone in wing_skeleton.get_bone_count():
		var prev_rotation = wing_skeleton.get_bone_pose_rotation(bone)
		var new_rotation = prev_rotation.slerp(new_pose.get_bone_pose_rotation(bone),0.15)
		#wing_skeleton.set_bone_pose_position(bone,new_pose.get_bone_pose_position(bone))
		wing_skeleton.set_bone_pose_rotation(bone,new_rotation)
		#print(wing_skeleton.get_bone_pose_position(bone))
		#print(wing_skeleton.get_bone_pose_rotation(bone))
	
## Slightly wobble on the Z axis as we fly.
func _on_flight_position_change_timeout() -> void:
	target_z_rotation = randi_range(-50,50)
	flight_rotation_timer.wait_time = randf_range(0.5,10)
	#target_body_rotation.z = deg_to_rad(randi_range(-50,50))

#func tail_IK():
	### Basic Spine IK
	#var tailbone_position = Vector3(0,dragon_node.global_position.x, dragon_node.global_position.y) - position
	#tail.set_bone_pose_position(0,tailbone_position)
	#print(tailbone_position)
	##spine_node.points[0] = (dragon_node.global_position - position)
	#for i in (tail_bone_iterations):
		#print(i)
		#var distance_constraint = tail_dist_constraints[i]#tail.get_bone_pose_position(i)
		#print(distance_constraint)
		#tail.set_bone_pose_position(i+1,GlobalData.constrain_distance(tail.get_bone_pose_position(i+1),tail.get_bone_pose_position(i),distance_constraint))
		#print(GlobalData.constrain_distance(tail.get_bone_pose_position(i+1),tail.get_bone_pose_position(i),distance_constraint))
		##spine_node.points[i+1] = GlobalData.constrain_distance(spine_node.points[i+1],spine_node.points[i],distance_constraint)
	#pass
