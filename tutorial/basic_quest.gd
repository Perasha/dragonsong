extends Node

#@onready var dragon_node = get_node("/root/Main/dragon")

@export var tasks = [
	{"type" : "Input", "key" : "move_left", "completed" : false}
]
@export var conditions = []
@export var text = ""

var is_completed = false
var tasks_completed = 0
@onready var total_tasks = tasks.size()
