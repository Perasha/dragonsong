extends HSlider

@export var val_label : Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	val_label.text = str(value)
