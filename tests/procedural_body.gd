extends Node2D

## DEBUG NODES
@onready var com_freq_slider = get_node("/root/Main/HUD/COM_Freq")
@onready var com_amp_slider = get_node("/root/Main/HUD/COM_Amp")

#var skeleton = []
@export var dragon_node : RigidBody2D
@onready var com = get_node("COM")
@onready var com_rest_pos = com.position # Resting position of our Center Of Mass
@onready var hip = get_node("Hip")
@onready var hip_rest_pos = hip.position

@export var com_freq = .6
@export var com_amp = 1.63
var com_freq_base = com_freq
var com_amp_base = com_amp

var com_prev_pos = Vector2(0,0)
## Alright, so to begin,
## We'll be interpolating the Y value only to try and get a sin wave as we move.

## That is the KEY: We are MOVING in RESPONSE to MOVEMENT. 

## Sin Waves!
# sin(x * FREQ) ## Multiply or divide X to change the Frequency
# sin(x) * AMP ## Multiple/divide X OUTSIDE of sin to change the Amplitude

## SO,
## With increased speed, we want increased frequency *and* amplitude.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	com_freq_slider.value = com_freq
	com_amp_slider.value = com_amp
	#for node in get_children():
	#	skeleton.append(node)
	#print(skeleton)
	pass

#var t = 0.1

var current_position
var target_position


## Different modes:
## - Walking
## - Running
## - Climbing
## - Hovering
## Disable if not any of those.

var move_start_pos = Vector2()
var move_timer = 0.0

var prev_amp
var prev_freq
var prev_position
var hip_time_offset = 1.0

var is_in_air = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(dragon_node.direction_x)
	if dragon_node.direction_x == -1.0:
		scale.x = 1.0
	if dragon_node.direction_x == 1.0:
		scale.x = -1.0
	#print("Distance Moved: ", dragon_node.distance_moved)
	## DEBUG NUMBER SHIFTING
	com_freq_base = com_freq_slider.value
	#com_freq = com_freq_slider.value
	com_amp_base = com_amp_slider.value
	#print(sin(dragon_node.position.x))
	prev_position = position
	## First, begin interpolating this body's position to the RigidBody
	position = dragon_node.position #lerp(prev_position,dragon_node.position,cos(position.x))# - com_rest_pos
	
	if dragon_node.distance_moved > 0.01:
		move_timer += 0.1
		
		if dragon_node.is_grounded:
			## If we were in the air, that means we just landed.
			## Process landing animation
			
			is_in_air = false
			## Lowering our frequency based on speed
			prev_freq = com_freq
			com_freq = lerp(prev_freq,com_freq_base + float(int(dragon_node.distance_moved / 10)),0.1)
			
			prev_amp = com_amp
			com_amp = lerp(prev_amp,com_amp_base * int(dragon_node.distance_moved),0.1)
			
			#com_amp = com_amp_base * int(dragon_node.distance_moved)# + com_amp_base)#lerp(com_amp,com_amp_base * (dragon_node.distance_moved),0.01)# * dragon_speed_multiplier
			
			com.position.y = com_rest_pos.y + sin(move_timer * com_freq) * com_amp
			hip.position.y = hip_rest_pos.y + cos(move_timer * com_freq) * com_amp
			#hip.position.y = hip_rest_pos.y - (sin((move_timer * com_freq) + hip_time_offset) * com_amp) ## Adding this value at the end to offset the timing
			
			#print("Previous Frequency: ", prev_freq)
			#print("Current Frequency: ", com_freq)
		else:
			is_in_air = true
	else:
			#com_freq = 0
		move_timer = 0.0
		#position.y = 0.0
	
	#if com_freq == INF or com_freq == NAN:
	#	position.y = 0
	#else:
	#position.y = sin(dragon_node.position.x * com_freq) * com_amp
	#print(position.y)
	#target_position = dragon_node.position
	#t += delta
	#t = (1 - cos(PI * t)) / 2
	#position = position.lerp(dragon_node.position,0.1)
	#print(dragon_node.distance_moved)
	#print(position)
	
	#current_position = lerp(global_position, target_position, weight)
	#global_position = current_position
	#position.lerp(dragon_node.position,weight)
