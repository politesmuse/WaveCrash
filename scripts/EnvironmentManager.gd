extends Node

@onready var world_env: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	set_night_env()  # pick your default here


func set_sunset_env() -> void:
	var env: Environment = Environment.new()

	# Background: warm pastel
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.95, 0.55, 0.6)

	# Ambient light
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.7, 0.55)
	env.ambient_light_energy = 1.2

	# Tonemapping
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.1
	env.tonemap_white = 8.0

	# "Fog" feel via adjustment (volumetric fog is 3D only, so we skip that)
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.05
	env.adjustment_saturation = 1.1

	# Glow/bloom
	env.glow_enabled = true
	env.glow_intensity = 0.75
	env.glow_hdr_threshold = 0.9
	env.glow_bicubic_upscale = true

	world_env.environment = env


func set_night_env() -> void:
	var env: Environment = Environment.new()

	# Background: deep blue-purple
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.07, 0.18)

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.45, 0.8)
	env.ambient_light_energy = 1.4

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.2
	env.tonemap_white = 6.0

	env.adjustment_enabled = true
	env.adjustment_brightness = 0.95
	env.adjustment_contrast = 1.1
	env.adjustment_saturation = 1.15

	env.glow_enabled = true
	env.glow_intensity = 1.0
	env.glow_hdr_threshold = 0.85
	env.glow_bicubic_upscale = true

	world_env.environment = env


func set_storm_env() -> void:
	var env: Environment = Environment.new()

	# Background: dark gray-blue
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.04, 0.07)

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.15, 0.18, 0.25)
	env.ambient_light_energy = 1.1

	# Use same ACES mapper, just darker & punchier
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.9
	env.tonemap_white = 4.0

	env.adjustment_enabled = true
	env.adjustment_brightness = 0.9
	env.adjustment_contrast = 1.2
	env.adjustment_saturation = 0.95

	env.glow_enabled = true
	env.glow_intensity = 1.3
	env.glow_hdr_threshold = 0.8

	world_env.environment = env
