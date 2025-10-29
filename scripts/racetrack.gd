extends Node

var has_started = false
var has_finished = false
var current_time = 0.0
var best_time

var timestamp_start = 0.0

@onready var hud = get_node("RacingHud")
@onready var hud_pointer = get_node("End/Direction_Indicator")

@onready var timer = get_node("Timer")
@onready var start_node = get_node("Start")
@onready var end_node = get_node("End")

var end_visible = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud_pointer.hide()
	pass # Replace with function body.

# This gives us the number of milliseconds that have passed since the engine started.
#print(Time.get_ticks_msec())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_started == true and has_finished == false:
		current_time = float(Time.get_ticks_msec() - timestamp_start) / 1000
	#print(current_time)
	
	# Update the Direction indicator if it's visible
	pass


func _on_start_body_entered(body: Node2D) -> void:
	print("STARTING!")
	if has_started == false:
		current_time = 0.00
		has_started = true
		has_finished = false
		timestamp_start = Time.get_ticks_msec()
		hud_pointer.show()
	# Create a timestamp of when we started


func _on_end_body_entered(body: Node2D) -> void:
	print("FINISHED!")
	if has_finished == false and has_started == true:
		has_finished = true
		has_started = false
		hud_pointer.hide()

func reset():
	has_finished = false
	has_started = false
	current_time = 0.0

# When the End point is Visible to the screen
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	print("Visible!")
	end_visible = true
	pass # Replace with function body.

# When the End point is NOT Visible to the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Hidden!")
	end_visible = false
	pass # Replace with function body.
