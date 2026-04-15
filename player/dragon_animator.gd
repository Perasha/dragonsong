extends Node2D

@export var dragon_node : RigidBody2D
@export var camera_marker : Node2D
@onready var InteractNode = dragon_node.get_node("InteractArea")
@onready var ClimbDetector = dragon_node.get_node("ClimbDetector")

## Spine
@onready var spine_node = get_node("Spine")
## Here we're designating certain nodes as "torso", "hip", "tail", etc
## Two options. Either track them by number, or track them by position. 
## If we track by position, we only have to update the position once if it changes.
var anchors = {
	"head" : {"position": Vector2(-113.0,-9.0),"array_location": 0},
	"torso": {"position": Vector2(67,25),"array_location": 0},
	"hip": {"position": Vector2(244.0,3.0),"array_location": 0}
}
var spine_dist_constraints = []
var neck_points = [] ##Position, distance
var abdomen_points = []
var tail_points = []

## SPRITES
@onready var BiteAnimNode = dragon_node.get_node("Bite")
@onready var head = get_node("Head")
@onready var hip = get_node("Hip")
@onready var torso = get_node("Torso")
var head_offset = Vector2()
var hip_offset = Vector2()
var torso_offset = Vector2()

## Wings
@onready var wing_node = get_node("Torso/Wings")
@onready var wing_folded_sprite = preload("res://player/dragon_new/Wing_Folded.png")
@onready var wing_glide_sprite = preload("res://player/dragon_new/Wing_Folded.png")
@onready var wing_up_sprite = preload("res://player/dragon_new/Wing_Open_Up.png")
@onready var wing_down_sprite = preload("res://player/dragon_new/Wing_Open_Down.png")

var wing_position_up = Vector2(145,-459)
var wing_position_down = Vector2(149,437)
var wing_position_folded = Vector2(210,12)

## Legs
@onready var backleg_node = get_node("Hip/BackLeg")
@onready var frontleg_node = get_node("Torso/FrontLeg")
@onready var backleg_folded_sprite = preload("res://player/dragon_new/Folded_BackLeg.png")
@onready var backleg_stand_sprite = preload("res://player/dragon_new/Standing_BackLeg.png")
@onready var frontleg_folded_sprite = preload("res://player/dragon_new/Folded_FrontLeg.png")
@onready var frontleg_stand_sprite = preload("res://player/dragon_new/Standing_FrontLeg.png")

var backleg_position_stand = Vector2(23,74)
var backleg_position_folded = Vector2(46,41)
var frontleg_position_stand = Vector2(-37,67)
var frontleg_position_folded = Vector2(-2,46)

## We'll be flipping just the sprites we need, rather than the whole node.
@onready var anchor_sprites = [head,torso,hip]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## First, find the anchor points in our spine for our Head, Torso, and Hip.
	
	var i = 0
	for point in spine_node.points:
		## While we're here, might as well set up distance constraints.
		if i < spine_node.points.size()-1:
			spine_dist_constraints.append(spine_node.points[i].distance_to(spine_node.points[i+1]))
		for anchor in anchors:
			#print(anchor)
			#print(anchors[anchor]["position"])
			if anchors[anchor]["position"] == point:
				anchors[anchor]["array_location"] = i
		i += 1
	
	#head_offset = head.position
	## Next, figure out our Neck, Tail, and Abdomen
	# Is this a bit inefficient? Probably. Don't care.
	## Neck
	#i = 0 + anchors["head"]["array_location"]
	#for point in spine_node.points:
		# If we are adding to HEAD, add to HEAD. 
		#i += 1
		
	

var hover_clock = 0
var hover_reset = 20
var wing_switch = false

## LEFT = -1
## RIGHT = +1
## UP = -1
## DOWN = 1
enum {LEFT, RIGHT}
var facing = LEFT

@export var body_offset = Vector2(100,100)
var distance_constraint = 50.0
var new_scale = Vector2(1.0,1.0)
var new_rotation = 0.0
func _process(delta: float) -> void:
	#torso.position = dragon_node.global_position
	#position = dragon_node.global_position
	
	## Basic Spine IK
	spine_node.points[0] = (dragon_node.global_position - position) + (body_offset)
	for i in (spine_node.points.size() - 1):
		#print(i)
		distance_constraint = spine_dist_constraints[i]
		spine_node.points[i+1] = constrain_distance(spine_node.points[i+1],spine_node.points[i],distance_constraint)
	#pass
	#print(spine_node.points[18].distance_to(spine_node.points[19]))
	
	if dragon_node.is_grounded:
		backleg_node.texture = backleg_stand_sprite
		backleg_node.position = backleg_position_stand
		frontleg_node.texture = frontleg_stand_sprite
		frontleg_node.position = frontleg_position_stand
	else:
		backleg_node.texture = backleg_folded_sprite
		backleg_node.position = backleg_position_folded
		frontleg_node.texture = frontleg_folded_sprite
		frontleg_node.position = frontleg_position_folded
	
	if not dragon_node.is_hovering:
		wing_node.position = wing_position_folded
	elif wing_switch == false:
		wing_node.texture = wing_up_sprite
		wing_node.position = wing_position_up
	new_rotation = 0.0
	new_scale.x = 1.0
	new_scale.y = 1.0
	#torso.flip_v = false
	## Rotating the sprite!
	if dragon_node.flight_direction.x < 0:
		new_scale.x = 1.0
		if dragon_node.is_flying and not dragon_node.is_hovering:
			new_scale.y = -1.0
			new_scale.x = -1.0
	else:
		new_scale.x = -1.0
		if dragon_node.is_flying and not dragon_node.is_hovering:
			new_scale.y = 1.0
			#flip_h = false
	if dragon_node.is_flying and not dragon_node.is_hovering:
		new_rotation = dragon_node.flight_direction.angle()
	
	## Sprite Manipulation
	
	## Flip the sprites to their respective
	for node in anchor_sprites:
		node.scale.x = new_scale.x
		node.scale.y = new_scale.y
		node.rotation = new_rotation
	head.position = spine_node.points[anchors["head"]["array_location"]] + spine_node.position
	#head.rotation = spine_node.points[anchors["torso"]["array_location"]].angle_to_point(spine_node.points[anchors["torso"]["array_location"]+5])
	#print(spine_node.points[anchors["torso"]["array_location"]].angle_to_point(spine_node.points[anchors["torso"]["array_location"]+5]))
	
	torso.position = spine_node.points[anchors["torso"]["array_location"]] + spine_node.position
	hip.position = spine_node.points[anchors["hip"]["array_location"]] + spine_node.position
	#print(spine_node.points[anchors["head"]["array_location"]])
	#print(spine_node.points[0])
	# Wing flaps!
	#if torso.flip_h: wing_node.flip_h = true
	#else: wing_node.flip_h = false
	#if torso.flip_v: wing_node.flip_v = true
	#else: wing_node.flip_v = false
	
	if not dragon_node.is_hovering:
		if dragon_node.is_gliding:
			wing_node.texture = wing_glide_sprite
		else:
			wing_node.texture = wing_folded_sprite
	
	if Input.is_action_pressed("flap"):
		wing_node.texture = wing_up_sprite
		wing_node.position = wing_position_up
	#wing_node.texture = wing_down_sprite
	if dragon_node.just_jumped or dragon_node.on_wingbeat_cooldown:
		wing_node.texture = wing_down_sprite
		wing_node.position = wing_position_down
		#if torso.flip_v:
		#	wing_node.position.y = -20
		#else:
		#	wing_node.position.y = 20
		
	# Hovering animation
	if dragon_node.is_hovering:
		#print(hover_clock)
		if hover_clock < hover_reset:
			hover_clock += 1
		else:
			hover_clock = 0
		#if hover_clock == (hover_reset / 2) and wing_switch == true:
		#	wing_node.texture = wing_glide_sprite
		#	wing_node.position.y = 0.0
		if hover_clock == 0:
			if wing_switch: 
				wing_switch = false
				wing_node.texture = wing_up_sprite
				wing_node.position = wing_position_up
			else: 
				wing_switch = true
				wing_node.texture = wing_down_sprite
				wing_node.position = wing_position_down
	#print(flip_h)
	if dragon_node.flight_direction.x < 0:
		facing = LEFT
		InteractNode.position.x = -72
		ClimbDetector.position.x = -42
		ClimbDetector.target_position.x = -65
		BiteAnimNode.position.x = -112
		BiteAnimNode.flip_v = false
	else:
		facing = RIGHT
		InteractNode.position.x = 72
		ClimbDetector.position.x = 42
		ClimbDetector.target_position.x = 65
		BiteAnimNode.position.x = 112
		BiteAnimNode.flip_v = true

# Mouth Placement
func play_bite_animation():
	BiteAnimNode.show()
	BiteAnimNode.play()
	pass

func _on_bite_animation_finished() -> void:
	BiteAnimNode.hide()
	pass # Replace with function body.

func constrain_distance(point,anchor,distance):
	return ((point - anchor).normalized() * distance) + anchor
