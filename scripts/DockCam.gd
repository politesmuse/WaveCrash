extends Camera2D

@export_category("Targets")
@export var boat: Node2D
@export var dock_reference: Node2D    # e.g., DockStart/CameraDockRef

@export_category("Zoom")
@export var zoom_near: Vector2 = Vector2(0.6, 0.6)   # zoomed in (start)
@export var zoom_far: Vector2 = Vector2(1.0, 1.0)    # zoomed out (full journey)
@export var zoom_start_distance: float = 50.0        # pixels from dock before zoom begins
@export var zoom_full_distance: float = 600.0        # distance where zoom_far is fully applied

@export_category("Framing")
# Where the camera should sit relative to the boat in world space.
# near_offset: boat centered-ish (good for start screen)
# far_offset: boat more bottom-left when zoomed out
@export var near_offset: Vector2 = Vector2(0.0, -50.0)
@export var far_offset: Vector2 = Vector2(200.0, -200.0)

@export_category("Smoothing")
@export var position_lerp_speed: float = 4.0
@export var zoom_lerp_speed: float = 3.0

func _process(delta: float) -> void:
	if boat == null or dock_reference == null:
		return

	# 1) Compute distance from dock along X (use abs() if direction can vary)
	var dist: float = boat.global_position.x - dock_reference.global_position.x
	var abs_dist: float = abs(dist)

	# 2) Map distance to 0..1 for zoom/offset interpolation
	var t: float = 0.0
	if abs_dist > zoom_start_distance:
		t = (abs_dist - zoom_start_distance) / max(1.0, zoom_full_distance - zoom_start_distance)
		t = clamp(t, 0.0, 1.0)

	# 3) Interpolate zoom
	var target_zoom: Vector2 = zoom_near.lerp(zoom_far, t)
	zoom = zoom.lerp(target_zoom, zoom_lerp_speed * delta)

	# 4) Interpolate framing offset (near: boat more centered, far: boat bottom-left-ish)
	var target_offset: Vector2 = near_offset.lerp(far_offset, t)
	var target_pos: Vector2 = boat.global_position + target_offset

	global_position = global_position.lerp(target_pos, position_lerp_speed * delta)
