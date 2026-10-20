@tool
extends RayCast2D

## Speed at which the laser extends when first fired, in pixels per second.
@export var cast_speed := 1600.0
## Maximum length of the laser in pixels.
@export var max_length_base := 1400.0
var max_length = max_length_base
## Distance in pixels from the origin to start drawing and firing the laser.
@export var start_distance := 40.0
## Base duration of the tween animation in seconds.
@export var growth_time := 0.1
@export var color := Color.WHITE: set = set_color

## If `true`, the laser is firing.
@export var is_casting := false: set = set_is_casting

var tween: Tween = null

## VISUAL EFFECTS & PARTICLES
@onready var impact_particles = get_node("FireMote_Impact")
@onready var beam_particles = get_node("FireMote_Beam")

@onready var beam: Line2D = %Beam
@onready var beam_width := beam.width
@onready var damage_area = get_node("DamageArea")

@onready var dragon_node = get_parent()

var mouse_pos

func _ready() -> void:
	set_color(color)
	set_is_casting(false)
	beam.points[0] = Vector2.RIGHT * start_distance
	beam.points[1] = Vector2.ZERO
	beam.visible = false

func _input(event: InputEvent) -> void:
	## Breath Weapon
	if Input.is_action_just_pressed("breath_weapon"):
		set_is_casting(true)
		#print("Holding breath")
		#mouse_pos = get_global_mouse_position()
		#look_node.is_looking = true
		#rotation = dragon_node.position.angle_to_point(mouse_pos)
		#max_length = max_length_base
		#raycaster.target_position.x = max_length_base
		#collision_node.position.x = -min_length
		#rotation_degrees += 180
		#weapon_active = true
		#toggle_particles()
		#raycaster.enabled = true
		
	if Input.is_action_just_released("breath_weapon"):
		set_is_casting(false)
		#look_node.is_looking = false
		#weapon_active = false
		#has_hit_ground = false
		#raycaster.enabled = false
		#collision_node.position.x = 0
		#fire_particles.emitting = false
		#toggle_particles()

var laser_end_position
@onready var laser_start_position := beam.points[1]

func _physics_process(delta: float) -> void:
	#print("Oh look at that physics process is going -_-")
	rotation = dragon_node.position.angle_to_point(get_global_mouse_position())
	rotation_degrees += 180
	target_position.x = move_toward(
		target_position.x,
		-max_length,
		cast_speed * delta
	)
	
	force_raycast_update()
	if is_colliding():
		laser_end_position = to_local(get_collision_point())
		max_length = Vector2.ZERO.distance_to(laser_end_position)
		impact_particles.emitting = true
		#impact_particles.position = target_position
	else:
		max_length = max_length_base
		laser_end_position = target_position
		impact_particles.emitting = false
	
	impact_particles.position = laser_end_position
	impact_particles.rotation = -rotation
	beam.points[0] = laser_end_position
	
	#var laser_start_position := beam.points[1]
	beam_particles.position = laser_start_position + (laser_end_position - laser_start_position) * 0.5
	beam_particles.process_material.emission_box_extents.x = laser_end_position.distance_to(laser_start_position) * 0.4
	#beam_particles.amount_ratio = 0.5 + ((max_length/max_length_base) * 0.5)
	#impact_particles.amount_ratio = beam_particles.amount_ratio


func set_is_casting(new_value: bool) -> void:
	#if is_casting == new_value:
	#	return
	is_casting = new_value

	set_physics_process(is_casting)

	if not beam:
		return

	if is_casting:
		var laser_start := Vector2.RIGHT * start_distance
		beam.points[0] = laser_start
		beam.points[1] = laser_start
		max_length = max_length_base
		beam_particles.emitting = true
		#appear()
	else:
		target_position = Vector2.ZERO
		beam_particles.emitting = false
		impact_particles.emitting = false
		#disappear()


func appear() -> void:
	beam.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(beam, "width", beam_width, growth_time * 2.0).from(0.0)


func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(beam, "width", 0.0, growth_time).from_current()
	tween.tween_callback(beam.hide)

#@onready var casting_particles: GPUParticles2D = %CastingParticles2D
#@onready var collision_particles: GPUParticles2D = %CollisionParticles2D
#@onready var beam_particles: GPUParticles2D = %BeamParticles2D

func set_color(new_color: Color) -> void:
	color = new_color
	if beam == null:
		return
	beam.modulate = new_color
	#casting_particles.modulate = new_color
	#collision_particles.modulate = new_color
	#beam_particles.modulate = new_color
