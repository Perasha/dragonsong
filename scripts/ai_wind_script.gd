extends Area2D

@export var wind_strength := 10.0
@export var wind_direction := Vector2.RIGHT
@export var noise_scale := 0.01
@export var time_scale := 0.5

## SHADER STUFF FOR DEBUGGING
@onready var debug_sprite := $DEBUG

var noise := FastNoiseLite.new()
var time := 0.0

func _ready():
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 1.0
	
	## DEBUG
	var mat = debug_sprite.material 
	mat.set_shader_parameter("noise_scale", noise_scale)
	mat.set_shader_parameter("time_scale", time_scale)
	
	var shape = $CollisionShape2D.shape
	var size = shape.extents * 2.0
	debug_sprite.scale = size
	
func _process(_delta):
	var mat = debug_sprite.material
	mat.set_shader_parameter("wind_strength", wind_strength)

	
func _physics_process(delta):
	time += delta * time_scale

	for body in get_overlapping_bodies():
		print(body.name)
		if body is RigidBody2D:
			var pos = body.global_position

			var n = noise.get_noise_3d(
				pos.x * noise_scale,
				pos.y * noise_scale,
				time
			)

			# n is between -1 and 1
			var force = wind_direction.normalized() * n * wind_strength
			body.apply_central_force(force)
