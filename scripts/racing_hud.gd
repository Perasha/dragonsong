extends CanvasLayer


@onready var current_time_label = get_node("Current_Time")
@onready var race_node = get_parent()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time_label.text = "Time:\n" + str(snappedf(race_node.current_time,0.01))
	pass


func _on_reset_button_up() -> void:
	var dragon_node = get_node("/root/Main/dragon")
	var camera_node = get_node("/root/Main/Camera2D")
	dragon_node.reset = true
	dragon_node.linear_velocity = Vector2(0,0)
	race_node.reset()
	camera_node.global_position = dragon_node.global_position
