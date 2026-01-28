extends RigidBody2D

## States
enum {IDLE,ATTACK,FLEE,MOVE,DEAD}

## Loadable Statistics -------------------------------
@export var species = "Bison"
@export var health = 10
@export var speed = 100
@export var strength = 3
var food_amount = health
var behavior = EntityBehavior.HERD


## Process Variables ---------------------------------

@onready var entity_manager = get_node("/root/Main/EntityManager")
@onready var sprite = get_node("Sprite")
@onready var floor_check = get_node("FloorCheck")
#@onready var floor_check = get_node("FloorCheck")

## Pathfinding
var nav_tries = 0
var nav_tries_max = 10
var destination : Vector2

## Entity Interactions
var attacking_entity : RigidBody2D
var grabbing_entity : RigidBody2D
var attack_target : RigidBody2D

var attack_cooldown_base = 10
var attack_cooldown = attack_cooldown_base

## States
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
	speed += randi_range(0,50)

## SIGNALS

## NOTE: This timer fires after both _process and _physics_process.
func phys_tick() -> void:
	#print("----", name, " is ", is_moving, " moving")
	if not is_moving and is_grounded:
		if thought == IDLE:
			print(name, " is wandering.")
			wander()
	#elif thought == FLEE and is_grounded:
		#is_running = true
	if thought == ATTACK and attack_target != null:
		print("Attack mode!")
		melee_attack(attack_target,strength)
		#if attack_target == null and not is_moving:
		hunt(attack_target)

func _on_body_entered(body: Node) -> void:
	#print(body)
	pass # Replace with function body.

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
	#print(entity_manager)
	if health <= 0 and thought != DEAD:
		entity_manager.dead_entities.append(self)
		print("Killed!")
	
	## This creature is Vengeful and will start to attack an attacking target.
	elif attacking_entity:
		print("Attacking entity: ", attacking_entity)
		thought = ATTACK
		attack_target = attacking_entity
		
## Alert when Hit
func alert(threat):
	pass

## Attacking

## Locating Target
func hunt(target):
	if position.distance_to(target.position) > 1500:
		thought = IDLE
		attack_target = null
		attacking_entity = null
		is_moving = false
	else:
		destination = target.position
		#if not is_moving:
			#entity_manager.move_queue.append(self)
		thought = ATTACK
		is_moving = true
		is_running = true

## Melee Attack the Target
func melee_attack(target,damage_amount):
	if attack_cooldown == 0:
		attack_cooldown = attack_cooldown_base
		if position.distance_to(target.position) < 200:
			if target.is_in_group("player"):
				target.resources.health_update(-damage_amount)
			else:
				target.health_update(-damage_amount)
	else:
		attack_cooldown -= 1

## Move
func move_to(location):
	#print(name, " is moving!")
	destination = location
	var direction = position.direction_to(destination)
	var speed_limit = speed
	
	if is_running:
		speed_limit = speed * 2
	
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
	destination.y = position.y
	
	## If we're at the destination, awesome
	## If not, add ourselves to the queue. 

## PATHFINDING
var choice = [1,-1]
var temp_direction = 0
# Wander
func wander():
	#print("Move Queue before:", entity_manager.move_queue)
	randomize()
	temp_direction = choice.pick_random()
	temp_direction *= randi_range(300,2500)
	destination = Vector2(temp_direction,position.y)
	#entity_manager.move_queue.append(self)
	thought = IDLE
	is_moving = true
	is_running = false
	#print("Move Queue after:", entity_manager.move_queue)
