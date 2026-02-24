extends Node

#@onready var haze = get_node("/root/Main/Camera2D/Haze")
#@onready var haze_bg = haze.get_node("BackgroundMix")
#@onready var haze_fg = haze.get_node("ForegroundMix")
@onready var wind = get_node("WindSystem")

var storm_color = Color(0.3,0.3,0.3,1.0)
var fog_color = Color(1,1,1,0.9)

var haze_layers = []
var parallax_bg_layers = []

enum {CALM, FOG, STORM}

var state_choices = [CALM, FOG, STORM]
var current_state = CALM
var next_state = CALM
var transition_time = 0
var transition_time_base = 500
var weather_duration = 1000

## Transitioning
var transitioning_objects = []
#var original_colors = []
var target_colors = []

## FOG EFFECT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#for node in haze.get_children():
	#	haze_layers.append(node)
	#for node in get_node("/root/Main/ParallaxBG").get_children():
		#parallax_bg_layers.append(node)
	#parallax_bg_layers.remove_at(0)
	#print(parallax_bg_layers)
	
	#set_fog(storm_color)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	## If we aren't transitioning, then the weather duration can now continue.
	weather_duration -= 1
	if weather_duration == 0:
		reset_weather()
	
	## Fog Transition
	if transitioning_objects != []:
		if transitioning_objects[transitioning_objects.size() - 1].color == target_colors[target_colors.size() - 1]:
			
			#original_colors = []
			target_colors = []
			transitioning_objects = []
		else:
			#transition_time -= 1
			var i = 0
			for object in transitioning_objects:
				object.color = object.color.lerp(target_colors[i],0.1)
				i += 1

func reset_weather():
	#time_delay = randi_range(100,1000)
	current_state = next_state
	next_state = state_choices.pick_random()
	weather_duration = randi_range(1000,1300)
	#wind.set_wind(current_state)
	#set_fog(current_state)

#func set_fog(state):
	#transition_time = transition_time_base
	#var color_bg
	#var color_fg
	##transitioning_objects.append(haze_bg)
	##transitioning_objects.append(haze_fg)
	#if state == FOG:
		#color_bg = fog_color
		#color_fg = fog_color
		#color_fg.a = 0.8
	#elif state == STORM:
		#color_bg = storm_color
		#color_fg = storm_color
		#color_fg.a = 0.8
	#elif state == CALM:
		#color_bg = Color(1,1,1,0)
		#color_fg = Color(1,1,1,0)
	#target_colors.append(color_bg)
	#target_colors.append(color_fg)
#func set_fog(color):
	#haze_bg.color = color
	#haze_fg.color = color
	#
	##haze_bg.color.a = 1.0
	#haze_fg.color.a = 0.8
#
#func clear_fog():
	#haze_bg.color = Color(1,1,1,0)
	#haze_fg.color = Color(1,1,1,0)
