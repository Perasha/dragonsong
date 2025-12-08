extends Node

#Pointer: "/root/Main"

# Menu Toggles
var option_hold_to_glide = false
var option_hold_to_hover = false
var option_hover_leave = true

@export var terminal_velocity = 2000.00

var ambrette_town = {
	"player_opinion" : 0,
	"threats" : []
}


func _on_tick_timer_timeout() -> void:
	#print(ambrette_town)
	pass # Replace with function body.
