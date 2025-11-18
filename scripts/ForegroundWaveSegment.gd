extends Polygon2D

@export var segment_width: float = 800.0
@export var resolution: int = 64
@export var bottom_y: float = 720.0

var wave_controller: Node2D

func _ready() -> void:
	wave_controller = get_tree().get_first_node_in_group("wave_controller") as Node2D
	if wave_controller == null:
		push_warning("ForegroundWaveSegment: No wave_controller found.")
	set_process(true)

func _process(_delta: float) -> void:
	if wave_controller == null:
		return

	var wc: Node2D = wave_controller
	if not wc.has_method("get_wave_height_at_x"):
		return

	var pts: PackedVector2Array = PackedVector2Array()
	var step: float = segment_width / float(resolution)
	var origin_x_local: float = -segment_width * 0.5

	for i in range(resolution + 1):
		var local_x: float = origin_x_local + step * float(i)
		var world_x: float = global_position.x + local_x
		var world_y: float = wc.get_wave_height_at_x(world_x)
		var local_y: float = world_y - global_position.y
		pts.append(Vector2(local_x, local_y))

	# Close polygon downwards to bottom_y
	pts.append(Vector2(origin_x_local + segment_width, bottom_y - global_position.y))
	pts.append(Vector2(origin_x_local, bottom_y - global_position.y))

	polygon = pts

	# Push audio bands into shader for this segment's material
	if material is ShaderMaterial:
		var sm: ShaderMaterial = material as ShaderMaterial
		sm.set_shader_parameter("u_bass", AudioReactive.bass)
		sm.set_shader_parameter("u_mids", AudioReactive.mids)
		sm.set_shader_parameter("u_highs", AudioReactive.highs)
