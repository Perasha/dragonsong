extends Node2D

@export var segment_count := 10
@export var segment_length := 100.0
@export var damping := 0.96
@export var gravity := Vector2(0, 300)
@export var stiffness := 0.1       # pull toward the "straight" rest pose
@export var iterations := 4

@onready var anchor: Node2D = $TailAnchor
@onready var line: Line2D = $Tail_Line

var pos: Array[Vector2] = []
var prev: Array[Vector2] = []

func _ready() -> void:
	for i in segment_count:
		var p := anchor.global_position + Vector2.RIGHT.rotated(anchor.global_rotation) * segment_length * i
		pos.append(p)
		prev.append(p)
		line.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	var rest_dir := Vector2.RIGHT.rotated(anchor.global_rotation)  # tail points backward
	pos[0] = anchor.global_position
	prev[0] = pos[0]

	for i in range(1, segment_count):
		var vel := (pos[i] - prev[i]) * damping
		prev[i] = pos[i]
		pos[i] += vel + gravity * delta * delta
		# gentle spring toward a straight tail so it doesn't just hang limp
		#pos[i] = pos[i].lerp(pos[i - 1] + rest_dir * segment_length, stiffness)

	for _n in iterations:
		pos[0] = anchor.global_position
		for i in range(1, segment_count):
			var d := pos[i] - pos[i - 1]
			pos[i] = pos[i - 1] + d.normalized() * segment_length

	for i in segment_count:
		line.set_point_position(i, line.to_local(pos[i]))
