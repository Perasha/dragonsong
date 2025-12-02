extends Node

@onready var entity = get_parent()
@onready var global_data = get_node("/root/Main")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_floor_check_area_entered(area: Area2D) -> void:
	if area.name == "Presence":
		if global_data.ambrette_town["player_opinion"] < 0:
			entity.active_threat = area.get_parent()
	pass # Replace with function body.


func _on_floor_check_area_exited(area: Area2D) -> void:
	if area.name == "Presence":
		#print("Safe")
		entity.active_threat = null
	pass # Replace with function body.
