@tool
extends Node2D

@export var segment_width: float = 1200.0 : set = _set_segment_width
@export var point_count: int = 24       : set = _set_point_count
@export var buoy_radius: float = 12.0   : set = _set_buoy_radius

@export var buoy_mass: float = 1.0
@export var wave_controller: Node2D
@export var boat: Node2D  

@export_category("Buoy Physics")
@export var buoy_spring_strength: float = 1200.0
@export var buoy_damping: float = 12.0

@export_category("Joints")
@export var joint_stiffness: float = 40.0
@export var joint_damping: float = 4.0

var _buoys: Array[RigidBody2D] = []
var _buoy_offset_x: Array[float] = []  # offsets from chain center in X


# ----- EDITOR PREVIEW -----

func _set_segment_width(v: float) -> void:
	segment_width = v
	queue_redraw()

func _set_point_count(v: int) -> void:
	point_count = max(v, 2)
	queue_redraw()

func _set_buoy_radius(v: float) -> void:
	buoy_radius = max(v, 1.0)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_READY:
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	if point_count < 2:
		return

	var half_width: float = segment_width * 0.5
	var step: float = segment_width / float(point_count - 1)
	var last: Vector2 = Vector2.ZERO

	for i in range(point_count):
		var x: float = -half_width + step * float(i)
		var pos: Vector2 = Vector2(x, 0.0)

		draw_circle(pos, buoy_radius, Color(0.3, 0.6, 1.0, 0.8))

		if i > 0:
			draw_line(last, pos, Color(0.4, 0.8, 1.0, 0.8), 2.0)

		last = pos


# ----- RUNTIME -----

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	print("[WaterChain] _ready called, spawning buoys…")

	if wave_controller == null:
		wave_controller = get_tree().get_first_node_in_group("wave_controller") as Node2D
		if wave_controller == null:
			push_warning("WaterChain: No wave_controller found; buoys will not be driven by waves.")

	_spawn_buoys()
	_spawn_joints()


func _spawn_buoys() -> void:
	_buoys.clear()
	_buoy_offset_x.clear()

	if point_count < 2:
		push_warning("WaterChain: point_count < 2, cannot spawn buoys.")
		return

	var half_width: float = segment_width * 0.5
	var step: float = segment_width / float(point_count - 1)

	# Center X of the chain at spawn: boat if available, else this node
	var center_x: float = boat.global_position.x if boat != null else global_position.x

	for i in range(point_count):
		var offset_x: float = -half_width + step * float(i)
		var world_x: float = center_x + offset_x

		var b := RigidBody2D.new()
		b.name = "Buoy_%d" % i
		b.mass = buoy_mass

		var shape_node := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = buoy_radius
		shape_node.shape = circle

		b.add_child(shape_node)
		add_child(b)

		# Place along this node's Y initially
		b.global_position = Vector2(world_x, global_position.y)

		_buoys.append(b)
		_buoy_offset_x.append(offset_x)

	print("[WaterChain] Spawned %d buoys." % _buoys.size())


func _spawn_joints() -> void:
	if _buoys.size() < 2:
		return

	for i in range(_buoys.size() - 1):
		var a: RigidBody2D = _buoys[i]
		var b: RigidBody2D = _buoys[i + 1]

		var joint := DampedSpringJoint2D.new()
		joint.name = "Joint_%d_%d" % [i, i + 1]
		joint.node_a = a.get_path()
		joint.node_b = b.get_path()

		joint.length = a.global_position.distance_to(b.global_position)
		joint.stiffness = joint_stiffness
		joint.damping = joint_damping

		add_child(joint)

	print("[WaterChain] Spawned %d joints." % (_buoys.size() - 1))


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if wave_controller == null:
		return
	if not wave_controller.has_method("get_wave_height_at_x"):
		return

	var count: int = _buoys.size()
	if count == 0:
		return

	# Chain center X follows the boat, or this node if no boat assigned
	var center_x: float = boat.global_position.x if boat != null else global_position.x

	for i in range(count):
		var b: RigidBody2D = _buoys[i]
		var offset_x: float = _buoy_offset_x[i]
		var target_x: float = center_x + offset_x

		# Sample wave at the buoy's X
		var world_x: float = target_x
		var target_y: float = wave_controller.get_wave_height_at_x(world_x)
		var dy: float = target_y - b.global_position.y
		var vy: float = b.linear_velocity.y

		var spring_force_y: float = dy * buoy_spring_strength
		var damping_force_y: float = -vy * buoy_damping
		var total_force_y: float = spring_force_y + damping_force_y

		b.apply_central_force(Vector2(0.0, total_force_y))

		# Lock X to the moving chain center + offset
		var pos: Vector2 = b.global_position
		pos.x = target_x
		b.global_position = pos

		# Zero horizontal velocity to avoid side drift
		var vel: Vector2 = b.linear_velocity
		vel.x = 0.0
		b.linear_velocity = vel


func get_buoys() -> Array[RigidBody2D]:
	return _buoys
