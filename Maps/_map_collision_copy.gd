extends CollisionPolygon2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var polygon_source_node = get_parent().get_node("Polygon2D")
	polygon = polygon_source_node.polygon
