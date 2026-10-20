extends Area2D

@onready var dragon_node = get_parent()
@onready var look_node = dragon_node.get_node("Camera_Marker")
@onready var collision_node = get_node("CollisionShape2D")
#@onready var beam = get_node("RayCast2D/Beam")
@onready var fire_particles = []
@onready var fire_particle_beam = get_node("FireMote_Beam")
@onready var fire_particle_ground = get_node("FireMote_Ground")

#@onready var raycaster = get_node("RayCast2D")


@onready var debug_text = get_node("Label")
@onready var debug_text2 = get_node("Label2")
@onready var debug_spot = get_node("TEST")
#var weapon_active = false

var min_length = 50
var max_length_base = 1200
var max_length = max_length_base
#var current_length = 0
var has_hit_ground = false

func _ready() -> void:
	for node in get_children():
		if node is GPUParticles2D:
			fire_particles.append(node)
	raycaster.add_exception(dragon_node)

func toggle_particles():
	if weapon_active:
		beam.show()
		for node in fire_particles:
			node.emitting = true
	else:
		beam.hide()
		for node in fire_particles:
			node.emitting = false

func _input(event: InputEvent) -> void:
	## Breath Weapon
	if Input.is_action_pressed("breath_weapon"):
		#print("Holding breath")
		var mouse_pos = get_global_mouse_position()
		#look_node.is_looking = true
		rotation = dragon_node.position.angle_to_point(mouse_pos)
		#max_length = max_length_base
		#raycaster.target_position.x = max_length_base
		#collision_node.position.x = -min_length
		rotation_degrees += 180
		#weapon_active = true
		toggle_particles()
		raycaster.enabled = true
		
	if Input.is_action_just_released("breath_weapon"):
		#look_node.is_looking = false
		weapon_active = false
		#has_hit_ground = false
		raycaster.enabled = false
		collision_node.position.x = 0
		#fire_particles.emitting = false
		toggle_particles()

func _physics_process(delta: float) -> void:
	debug_text.text = str(collision_node.position.x)
	if weapon_active:
		#print("Raycast Length: ")
		raycaster.force_raycast_update()
		#print(raycaster.get_collision_point().distance_to(to_local(raycaster.get_collision_point())))
		max_length = raycaster.get_collision_point().distance_to(raycaster.global_position)
		debug_text2.text = str(max_length)
		debug_spot.global_position = raycaster.get_collision_point()
		if max_length > max_length_base:
			max_length = max_length_base
		fire_particle_ground.rotation = -rotation
		if not has_hit_ground:
			fire_particle_ground.emitting = false
		else:
			fire_particle_ground.emitting = true
		
		if collision_node.position.x > -max_length:
			collision_node.position.x -= 50
		if collision_node.position.x < -max_length:
			collision_node.position.x = -max_length
		if collision_node.position.x > -min_length:
			collision_node.position.x = -min_length
		
		beam.points[0] = Vector2(1,0) * collision_node.position.x
		beam.points[1] = Vector2.ZERO
		
		fire_particle_ground.position = collision_node.position
		
		#for body in get_overlapping_bodies():
		#	if body.is_in_group("entity"):
		#		body.attacking_entity = dragon_node
		#		body.health_update(-1)


func _on_body_entered(body: Node2D) -> void:
	#print("Body: ", body)
	if body is StaticBody2D:
		print("Ground Detected")
		has_hit_ground = true
	pass # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	if body is StaticBody2D:
		print("Ground Detected")
		has_hit_ground = false
	pass # Replace with function body.
