extends ProgressBar

@onready var label = get_node("Label")
@onready var dragon_node = get_parent().get_parent().get_node("dragon")
@onready var dragon_resources = dragon_node.get_node("Resources")

func _ready():
	max_value = dragon_resources.max_health
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(dragon_resources.health)
	value = dragon_resources.health
	pass
