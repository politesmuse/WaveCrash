extends Node2D

@export_category("Wave Shape")
@export var water_line_y: float = 315.0
@export_range(0.0, 200.0, 0.1) var base_amp: float = 40.0
@export_range(0.0, 5.0, 0.01) var base_freq: float = 0.5

@export_category("Wave Travel")
# Base scroll speed in pixels per second (sign controls direction)
@export_range(-500.0, 500.0, 1.0) var base_scroll_speed: float = 80.0
@export_range(-500.0, 500.0, 1.0) var chop_scroll_speed: float = 140.0

@export_category("Chop Waves")
@export_range(0.0, 100.0, 0.1) var chop_amp: float = 15.0
@export_range(0.0, 10.0, 0.1) var chop_freq: float = 2.5

@export_category("Audio Mapping")
@export_range(0.0, 5.0, 0.01) var bass_amp_boost: float = 2.0
@export_range(0.0, 5.0, 0.01) var bass_speed_boost: float = 1.5
@export_range(0.0, 5.0, 0.01) var mids_chop_boost: float = 1.5
@export_range(0.0, 5.0, 0.01) var highs_ripple_boost: float = 1.0

# Internal scroll offsets for directional movement
var _base_scroll_offset: float = 0.0
var _chop_scroll_offset: float = 0.0
var _time: float = 0.0

func _ready() -> void:
	add_to_group("wave_controller")

func _process(delta: float) -> void:
	_time += delta

	var bass: float = AudioReactive.bass
	var mids: float = AudioReactive.mids

	# Scroll speeds boosted by audio
	var base_speed_now: float = base_scroll_speed * (1.0 + bass * bass_speed_boost)
	var chop_speed_now: float = chop_scroll_speed * (1.0 + mids * 0.8)

	# Move the pattern along X in a consistent direction
	_base_scroll_offset += base_speed_now * delta
	_chop_scroll_offset += chop_speed_now * delta

func get_wave_height_at_x(world_x: float) -> float:
	# Scale down to avoid needing giant freq values
	var x: float = world_x * 0.01

	var bass: float = AudioReactive.bass
	var mids: float = AudioReactive.mids
	var highs: float = AudioReactive.highs

	# Audio-reactive amplitudes
	var amp_base: float = base_amp * (1.0 + bass * bass_amp_boost)
	var amp_chop: float = chop_amp * (1.0 + mids * mids_chop_boost)

	# Directional travel: use (x + scroll_offset)
	var h_base: float = sin((x + _base_scroll_offset * 0.01) * base_freq * TAU) * amp_base
	var h_chop: float = sin((x + _chop_scroll_offset * 0.01) * chop_freq * TAU) * amp_chop

	# Small high-frequency ripple that still uses time
	var ripple: float = sin(x * (chop_freq * 3.0) * TAU + _time * 6.0) * (5.0 + highs * highs_ripple_boost * 10.0)

	return water_line_y + h_base + h_chop + ripple

func get_wave_slope_at_x(world_x: float) -> float:
	var eps: float = 5.0
	var y1: float = get_wave_height_at_x(world_x - eps)
	var y2: float = get_wave_height_at_x(world_x + eps)
	return (y2 - y1) / (2.0 * eps)
