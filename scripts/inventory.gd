extends Label

@onready var dragon_node = get_node("/root/Main/dragon")
@onready var dragon_resources = dragon_node.get_node("Resources")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str("Inventory\n", dragon_resources.collected_items, " / ", dragon_resources.inventory_size)
