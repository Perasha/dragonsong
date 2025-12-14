extends "object_base.gd"

## STATS
@export var health = 0.10
##-------------------------

@export var is_grounded = false
var entity = true
var dead = false
const DeathAura = preload("res://death_aura.tscn")

@onready var behavior_node = get_node("Behavior")
@onready var village_nav_node = get_parent().get_parent().get_node("NavNodes")
@onready var floor_check = get_node("FloorCheck")
@onready var sprite = get_node("Sprite")
#GlobalData.terminal_velocity
var default_speed = 100
var max_speed = 100
var max_run_speed = max_speed * 2

var is_running = false
#var is_grabbed = false

var destination = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	destination = position
	pass # Replace with function body.

#var previous_position 
#var current_position = position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	max_speed = default_speed
	is_running = false
	
	# Don't do this stuff if we're dead
	if not is_grabbed and not dead:
		#Check if we're on the ground
		if floor_check.has_overlapping_bodies():
			is_grounded = true
		else:
			is_grounded = false
			
		# If there's an active threat, run
		if active_threat != null:
			is_running = true
			move_away_from(active_threat)
	
	if not is_grabbed and not dead and is_grounded:
		if position.distance_to(destination) > 30:
			move_to(destination)
		else:
			linear_velocity *= 0.75

func move_to(destination):
	var direction = position.direction_to(destination)
	var speed_limit = max_speed
	if is_running:
		speed_limit = max_run_speed
	
	if abs(linear_velocity.x) < speed_limit:
		linear_velocity.x += direction.x * 8
	if abs(linear_velocity.x) > speed_limit:
		if linear_velocity.x < 0: linear_velocity.x = -speed_limit
		else: linear_velocity.x = speed_limit
	if abs(linear_velocity.y) > speed_limit:
		if linear_velocity.y > 0: linear_velocity.y = speed_limit
		else: linear_velocity.y = -speed_limit
	if destination.x > position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

#func get_destination():
	#pass
	#return village_nav_node.locations.pick_random()

func move_away_from(target):
	destination = position + -(Vector2(position.direction_to(target.position).x,0) * 1000)

var active_threat : RigidBody2D

func damage(value):
	health -= value
	# DEATH
	if health < 0 and not dead:
		health = 0
		dead = true
		sprite.rotation_degrees = 90
		sprite.position.y = 20
		#linear_velocity = Vector2(0,0)
		physics_material_override.friction = 0.5
		if floor_check != null:
			floor_check.queue_free()
		if behavior_node != null:
			behavior_node.queue_free()
		add_child(DeathAura.instantiate())

## FALL DAMAGE
var fall_impact_threshold = 6.0
var fall_impact = 0.0
func _on_body_entered(body: Node) -> void:
	#print("IMPACT, distance moved:", distance_moved)
	
	if distance_moved > fall_impact_threshold:
		fall_impact = distance_moved / 200
		damage(snappedf(fall_impact,0.01))
	pass # Replace with function body.
