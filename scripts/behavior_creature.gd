extends Node

## Debug
@onready var HungerBar = get_parent().get_node("Hunger")
@onready var RestBar = get_parent().get_node("Rest")
@onready var HealthBar = get_parent().get_node("Health")
## -------------

@onready var entity = get_parent()
@onready var entity_floorcheck = get_parent().get_node("FloorCheck")
@onready var global_data = get_node("/root/Main")
@onready var tick_timer = get_node("/root/Main/TickTimer")
@onready var dragon_node = get_node("/root/Main/dragon")

@export var hunger = 100.0
@export var rest = 100.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tick_timer.timeout.connect(_on_tick_timer_timeout)
	HungerBar.max_value = hunger
	RestBar.max_value = rest
	HealthBar.max_value = entity.health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	## DEBUG
	HungerBar.value = hunger
	RestBar.value = rest
	HealthBar.value = entity.health
	pass

# Need Decay
func _on_tick_timer_timeout():
	hunger -= 0.1
	rest -= 0.1
	pass

var target : RigidBody2D

func attack(target):
	pass

func eat():
	pass

func find_food():
	pass

func _on_presence_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.is_in_group("player"):
		pass
	pass # Replace with function body.
