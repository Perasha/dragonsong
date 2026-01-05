extends GPUParticles2D

@onready var dragon_node = get_parent()
@onready var cast_node = get_node("CastEffect")
@onready var burst_node = get_node("BurstEffect")

@export var spell_duration = 10.0
var spell_timer = 0.0
var cast_timer = 0.0
var is_spell_active = false

var active_spell = {
	"name" : "Sonic Burst",
	"cast_time" : 3.0,
	"duration" : 3.0
}
# While the spell Sonic Burst is active, max_fly_speed becomes equal to terminal velocity. 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if cast_timer > 0:
		cast_timer -= 1
	elif spell_timer > 0:
		spell_timer -= 1
		continue_spell(active_spell)
	else:
		emitting = false
		is_spell_active = false
		end_spell()
	
	if Input.is_action_pressed("cast_spell"):
		cast_node.emitting = true
	if Input.is_action_just_released("cast_spell"):
		cast_node.emitting = false
		burst_node.emitting = true
		emitting = true
		
		is_spell_active = true
		spell_timer = 100 * active_spell["duration"]
		start_spell(active_spell)
	

func start_spell(spell):
	if spell["name"] == "Sonic Burst":
		dragon_node.current_speed = GlobalData.terminal_velocity
		dragon_node.apply_momentum()
		dragon_node.is_flying = true
		dragon_node.is_hovering = false

func continue_spell(spell):
	if spell["name"] == "Sonic Burst" and dragon_node.is_flying:
		dragon_node.current_speed = GlobalData.terminal_velocity
		dragon_node.apply_momentum()
		dragon_node.is_hovering = false

func end_spell():
	dragon_node.get_node("Resources").health_update(0)
