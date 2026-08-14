extends Node

enum {IDLE,MOVE,GRABBED,DEAD}

# Unlocks
var hover_unlocked = false

# Menu Toggles
#var option_hold_to_glide = false
var option_hold_to_dive = true
var option_dive_leave = false

var option_hold_to_hover = false
var option_hover_leave = false

var option_hold_to_look = false

@export var terminal_velocity = 3250.00

var first_hovered_item = false
var first_full_inventory = false

## Statistics
var created_piles = 0

var move_database = {
	"strike" : {"range" : 200, "damage" : 1}
}

var flower_text = """The rose has a light trace of magic on it.
It feels like a piece of the key is nearby."""

var Active_Quests = []

var collected_keys = 0

func _ready() -> void:
	pass
	#print(InputMap.get_actions())
	#for action in InputMap.get_actions():
		#print(action)
		#if action.begins_with("ui_"):
			#print(action, " is a built-in action.")
		#else:
			#user_inputs.append(action)
	#print("User actions: ", user_inputs)
	#
	#print(InputMap.action_get_events("flap")[0])

func test():
	print("Complete!")

@onready var tick_timer = get_node("/root/Main/TickTimer")

func _on_tick_timer_timeout() -> void:
	#print("Bang!")
	pass # Replace with function body.

func array_swapback(array,index,debug_info):
	#print(debug_info)
	## This removes the element we want, then swaps the element at the very back with the element we remove. 
	## Because we care not about the order of the array.
	#print("Array before:", array)
	#for entry in array:
	#	print(entry)
	#print("index: ", index)
	array[index] = array[array.size() - 1]
	array.remove_at(array.size() - 1)
	#print("Array after:")
	#for entry in array:
	#	print(entry)

func constrain_distance(point,anchor,distance):
	return ((point - anchor).normalized() * distance) + anchor
