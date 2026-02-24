extends GPUParticles2D

@onready var dragon_node = get_parent()
@onready var cast_node = get_node("CastEffect")
@onready var burst_node = get_node("BurstEffect")
@onready var cast_bar = get_node("ProgressBar")

@export var spell_duration = 10.0
var spell_timer = 0.0
var cast_timer = 0.0
var is_spell_active = false

var active_spell = {
	"name" : "Sonic Burst",
	"cast_time" : 2.0,
	"duration" : 3.0
}
# While the spell Sonic Burst is active, max_fly_speed becomes equal to terminal velocity. 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cast_bar.hide()
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if spell_timer > 0:
		spell_timer -= 1
		continue_spell(active_spell)
	else:
		emitting = false
		is_spell_active = false
		end_spell()
	
	if Input.is_action_pressed("cast_spell") and not is_spell_active:
		cast_node.emitting = true
		if cast_timer > 0:
			cast_timer -= 1
			cast_bar.value -= 1
		elif cast_timer == 0 and cast_bar.visible == false:
			cast_timer = active_spell["cast_time"] * 50
			cast_bar.show()
			cast_bar.max_value = cast_timer
			cast_bar.value = cast_timer
	if Input.is_action_just_released("cast_spell"):
		if cast_timer == 0:
			burst_node.emitting = true
			emitting = true
			is_spell_active = true
			spell_timer = 50 * active_spell["duration"]
			start_spell(active_spell)
		cast_timer = 0
		cast_node.emitting = false
		cast_bar.value = 0
		cast_bar.hide()
		
	cast_bar.value = cast_timer
	

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
