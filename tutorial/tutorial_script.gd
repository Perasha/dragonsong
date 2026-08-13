extends Node

@onready var dragon_node = get_node("/root/Main/dragon")
@onready var thought_bubble = get_node("%Thought")
@onready var timer = get_node("Timer")
@onready var active_progress_bar = get_node("ActiveProgress/ProgressBar")

## Tutorial Progression
## Once we're at 5+, we want to use the timer.
var tutorial_thought = [
	"Press A and D to move.",
	"Hold SHIFT to run.",
	"Walking into a wall and holding W causes you to climb.",
	"Hold and release SPACEBAR to start flying. You might want a running start.",
	"Keep flapping to stay airborne. Use WASD to steer.",
	"Press SHIFT to toggle Gliding.",
	"Press CTRL to slow down."
]

var tutorial_finished = tutorial_thought.size()
var tutorial_current_stage = -1

var active_progress = 0
var max_progress = 800

var active_quest = null
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
		print("Node: ", node)
		if node.is_in_group("quest"):
			node.body_entered.connect(_on_questarea_enter.bind(node.stage))
			node.body_exited.connect(_on_questarea_leave.bind(node.stage))
			pass
			#quests.append(node)
	#print("Active Quest: ", active_quest)
	#progress_tutorial(GlobalData.tutorial_progress)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tutorial_current_stage == tutorial_finished:
		print(tutorial_current_stage, " ", tutorial_finished)
		print("Tutorial Finished.")
		process_mode = Node.PROCESS_MODE_DISABLED
	
	if tutorial_current_stage == 4: ## WASD Flight
		if active_progress_bar.visible == false:
			active_progress_bar.visible = true
		check_flight_movement()
		if active_progress >= max_progress:
			progress_tutorial()
	
	if tutorial_current_stage == 5: ## Gliding
		check_gliding()
		if active_progress >= max_progress:
			progress_tutorial()
	
	if tutorial_current_stage == 6: ## Slowing Down
		check_slow_down()
		if active_progress >= max_progress:
			tutorial_current_stage = 7
			active_progress_bar.visible = false
			thought_bubble.thought_start("Wonderful. You're ready to explore the world.")
	
	#for task in active_quest.tasks:
		#if task["completed"] == false:
			#if Input.is_action_just_pressed(task["key"]):
				#complete_task(task)


func progress_tutorial():
	active_progress = 0
	tutorial_current_stage += 1
	if tutorial_current_stage == 5:
		max_progress = 100
		active_progress_bar.max_value = max_progress
	#	print("Showing the progress bar")
	#	active_progress_bar.visible = true
	display_text(tutorial_current_stage)
	timer.start()
	#load_quest(quests[index])
	#thought_bubble.thought_start(active_quest.text)

func _on_timer_timeout() -> void:
	display_text(tutorial_current_stage)
	pass
	#thought_bubble.thought_start(active_quest.text)
	#progress_tutorial(GlobalData.tutorial_progress)

func display_text(stage):
	thought_bubble.thought_start(tutorial_thought[stage])

## Quest Checks
# When loading an active quest, 

func _on_questarea_enter(body: Node2D, stage):
	#print("Body: ", body)
	#print("Stage: ", stage)
	if stage > tutorial_current_stage:
		tutorial_current_stage = stage
		timer.start()
		display_text(tutorial_current_stage)
	pass

func _on_questarea_leave(body: Node2D, stage):
	if stage < tutorial_current_stage:
		for node in get_children():
			print("Node: ", node)
			if node.is_in_group("quest"):
				if node.stage == stage:
					node.process_mode = Node.PROCESS_MODE_DISABLED
	# Set the area to inactive, and disable it if its conditions have been met.
	#if stage >= 5:
	#	display_text(5)
	#	timer.start()
	pass

func check_flight_movement():
	if dragon_node.direction_x != 0:
		active_progress += 1
	if dragon_node.direction_y != 0:
		active_progress += 1
	if dragon_node.just_jumped:
		active_progress += dragon_node.stored_jump * 10
	active_progress_bar.value = active_progress

func check_slow_down():
	if dragon_node.is_hovering:
		active_progress += 1
	active_progress_bar.value = active_progress
	#return dragon_node.is_hovering

func check_gliding():
	if dragon_node.is_gliding:
		active_progress += 1
	active_progress_bar.value = active_progress
# For each condition we need to check, check each individual name
# If it's "flying", link the "emit_flying" signal to (receive_condition)



#func check_flying():
	#return dragon_node.is_flying
#
#func check_hovering():
	#return dragon_node.is_hovering
#
#func check_gliding():
	#return dragon_node.is_gliding
#
#func check_running():
	#return dragon_node.is_running
#
#func check_climbing():
	#return dragon_node.is_climbing
