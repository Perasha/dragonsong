extends PanelContainer


#@onready var self = get_node("%Thought")
@onready var speechbubble_label = get_node("%ThoughtLabel")
var current_object 
var speech_hide_timer_max = 200
var speech_hide_timer = 0
var speechbubble_is_shown = false
var showing_speechbubble = false
var hiding_speechbubble = false
#var can_interact = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show()
	modulate = Color(1,1,1,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hiding_speechbubble:
		fade_out(self,0.1)
	elif showing_speechbubble:
		fade_in(self,0.1)
	
	if speech_hide_timer > 0 and speechbubble_is_shown:
		#print(speech_hide_timer)
		speech_hide_timer -= 1
	elif speech_hide_timer == 0 and speechbubble_is_shown:
		speechbubble_is_shown = false
		fade_out(self,0.1)

func thought_start(text):
	show()
	speechbubble_is_shown = true
	fade_in(self,0.1)
	print("Text: ", text)
	print("Speech Bubble Label: ", speechbubble_label)
	speechbubble_label.text = str(text)
	speech_hide_timer = speech_hide_timer_max

func fade_in(object,time_step):
	showing_speechbubble = true
	hiding_speechbubble = false
	var original_color = object.modulate
	object.modulate = original_color.lerp(Color(1,1,1,1),time_step)
	if modulate == Color(1,1,1,1):
		showing_speechbubble = false

func fade_out(object,time_step):
	hiding_speechbubble = true
	showing_speechbubble = false
	var original_color = object.modulate
	object.modulate = original_color.lerp(Color(1,1,1,0),time_step)
	if modulate == Color(1,1,1,0):
		hiding_speechbubble = false
