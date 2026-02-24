extends Area2D

@onready var dragon_node = get_parent()
@onready var look_node = dragon_node.get_node("Camera_Marker")
@onready var fire_particles = []
var weapon_active = false

func _ready() -> void:
	for node in get_children():
		if node is GPUParticles2D:
			fire_particles.append(node)

func toggle_particles():
	if weapon_active:
		for node in fire_particles:
			node.emitting = true
	else:
		for node in fire_particles:
			node.emitting = false

func _input(event: InputEvent) -> void:
	## Breath Weapon
	if Input.is_action_pressed("breath_weapon"):
		var mouse_pos = get_global_mouse_position()
		#look_node.is_looking = true
		rotation = dragon_node.position.angle_to_point(mouse_pos)
		rotation_degrees += 180
		weapon_active = true
		toggle_particles()
		
	if Input.is_action_just_released("breath_weapon"):
		#look_node.is_looking = false
		weapon_active = false
		#fire_particles.emitting = false
		toggle_particles()

func _physics_process(delta: float) -> void:
	if weapon_active:
		for body in get_overlapping_bodies():
			if body.is_in_group("entity"):
				body.attacking_entity = dragon_node
				body.health_update(-1)
