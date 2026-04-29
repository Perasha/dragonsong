extends Node

enum {IDLE,MOVE,GRABBED,DEAD}

# Menu Toggles
var option_hold_to_glide = false
var option_hold_to_hover = false
var option_hover_leave = false
var option_hold_to_look = false

@export var terminal_velocity = 3250.00

var ambrette_town = {
	"player_opinion" : 0,
	"threats" : []
}

var move_database = {
	"strike" : {"range" : 200, "damage" : 1}
}

var flower_text = """The rose has a light trace of magic on it.
It feels like a piece of the key is nearby."""

var Active_Quests = []

var collected_keys = 0

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
