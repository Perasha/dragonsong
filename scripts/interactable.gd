extends Sprite2D

@onready var tooltip = get_node("Interactable/ColorRect")
@onready var speechbubble = get_node("%Thought")
var can_interact = false
@export var is_collectible = false

@export var object_data = {
	"type" : "statue",
	"text" : "This statue feels like an old memory."
}

func _ready() -> void:
	get_node("Interactable").body_entered.connect(_on_interactable_body_entered)
	get_node("Interactable").body_exited.connect(_on_interactable_body_exited)


signal interact(object,player)

func collect():
	if object_data["type"] == "key_fragment":
		GlobalData.collected_keys += 1

func _on_interactable_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		tooltip.show()
		can_interact = true
		interact.emit(self,body)
		pass # Replace with function body.


func _on_interactable_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		tooltip.hide()
		can_interact = false
		interact.emit(self,body)
	pass # Replace with function body.
