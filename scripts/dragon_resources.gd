extends Node

@export var stamina_max = 500.0
var stamina = stamina_max

var flight_duration = {
	"up": 0.0,
	"down": 0.0,
	"left": 0.0,
	"right": 0.0
}

@onready var dragon_node = get_parent()
