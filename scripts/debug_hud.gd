extends CanvasLayer


@onready var dragon_node = get_node("/root/Main/dragon")
@onready var dragon_resources = get_node("/root/Main/dragon/Resources")
@onready var camera_node = get_node("/root/Main/Camera2D")

@onready var speedLabel = get_node("Speed")
@onready var lin_vel_Label = get_node("LinearVelocity")
@onready var flight_dir_Label = get_node("FlightDirection")

@onready var dist_mov_label = get_node("DistanceMoved")
@onready var pos_label = get_node("Position")
@onready var glide_label = get_node("GlideToggle")
@onready var stalling_label = get_node("Stalling")
@onready var jump_str_label = get_node("JumpStrength")
@onready var afterbrn_label = get_node("Afterburner")

@onready var cam_scale_label = get_node("Camera Scale")

#@onready var stamina_bar = get_node("Stamina")
#@onready var stamina_label = get_node("Stamina/Label")

func _ready() -> void:
	pass
	#stamina_bar.max_value = dragon_resources.stamina_max

#@onready var current_gravity = get_node("HSlider/CurrentGravity")
#@onready var grav_slider = get_node("HSlider")
#Position
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("show_debug_hud"):
		if visible:
			hide()
		else:
			show()

func _on_update_timeout() -> void:
	speedLabel.text = "Speed: " + str(int(dragon_node.current_speed))
	lin_vel_Label.text = "Linear Velocity: " + str(int(dragon_node.linear_velocity.x)) + ", " + str(int(dragon_node.linear_velocity.y))
	flight_dir_Label.text = "Flight Direction: " + str(snapped(dragon_node.flight_direction.x, 0.01)) + ", " + str(snapped(dragon_node.flight_direction.y, 0.01))
	pos_label.text = str(int(dragon_node.position.x)) + ", " + str(int(dragon_node.position.y))	
	dist_mov_label.text = str(int(dragon_node.distance_moved))
	glide_label.text = "Glide Toggle: " + str(dragon_node.toggle_glide)
	jump_str_label.text = "Jump Strength: " + str(dragon_node.jump_strength)
	cam_scale_label.text = "Camera Scale\n" + str(camera_node.zoom)
	stalling_label.text = "Is Stalling: " + str(dragon_node.is_stalling)
	afterbrn_label.text = "Afterburner: " + str(dragon_node.wingbeat_afterburner)
	
	#stamina_bar.value = dragon_resources.stamina
	#stamina_label.text = str(snapped(dragon_resources.stamina,0.01))
	
	# Set Gravity
	#PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space,PhysicsServer2D.AREA_PARAM_GRAVITY,grav_slider.value)
	#current_gravity.text = str(grav_slider.value)
	

func _on_check_box_toggled(toggled_on: bool) -> void:
	print(toggled_on)
	dragon_node.option_hold_to_glide = toggled_on
	print(dragon_node.option_hold_to_glide)
	dragon_node.toggle_glide = false
	pass # Replace with function body.


#func _on_button_button_up() -> void:
	#dragon_resources.rest()
	#pass # Replace with function body.
