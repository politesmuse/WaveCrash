extends GPUParticles2D

@export_range(0.0, 2000.0, 1.0) var base_emission: int = 80
@export_range(0.0, 4000.0, 1.0) var max_boost: int = 400

var _energy_s: float = 0.0

func _process(delta: float) -> void:
	var h: float = AudioReactive.highs
	var m: float = AudioReactive.mids

	var target: float = h * 1.2 + m * 0.8
	var smooth: float = clamp(8.0 * delta, 0.0, 1.0)
	_energy_s = lerp(_energy_s, target, smooth)

	var boost: float = pow(clamp(_energy_s, 0.0, 1.0), 1.5)
	amount = int(base_emission + float(max_boost) * boost)

	var pm: ParticleProcessMaterial = process_material as ParticleProcessMaterial
	if pm:
		var speed: float = lerp(20.0, 80.0, boost)
		pm.initial_velocity_min = speed * 0.5
		pm.initial_velocity_max = speed
