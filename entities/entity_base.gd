extends RigidBody2D

## States
enum {IDLE,ATTACK,SEARCH,FLEE,MOVE,DEAD}

## Loadable Statistics -------------------------------
@export var species = "Bison"
@export var health = 10
@export var speed = 3
@export var strength = 3
@export var perception = 5
@export var stealth = 0

@export var active_move = {
	"name" : "strike",
	"range" : 1, # Melee range
	"damage": 1,
	"cooldown" : 10
}

@export var moves = {
	"strike" : {"range" : 1, "damage" : 1, "cooldown": 10}
}

var food_amount = health

## Unique Behavior
#@export var FoodSearch_script : GDScript
#@onready var FoodSearch = FoodSearch_script.new()

@export var PresenceBehavior_script : GDScript
@onready var PresenceBehavior = PresenceBehavior_script.new()

@export var ResponseSightThreat_script : GDScript
@onready var ResponseSightThreat = ResponseSightThreat_script.new()

@export var ResponseAttack_script : GDScript
@onready var ResponseAttack = ResponseAttack_script.new()

@export var ResponseDeath_script : GDScript
@onready var ResponseDeath = ResponseDeath_script.new()

## Process Variables ---------------------------------
@onready var entity_manager = get_node("/root/Main/EntityManager")
@onready var sprite = get_node("Sprite")
@onready var floor_check = get_node("FloorCheck")
@export var presence : Area2D
#@onready var perception_field = get_node("Perception")
#@onready var floor_check = get_node("FloorCheck")

## Pathfinding
var nav_tries = 0
var nav_tries_max = 10
var destination : Vector2
var look_target = position

## Entity Interactions
var attacking_entity : RigidBody2D
var grabbing_entity : RigidBody2D
var attack_target : RigidBody2D
var threat : RigidBody2D

var attack_cooldown_base = 10
var attack_cooldown = 0

## States
#var can_fly = false
var is_flying = false
var is_grounded = false
var is_moving = false
var is_running = false
var thought = IDLE
var prev_thought = null
var array_key = 0

## Methods ---------------------------------

func _ready() -> void:
	GlobalData.tick_timer.timeout.connect(phys_tick)
	destination = position
	speed += randi_range(-1,1)
	if presence:
		presence.get_node("CollisionShape2D").shape.radius = perception * 100
	#perception_field.get_node("CollisionShape2D").shape.radius = perception * 100

## SIGNALS

## NOTE: This timer fires after both _process and _physics_process.
func phys_tick() -> void:
	#print("----", name, " is ", is_moving, " moving")
	if attack_cooldown > 0:
		attack_cooldown -= 1
	
	if not is_moving and is_grounded:
		if thought == IDLE:
			#print(name, " is wandering.")
			wander()
	
	if thought == FLEE and is_grounded:
		#print("Fleeing!")
		#print(name)
		if threat != null:
			if position.distance_to(threat.position) > 1500:
				thought = IDLE
				threat = null
				is_running = false
			else:
				move_away_from(threat)
		else:
			thought = IDLE
	if thought == ATTACK and attack_target != null:
		hunt(attack_target,active_move)
	
	## Looking
	if look_target.x > position.x:
		# Facing Right
		sprite.flip_h = true
	else:
		# Facing Left
		sprite.flip_h = false

#func _on_body_entered(body: Node) -> void:
	#print(body)
#	pass # Replace with function body.

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	is_grounded = floor_check.is_colliding()
	if grabbing_entity:
		custom_integrator = true
		#print(grabbing_entity)
		reset_physics_interpolation.call_deferred()
		state.transform.origin = grabbing_entity.position
	else:
		custom_integrator = false

## Health Update
func health_update(value):
	health += value
	if health <= 0 and thought != DEAD:
		ResponseDeath.execute(self)
		entity_manager.dead_entities.append(self)
	
	## Execute our unique Response to being Attacked
	elif attacking_entity:
		ResponseAttack.execute(self)
		
## Alert when Hit
#func alert(threat):
	#pass

## Attacking ------------------------------------------

## Locating Target
func hunt(target, move):
	look_target = target.position
	if position.distance_to(target.position) > 1500:
		thought = IDLE
		attack_target = null
		attacking_entity = null
		is_moving = false
	else:
		var distance_to_target = int(position.distance_to(target.position))
		#print(distance_to_target)
		#print(move["range"])
		if distance_to_target - 4 > (move["range"] * 100):
			#print("Moving to target")
			destination = target.position
		else:
			#print("Attacking target")
			destination = position
			attack(target,move)
		#if not is_moving:
			#entity_manager.move_queue.append(self)
		thought = ATTACK
		is_moving = true
		is_running = true

## Attack the Target
func attack(target,move):
	#print(target)
	if attack_cooldown == 0:
		attack_cooldown = attack_cooldown_base
		#if position.distance_to(target.position) < move["range"]:
		if target.is_in_group("player"):
			target.resources.health_update(-(move["damage"] + strength))
		else:
			target.attacking_entity = self
			target.health_update(-(move["damage"] + strength))

## Move
func move_to(location):
	#print(name, " is moving!")
	destination = location
	var direction = position.direction_to(destination)
	var speed_limit = (speed * 50)
	#print("Speed: ", speed)
	#print("Speed limit: ", speed_limit)
	
	if is_running:
		speed_limit = (speed * 50) * 1.5
	
	if abs(linear_velocity.x) < speed_limit:
		linear_velocity.x += direction.x * 8
	if abs(linear_velocity.x) > speed_limit:
		if linear_velocity.x < 0: linear_velocity.x = -speed_limit
		else: linear_velocity.x = speed_limit
	if abs(linear_velocity.y) > speed_limit:
		if linear_velocity.y > 0: linear_velocity.y = speed_limit
		else: linear_velocity.y = -speed_limit
	#if abs(destination.x) >= (abs(position.x) + 1):
	
	if not is_flying:
		destination.y = position.y
	
	## If we're at the destination, awesome
	## If not, add ourselves to the queue. 

## PATHFINDING
var choice = [1,-1]
## Wander
func wander():
	var temp_direction = 0
	#print("Move Queue before:", entity_manager.move_queue)
	randomize()
	temp_direction = choice.pick_random()
	temp_direction *= randi_range(300,2500)
	destination = position + Vector2(temp_direction,position.y)
	#entity_manager.move_queue.append(self)
	thought = IDLE
	is_moving = true
	is_running = false
	look_target = destination
	#print("Move Queue after:", entity_manager.move_queue)

func move_away_from(target):
	destination = position + -(Vector2(position.direction_to(target.position).x,0) * randi_range(1000,2500))
	is_moving = true
	look_target = destination
