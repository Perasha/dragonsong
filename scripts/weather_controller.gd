extends CanvasLayer

@onready var dragon_node = get_parent().get_node("dragon")
@onready var weather_timer = get_node("WeatherTimer")
@onready var weather_label = get_node("CurrentWeather")

var weather_type = ["calm","storm"]
var weather_mode = "calm"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weather_timer.start()
	weather_label.text = weather_mode


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if weather_mode == "storm":
		if dragon_node.is_hovering:
			dragon_node.linear_velocity.x += 11.5
		elif dragon_node.is_flying:
			dragon_node.linear_velocity.x += 20
		else:
			dragon_node.linear_velocity.x += 10
		pass


func _on_weather_timer_timeout() -> void:
	#print("Weather shift!")
	if weather_mode == "calm":
		weather_mode = "storm"
	else:
		weather_mode = "calm"
	#weather_mode = weather_type.pick_random()
	print("Current weather: ", weather_mode)
	weather_label.text = weather_mode
	pass # Replace with function body.
