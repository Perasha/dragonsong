extends Sprite2D

@onready var dragon_node = get_parent()
@onready var wing_node = get_node("Wings")

@onready var wing_folded_sprite = preload("res://Sprites/wings_folded.png")
@onready var wing_glide_sprite = preload("res://Sprites/wings_glide.png")
@onready var wing_up_sprite = preload("res://Sprites/wings_up.png")
@onready var wing_down_sprite = preload("res://Sprites/wings_down.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var hover_clock = 0
var hover_reset = 20
var wing_switch = false
enum {LEFT, RIGHT}
var facing = LEFT

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not dragon_node.is_hovering:
		wing_node.position.y = 0.0
	elif wing_switch == false:
		wing_node.texture = wing_up_sprite
		wing_node.position.y = 0.0
	rotation = 0.0
	flip_v = false
	#Rotating the sprite!
	if dragon_node.flight_direction.x < 0:
		flip_h = false
		if dragon_node.is_flying and not dragon_node.is_hovering:
			flip_v = true
			flip_h = true
	else:
		flip_h = true
		if dragon_node.is_flying and not dragon_node.is_hovering:
			flip_v = false
			#flip_h = false
	if dragon_node.is_flying and not dragon_node.is_hovering:
		rotation = dragon_node.flight_direction.angle()
	
	
	# Wing flaps!
	if flip_h: wing_node.flip_h = true
	else: wing_node.flip_h = false
	if flip_v: wing_node.flip_v = true
	else: wing_node.flip_v = false
	
	if not dragon_node.is_hovering:
		if dragon_node.is_gliding:
			wing_node.texture = wing_glide_sprite
		else:
			wing_node.texture = wing_folded_sprite
	
	if Input.is_action_pressed("flap"):
		wing_node.texture = wing_up_sprite
	#wing_node.texture = wing_down_sprite
	if dragon_node.just_jumped or dragon_node.on_wingbeat_cooldown:
		wing_node.texture = wing_down_sprite
		if flip_v:
			wing_node.position.y = -20
		else:
			wing_node.position.y = 20
		
	# Hovering animation
	if dragon_node.is_hovering:
		#print(hover_clock)
		if hover_clock < hover_reset:
			hover_clock += 1
		else:
			hover_clock = 0
		#if hover_clock == (hover_reset / 2) and wing_switch == true:
		#	wing_node.texture = wing_glide_sprite
		#	wing_node.position.y = 0.0
		if hover_clock == 0:
			if wing_switch: 
				wing_switch = false
				wing_node.texture = wing_up_sprite
				wing_node.position.y = 0.0
			else: 
				wing_switch = true
				wing_node.texture = wing_down_sprite
				if flip_v:
					wing_node.position.y = -20
				else:
					wing_node.position.y = 20
	if flip_h:
		facing = LEFT
	else:
		facing = RIGHT
	
	# Mouth Placement
