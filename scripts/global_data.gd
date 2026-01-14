extends Node

#Pointer: "/root/Main"

# Menu Toggles
var option_hold_to_glide = false
var option_hold_to_hover = false
var option_hover_leave = true
var option_hold_to_look = false

@export var terminal_velocity = 2750.00

var ambrette_town = {
	"player_opinion" : 0,
	"threats" : []
}

var flower_text = """The rose has a light trace of magic on it.
It feels like a piece of the key is nearby."""

var Active_Quests = []

var collected_keys = 0

func test():
	print("Complete!")

func _on_tick_timer_timeout() -> void:
	#print(ambrette_town)
	pass # Replace with function body.

func array_swapback(array,index):
	## This removes the element we want, then swaps the element at the very back with the element we remove. 
	## Because we care not about the order of the array.
	array[index] = array[array.size() - 1]
	array.remove_at(array.size() - 1)
