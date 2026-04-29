extends Node3D

enum {LEFT, RIGHT}
@export_category("Key Nodes")
@export var dragon_node : RigidBody2D
@export var tail_spring : SpringBoneSimulator3D

@export_category("Spine Poses")
@export var spine_rest : PackedScene
@export var spine_up : PackedScene
@export var spine_down : PackedScene

@export_category("Wing Poses")
@export var wing_dive : PackedScene
@export var wing_flap_top : PackedScene
#@export var wing_flap_mid : PackedScene
@export var wing_flap_bottom : PackedScene
@export var wing_folded : PackedScene
@export var wing_glide : PackedScene

@onready var flight_rotation_timer = get_node("FlightPositionChange")
var is_flight_pos_timer_enabled = false

## Body
@onready var body = get_node("body")
@onready var spine = get_node("body/BodyArmature/Skeleton3D")
var tail_bones = []

## Body Poses
@onready var spine_rest_pose = spine_rest.instantiate().get_node("BodyArmature/Skeleton3D")
@onready var spine_up_pose = spine_up.instantiate().get_node("BodyArmature/Skeleton3D")
@onready var spine_down_pose = spine_down.instantiate().get_node("BodyArmature/Skeleton3D")

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
	#	pass
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

var target_wing_pose# = wing_folded_pose
var target_spine_pose
var target_z_rotation = 0.0

var target_rotation_left = 0
var target_rotation_right = 180
var target_rotation = 0.0
var facing = LEFT

var prev_flight_direction = Vector2(0,0)
var flight_dir_accel = Vector2(0,0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#position.z = dragon_node.position.x
	#position.y = dragon_node.position.y
	#target_wing_pose = wing_folded_pose
	#target_spine_pose = spine_rest_pose
	#tail_spring
	if dragon_node.is_flying:
		## This will add some spring-iness to the tail as we fly. If we were doing this in 3D we
		## probably wouldn't need to buuuuuut... here we are.
		
		## We're grabbing our Flight Direction, and detecting the amount of change between it and the previous time we checked.
		flight_dir_accel = (prev_flight_direction - dragon_node.flight_direction) * 8
		#print("Flight Direction change X:", prev_flight_direction - dragon_node.flight_direction)
		
		tail_spring.external_force.x = flight_dir_accel.x
		tail_spring.external_force.y = flight_dir_accel.y
		
		if dragon_node.is_flap_held:
			target_wing_pose = wing_up_pose
		else:
			if is_flight_pos_timer_enabled == false:
				flight_rotation_timer.start()
				is_flight_pos_timer_enabled = true
			if dragon_node.wingbeat_afterburner > dragon_node.wingbeat_reset_num:
				target_wing_pose = wing_down_pose
			elif dragon_node.is_flap_held:
				target_wing_pose = wing_up_pose
			elif dragon_node.is_gliding: 
				target_wing_pose = wing_glide_pose
			else:
				target_wing_pose = wing_dive_pose
			HindLeg_L.rotation_degrees.x = -30
			HindLeg_R.rotation_degrees.x = -30
			ForeLeg_L.rotation_degrees.x = -30
			ForeLeg_R.rotation_degrees.x = -30
			
			#if dragon_node.direction_y == 1:
			#	target_spine_pose = spine_down_pose
			#if dragon_node.direction_y == -1:
			#	target_spine_pose = spine_up_pose
	else:
		if is_flight_pos_timer_enabled == true:
			flight_rotation_timer.stop()
			is_flight_pos_timer_enabled = false
			target_z_rotation = 0
		tail_spring.external_force = Vector3(0,0,0)
		target_wing_pose = wing_folded_pose
		#target_spine_pose = spine_rest_pose
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
		
	## Setting our new poses	
	change_pose(target_wing_pose,wing_skeleton)
	#change_pose(target_spine_pose,spine)
	## Tail Movement
	#tail_IK()
	#Membrane_L.rotation_degrees.z -= 4
	#print(rotation_degrees.y)
	prev_flight_direction = dragon_node.flight_direction
	
	#var new_rotation = Quaternion()
	#var prev_rotation = Quaternion()
## Slightly wobble on the Z axis as we fly.
func _on_flight_position_change_timeout() -> void:
	target_z_rotation = randi_range(-50,50)
	flight_rotation_timer.wait_time = randf_range(0.5,10)
	#target_body_rotation.z = deg_to_rad(randi_range(-50,50))

## The pose is passed in as the skeleton that we need.
func change_pose(new_pose,skeleton):
	#print(skeleton.name)
	#print(new_pose)
	for bone in skeleton.get_bone_count():
		#print(bone)
		#print(skeleton.get_bone_pose_rotation(bone))
		var prev_rotation = skeleton.get_bone_pose_rotation(bone)
		#print(prev_rotation)
		var new_rotation = prev_rotation.slerp(new_pose.get_bone_pose_rotation(bone),0.15)
		skeleton.set_bone_pose_rotation(bone,new_rotation)

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
