extends LightOccluder2D

func _ready() -> void:
	#var polygon_source_node = get_parent()
	occluder.polygon = get_parent().polygon
