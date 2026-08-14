extends Node

@onready var dragon_node = get_node("/root/Main/dragon")
@onready var thought_bubble = get_node("%Thought")
@onready var timer = get_node("Timer")
@onready var active_progress_bar = get_node("ActiveProgress/ProgressBar")

## Tutorial Progression
## Once we're at 5+, we want to use the timer.
#var tutorial_thought = [
	#"Press A and D to move.",
	#"Hold SHIFT to run.",
	#"Walking into a wall and holding W causes you to climb.",
	#"While moving, hold and release SPACEBAR to start flying.",
	#"Hold W and keep flapping to stay airborne.",
	#"Use WASD to steer.",
	#"Press SHIFT to toggle Gliding.",
	#"Press CTRL to slow down."
#]

var tutorial_stages = [
	{"text" : "Press A and D to move.", "needed_progress" : 100, "test" : "flight_steering"},
	{"text" : "Hold SHIFT to run.", "needed_progress" : 50, "test" : null},
	{"text" : "While moving, hold and release SPACEBAR to start flying.", "needed_progress" : 20, "test" : null},
	#{"text" : "Hold W and keep flapping to stay airborne.", "needed_progress" : 300, "test" : "flight_basic"},
	{"text" : "Use WASD to steer.", "needed_progress" : 500, "test" : "flight_steering"},
	{"text" : "Hold and release SPACEBAR to gain a boost.", "needed_progress" : 20, "test" : "flight_big_flaps"},
	{"text" : "Hold SHIFT to dive.", "needed_progress" : 100, "test" : "flight_gliding"},
	{"text" : "Press CTRL to slow down.", "needed_progress" : 100, "test" : "flight_hovering"}
]

var tutorial_finished = tutorial_stages.size()
var tutorial_current_stage = -1

var active_progress = 0
var max_progress = 800

#var active_quest = null
#var active_input_tasks = []
#var active_checks = []

#var loaded_quests = []
#var quests = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active_progress_bar.max_value = max_progress
	active_progress_bar.visible = false
	pass
	#print("Thought Bubble: ", thought_bubble)
	for node in get_children():
		#print("Node: ", node)
		if node.is_in_group("quest"):
			node.body_entered.connect(_on_questarea_enter.bind(node.stage))
			node.body_exited.connect(_on_questarea_leave.bind(node.stage))
			pass
	stage_data = tutorial_stages[0]
			#quests.append(node)
	#print("Active Quest: ", active_quest)
	#progress_tutorial(GlobalData.tutorial_progress)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tutorial_current_stage == tutorial_finished:
		print(tutorial_current_stage, " ", tutorial_finished)
		print("Tutorial Finished.")
		thought_bubble.thought_start("Wonderful. You're ready to explore the world.")
		get_node("ActiveProgress").hide()
		process_mode = Node.PROCESS_MODE_DISABLED
	
	if stage_data["test"] == "flight_basic":
		check_flight_basic()
	elif stage_data["test"] == "flight_steering":
		check_steering()
	elif stage_data["test"] == "flight_gliding":
		check_gliding()
	elif stage_data["test"] == "flight_hovering":
		check_slow_down()
	elif stage_data["test"] == "flight_big_flaps":
		check_flap()
	active_progress_bar.value = active_progress
	
	if active_progress >= max_progress:
			progress_tutorial()

var stage_data
func progress_tutorial():
	active_progress = 0
	tutorial_current_stage += 1
	if tutorial_current_stage < tutorial_finished:
		stage_data = tutorial_stages[tutorial_current_stage]
		#print("Test Needed: ", stage_data["test"])
		if stage_data["test"] != null:
			active_progress_bar.visible = true
			max_progress = stage_data["needed_progress"]
			active_progress_bar.max_value = max_progress
		else:
			#print("Test data null, not showing")
			active_progress_bar.visible = false
		display_text(tutorial_current_stage)
		timer.start()
	else:
		tutorial_current_stage = tutorial_finished

func _on_timer_timeout() -> void:
	if active_progress < max_progress:
		display_text(tutorial_current_stage)
	pass
	#thought_bubble.thought_start(active_quest.text)
	#progress_tutorial(GlobalData.tutorial_progress)

func display_text(stage):
	thought_bubble.thought_start(tutorial_stages[stage]["text"])

## Quest Checks
# When loading an active quest, 

func _on_questarea_enter(body: Node2D, stage):
	#print("Body: ", body)
	#print("Stage: ", stage)
	if stage > tutorial_current_stage:
		tutorial_current_stage = stage - 1
		progress_tutorial() ## Progressing the tutorial automatically increases our stage
		#tutorial_current_stage = stage
		timer.start()
		display_text(tutorial_current_stage)
	pass

func _on_questarea_leave(body: Node2D, stage):
	if stage < tutorial_current_stage:
		for node in get_children():
			#print("Node: ", node)
			if node.is_in_group("quest"):
				if node.stage == stage:
					node.process_mode = Node.PROCESS_MODE_DISABLED
	# Set the area to inactive, and disable it if its conditions have been met.
	#if stage >= 5:
	#	display_text(5)
	#	timer.start()
	pass

func check_flight_basic():
	if dragon_node.flight_direction.y < 0.1 and dragon_node.is_flying:
		active_progress += 1
	#if dragon_node.direction_y == -1:
	#	active_progress += 1
	#if dragon_node.just_jumped:
	#	active_progress += dragon_node.stored_jump * 10

func check_steering():
	if dragon_node.direction_x != 0:
		active_progress += 1
	if dragon_node.direction_y != 0:
		active_progress += 1

func check_slow_down():
	if dragon_node.is_hovering:
		active_progress += 1
	#return dragon_node.is_hovering

func check_gliding():
	if not dragon_node.is_gliding:
		active_progress += 1

func check_run():
	if dragon_node.is_running:
		active_progress += 1

func check_flap():
	if dragon_node.just_jumped:# and dragon_node.jump_strength == dragon_node.max_jump_strength:
		#print(dragon_node.recent_jump_strength)
		active_progress += dragon_node.recent_jump_strength


func _on_skip_button_down() -> void:
	tutorial_current_stage = tutorial_finished
