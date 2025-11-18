extends CharacterBody2D

@export_category("Movement")
@export var move_speed: float = 250.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0

@export_category("Wave Ride")
@export var vertical_follow_strength: float = 60.0
@export var vertical_damping: float = 8.0
@export var tilt_strength: float = 0.9

@export_category("Physics Feel")
@export var gravity: float = 400.0
@export var max_vertical_speed: float = 1200.0

@export_category("Jump")
@export var jump_force: float = 650.0
@export var grounded_distance_threshold: float = 12.0

@export_category("Water Interaction")
@export var max_submerge_depth: float = 10.0   # pixels

var _wave_controller: Node2D
var _is_grounded: bool = false
var _last_surface_y: float = 0.0

func _ready() -> void:
	_wave_controller = get_tree().get_first_node_in_group("wave_controller") as Node2D
	if _wave_controller == null:
		push_warning("Boat: No node in group 'wave_controller' found. Boat will not follow waves.")

func _physics_process(delta: float) -> void:
	var input_dir: float = 0.0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1.0
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1.0

	# ── Horizontal movement ─────────────────────────────
	var target_vx: float = input_dir * move_speed
	if abs(target_vx) > 0.1:
		velocity.x = move_toward(velocity.x, target_vx, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# ── Vertical movement (gravity + spring to wave) ────
	velocity.y += gravity * delta
	_is_grounded = false

	var surface_y: float = global_position.y  # will be overwritten if wave controller is valid

	if _wave_controller:
		var wc: Node = _wave_controller

		if "get_wave_height_at_x" in wc:
			surface_y = wc.get_wave_height_at_x(global_position.x)
			_last_surface_y = surface_y

			var dy: float = surface_y - global_position.y

			# Spring toward the surface
			var spring_accel: float = dy * vertical_follow_strength
			# Damping (drag)
			var damping_accel: float = -velocity.y * vertical_damping
			var total_accel: float = spring_accel + damping_accel

			velocity.y += total_accel * delta

			# Grounded if close to surface and not moving up strongly
			if abs(dy) <= grounded_distance_threshold and velocity.y >= 0.0:
				_is_grounded = true

		if "get_wave_slope_at_x" in wc:
			var slope: float = wc.get_wave_slope_at_x(global_position.x)
			var target_rot: float = atan(slope * tilt_strength)
			rotation = lerp_angle(rotation, target_rot, 8.0 * delta)

	# ── Jump input ──────────────────────────────────────
	if Input.is_action_just_pressed("jump") and _is_grounded:
		velocity.y = -jump_force
		_is_grounded = false

	# Clamp vertical speed for stability
	if velocity.y > max_vertical_speed:
		velocity.y = max_vertical_speed
	elif velocity.y < -max_vertical_speed:
		velocity.y = -max_vertical_speed

	# Apply movement
	move_and_slide()

	# ── Submersion clamp AFTER movement ─────────────────
	# Godot y increases downward:
	# if the boat's y is more than max_submerge_depth below the surface, push it up.
	var current_surface_y: float = _last_surface_y
	var max_allowed_y: float = current_surface_y + max_submerge_depth

	if global_position.y > max_allowed_y:
		global_position.y = max_allowed_y
		if velocity.y > 0.0:
			velocity.y = 0.0   # kill downward velocity so it doesn't keep trying to dive
