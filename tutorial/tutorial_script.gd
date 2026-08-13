extends Node

@onready var dragon_node = get_node("/root/Main/dragon")
@onready var thought_bubble = get_node("%Thought")
@onready var timer = get_node("Timer")

## Tutorial Progression
var tutorial_thought = [
	"Press A and D to move.",
	"SHIFT to run.",
	"Walking into a wall causes you to climb.",
	"Get a running start, then SPACEBAR to flap your wings.",
	"Hold SPACEBAR, then release to flap your wings harder.",
	"Use WASD to steer mid-flight.",
	"Press CTRL to slow down.",
	"Press SHIFT to toggle Gliding."
]
var tutorial_finished = 1#tutorial_thought.size() - 1

var active_quest = null
#var active_input_tasks = []
#var active_checks = []

#var loaded_quests = []
var quests = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Thought Bubble: ", thought_bubble)
	for node in get_children():
		print("Node: ", node)
		if node.is_in_group("quest"):
			quests.append(node)
	#print("Active Quest: ", active_quest)
	progress_tutorial(GlobalData.tutorial_progress)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.tutorial_progress == tutorial_finished:
		process_mode = Node.PROCESS_MODE_DISABLED
	
	for task in active_quest.tasks:
		if task["completed"] == false:
			if Input.is_action_just_pressed(task["key"]):
				complete_task(task)


func progress_tutorial(index):
	#print(quests)
	load_quest(quests[index])
	#print("Active Quest: ", active_quest)
	thought_bubble.thought_start(active_quest.text)

func _on_timer_timeout() -> void:
	thought_bubble.thought_start(active_quest.text)
	#progress_tutorial(GlobalData.tutorial_progress)

func _on_complete_quest():
	GlobalData.tutorial_progress += 1
	progress_tutorial(GlobalData.tutorial_progress)

func complete_task(task):
	print(active_quest.tasks[task["id"]])
	active_quest.tasks[task["id"]]["completed"] = true
	active_quest.tasks_completed += 1
	if active_quest.tasks_completed == active_quest.total_tasks:
		active_quest.is_completed = true
		_on_complete_quest()
	

func load_quest(quest_node):
	active_quest = quest_node
	print("Quest Node: ", quest_node)

## Quest Checks
# When loading an active quest, 


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
