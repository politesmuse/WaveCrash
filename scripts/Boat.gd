extends RigidBody2D

@export_category("Movement")
@export var move_speed: float = 220.0
@export var acceleration: float = 700.0
@export var water_drag: float = 1.2           # how quickly the boat slows in water
@export var max_horizontal_speed: float = 360.0
@export var velocity: Vector2 = Vector2.ZERO

@export_category("Wave Ride")
@export var hover_offset: float = 10.0        # how many pixels above the wave surface to ride
@export var vertical_follow_strength: float = 70.0
@export var vertical_damping: float = 10.0
@export var tilt_strength: float = 0.9

@export_category("Physics Feel")
@export var gravity: float = 250.0
@export var max_vertical_speed: float = 900.0

@export_category("Jump")
@export var jump_force: float = 650.0
@export var grounded_distance_threshold: float = 10.0

@export_category("Water Interaction")
@export var max_submerge_depth: float = 12.0  # pixels

var _wave_controller: Node2D
var _last_surface_y: float = 0.0
var _is_grounded: bool = false

func _ready() -> void:
	_wave_controller = get_tree().get_first_node_in_group("wave_controller") as Node2D
	if _wave_controller == null:
		push_warning("Boat: No node in group 'wave_controller' found. Boat will not follow waves.")

func _physics_process(delta: float) -> void:
	var input_dir: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	_apply_horizontal(input_dir, delta)
	_apply_vertical_and_wave_follow(delta)
	_apply_jump()

	# Clamp vertical speed for stability
	if velocity.y > max_vertical_speed:
		velocity.y = max_vertical_speed
	elif velocity.y < -max_vertical_speed:
		velocity.y = -max_vertical_speed

	global_position += velocity * delta
	_clamp_submersion()
	_update_tilt(delta)

func _apply_horizontal(input_dir: float, delta: float) -> void:
	# Thrust toward target speed when there is input
	if abs(input_dir) > 0.0:
		var target_vx: float = input_dir * move_speed
		velocity.x = move_toward(velocity.x, target_vx, acceleration * delta)

	# Always apply water drag so the boat slowly coasts to a stop
	var drag: float = 1.0 / (1.0 + water_drag * delta)
	velocity.x *= drag

	velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)

func _apply_vertical_and_wave_follow(delta: float) -> void:
	_is_grounded = false
	velocity.y += gravity * delta

	var surface_y: float = global_position.y

	if _wave_controller:
		if "get_wave_height_at_x" in _wave_controller:
			surface_y = _wave_controller.get_wave_height_at_x(global_position.x)

		_last_surface_y = surface_y

		# Target a point slightly ABOVE the surface to feel like you skim the crest
		var target_y: float = surface_y - hover_offset
		var dy: float = target_y - global_position.y

		# Spring + damping
		var spring_accel: float = dy * vertical_follow_strength
		var damping_accel: float = -velocity.y * vertical_damping
		var total_accel: float = spring_accel + damping_accel

		velocity.y += total_accel * delta

		# Grounded if we're close to our target ride height and moving down or resting
		if abs(dy) <= grounded_distance_threshold and velocity.y >= 0.0:
			_is_grounded = true

func _apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and _is_grounded:
		velocity.y = -jump_force
		_is_grounded = false

func _clamp_submersion() -> void:
	var current_surface_y: float = _last_surface_y
	var max_allowed_y: float = current_surface_y + max_submerge_depth

	if global_position.y > max_allowed_y:
		global_position.y = max_allowed_y
		if velocity.y > 0.0:
			velocity.y = 0.0   # kill downward velocity so it doesn't keep trying to dive

func _update_tilt(delta: float) -> void:
	if _wave_controller and "get_wave_slope_at_x" in _wave_controller:
		var slope: float = _wave_controller.get_wave_slope_at_x(global_position.x)
		var target_rot: float = atan(slope * tilt_strength)
		rotation = lerp_angle(rotation, target_rot, 8.0 * delta)
