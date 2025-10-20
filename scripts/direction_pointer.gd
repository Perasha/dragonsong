extends Area2D

@onready var dragon_node = get_parent()

#dragon_node.flight_direction
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = dragon_node.flight_direction * 100
	pass
