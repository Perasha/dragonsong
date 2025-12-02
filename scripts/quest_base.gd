extends Node

# This is for a Fetch Quest - deliver an object to a place.
@export var package : RigidBody2D
@export var drop_point : Area2D
# Called when the node enters the scene tree for the first time.

var quest_started = false
var quest_completed = false


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_drop_point_body_entered(body: Node2D) -> void:
	if body == package:
		print("Quest complete!")
	pass # Replace with function body.
