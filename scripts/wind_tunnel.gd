extends Area2D

var current_bodies = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		body.linear_velocity.y -= 50
		body.flight_direction.y += -.1
		body.is_stalling = false
			
