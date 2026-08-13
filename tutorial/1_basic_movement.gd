extends Node

## Detecting Basic Movement
var completed_left = false
var completed_right = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().dragon_node.direction_x == -1:
		completed_left = true
	if get_parent().dragon_node.direction_x == 1:
		completed_right = true
	if completed_left and completed_right:
		pass
