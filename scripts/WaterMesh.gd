extends Polygon2D

@export var water_chain: Node2D
@export var bottom_y: float = 900.0   # world-space y to close the mesh downward
@export var extra_margin: float = 100.0  # widen left/right a bit past buoys

func _ready() -> void:
	if water_chain == null:
		water_chain = get_parent() as Node2D

func _process(_delta: float) -> void:
	if water_chain == null:
		return
	if not water_chain.has_method("get_buoys"):
		return

	var buoys: Array = water_chain.get_buoys()
	if buoys.is_empty():
		return

	var pts: PackedVector2Array = PackedVector2Array()

	# Top edge: sample buoys from left to right
	# Convert their global positions into this Polygon2D's local space
	var left_idx: int = 0
	var right_idx: int = buoys.size() - 1

	var left_pos: Vector2 = (buoys[left_idx] as Node2D).global_position
	var right_pos: Vector2 = (buoys[right_idx] as Node2D).global_position

	# Add a bit of extra width so the mesh extends past the first/last buoy
	var left_x: float = left_pos.x - extra_margin
	var right_x: float = right_pos.x + extra_margin

	# First point: left extended point at left buoy's height
	var first_top: Vector2 = Vector2(left_x, left_pos.y)
	pts.append(to_local(first_top))

	# Middle: actual buoy positions
	for i in range(buoys.size()):
		var b: Node2D = buoys[i]
		pts.append(to_local(b.global_position))

	# Last top point: right extended point at right buoy's height
	var last_top: Vector2 = Vector2(right_x, right_pos.y)
	pts.append(to_local(last_top))

	# Bottom edge: close polygon downwards (two points)
	var bottom_left: Vector2 = Vector2(left_x, bottom_y)
	var bottom_right: Vector2 = Vector2(right_x, bottom_y)

	pts.append(to_local(bottom_right))
	pts.append(to_local(bottom_left))

	polygon = pts
