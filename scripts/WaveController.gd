extends Node2D

@export_category("Visual Mapping")
# How much to scale the vertical wave motion for what you see on screen
@export var visual_vertical_scale: float = 0.25
# Where the visible "water line" should sit in world space
@export var visual_water_line_y: float = 311.0

@export_category("Wave Shape")
@export var water_line_y: float = 360.0
@export_range(0.0, 200.0, 0.1) var base_amp: float = 40.0
@export_range(0.0, 5.0, 0.01) var base_freq: float = 0.5
@export_range(0.0, 5.0, 0.01) var base_speed: float = 1.0

@export_category("Chop Waves")
@export_range(0.0, 100.0, 0.1) var chop_amp: float = 15.0
@export_range(0.0, 10.0, 0.1) var chop_freq: float = 2.5
@export_range(0.0, 5.0, 0.01) var chop_speed: float = 2.0

@export_category("Audio Mapping")
@export_range(0.0, 5.0, 0.01) var bass_amp_boost: float = 2.0
@export_range(0.0, 5.0, 0.01) var bass_speed_boost: float = 1.5
@export_range(0.0, 5.0, 0.01) var mids_chop_boost: float = 1.5
@export_range(0.0, 5.0, 0.01) var highs_ripple_boost: float = 1.0

var _time: float = 0.0

func _ready() -> void:
	add_to_group("wave_controller")

func _process(delta: float) -> void:
	_time += delta

func get_wave_height_at_x(world_x: float) -> float:
	var x := world_x * 0.01

	var bass := AudioReactive.bass
	var mids := AudioReactive.mids
	var highs := AudioReactive.highs

	var t_base := _time * (base_speed + bass * bass_speed_boost)
	var t_chop := _time * (chop_speed + mids * 1.5)

	var amp_base := base_amp * (1.0 + bass * bass_amp_boost)
	var amp_chop := chop_amp * (1.0 + mids * mids_chop_boost)

	var h_base := sin(x * base_freq * TAU + t_base) * amp_base
	var h_chop := sin(x * chop_freq * TAU + t_chop) * amp_chop
	var ripple := sin(x * (chop_freq * 3.0) * TAU + _time * 6.0) * (5.0 + highs * highs_ripple_boost * 10.0)

	  # 1) Canonical full-strength wave height
	var canonical_y: float = water_line_y + h_base + h_chop + ripple

	# 2) Offset from canonical baseline
	var offset: float = canonical_y - water_line_y

	# 3) Map to flattened visual wave:
	#    - scaled by visual_vertical_scale
	#    - centered around visual_water_line_y
	var visual_y: float = visual_water_line_y + offset * visual_vertical_scale

	return visual_y

func get_wave_slope_at_x(world_x: float) -> float:
	var eps := 5.0
	var y1 := get_wave_height_at_x(world_x - eps)
	var y2 := get_wave_height_at_x(world_x + eps)
	return (y2 - y1) / (2.0 * eps)
