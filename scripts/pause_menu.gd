extends CanvasLayer

@onready var global_data = get_parent()

@onready var menu_button = get_node("MenuButton")
@onready var options_menu = get_node("OptionsMenu")
@onready var main_menu = get_node("MainMenu")
@onready var control_menu = get_node("ControlsMenu")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Escape"):
		if menu_button.visible == true:
			# Pause the game and open the menu, hiding the menu button
			_on_menu_button_pressed()
		elif main_menu.visible == false:
			_on_back_pressed()
		else:
			_on_resume_pressed()


func _on_resume_pressed() -> void:
	for node in get_children():
		node.hide()
	get_tree().paused = false
	menu_button.show()

func _on_hold_hover_toggled(toggled_on: bool) -> void:
	global_data.option_hold_to_hover = toggled_on

func _on_hold_glide_toggled(toggled_on: bool) -> void:
	#print(toggled_on)
	#print(global_data.option_hold_to_glide)
	global_data.option_hold_to_glide = toggled_on


func _on_options_pressed() -> void:
	options_menu.show()
	main_menu.hide()
	#print("What the hell is happening")
	#print(options_menu.visible)

## OPTIONS MENU BACK
func _on_back_pressed() -> void:
	for node in get_children():
		node.hide()
	main_menu.show()


func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_hover_leave_toggled(toggled_on: bool) -> void:
	global_data.option_hover_leave = toggled_on
	pass # Replace with function body.


func _on_controls_pressed() -> void:
	main_menu.hide()
	get_node("ControlsMenu").show()
	pass # Replace with function body.


func _on_menu_button_pressed() -> void:
	#print("Pressed!")
	get_tree().paused = true
	main_menu.show()
	menu_button.hide()
