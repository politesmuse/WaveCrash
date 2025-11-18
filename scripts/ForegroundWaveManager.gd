extends Node2D

@export var segment_width: float = 800.0
@export var boat: Node2D

# Typed array of Polygon2D segments
var segments: Array[Polygon2D] = []

func _ready() -> void:
	for child in get_children():
		if child is Polygon2D:
			segments.append(child)
	# Godot 4: sort_custom takes a single Callable
	segments.sort_custom(Callable(self, "_sort_by_x"))

# Comparison function for sort_custom: return true if a should come before b
func _sort_by_x(a: Polygon2D, b: Polygon2D) -> bool:
	return a.position.x < b.position.x

func _process(_delta: float) -> void:
	if boat == null:
		return
	if segments.is_empty():
		return

	var boat_x: float = boat.global_position.x
	var total_width: float = segment_width * float(segments.size())

	for seg in segments:
		var seg_center_x: float = seg.global_position.x  # typed as float
		# If this segment is too far behind the boat, move it ahead
		if seg_center_x + segment_width * 0.5 < boat_x - segment_width:
			seg.position.x += total_width
