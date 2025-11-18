extends RigidBody2D

@export var move_force: float = 800.0
@export var max_speed: float = 450.0
@export var water_drag: float = 2.0

var _wave_controller: Node2D

func _ready() -> void:
	_wave_controller = get_tree().get_first_node_in_group("wave_controller") as Node2D

func _physics_process(delta: float) -> void:
	var input_dir: float = 0.0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1.0
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1.0

	if abs(input_dir) > 0.0:
		apply_central_force(Vector2(input_dir * move_force, 0.0))

	# Soft horizontal speed clamp
	if linear_velocity.x > max_speed:
		linear_velocity.x = max_speed
	elif linear_velocity.x < -max_speed:
		linear_velocity.x = -max_speed

	# Simple drag
	linear_velocity.x = lerp(linear_velocity.x, 0.0, water_drag * delta)

	# Optional: tilt toward local wave slope
	if _wave_controller and _wave_controller.has_method("get_wave_slope_at_x"):
		var slope: float = _wave_controller.get_wave_slope_at_x(global_position.x)
		var target_rot: float = atan(slope * 0.9)
		rotation = lerp_angle(rotation, target_rot, 4.0 * delta)
