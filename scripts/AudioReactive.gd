extends Node

var bass: float = 0.0
var mids: float = 0.0
var highs: float = 0.0

var _analyzer: AudioEffectSpectrumAnalyzerInstance = null

@export var bus_name: String = "Master"
@export var effect_index: int = 0

func _ready() -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning("AudioReactive: bus '%s' not found. Using bus 0 (Master by default)." % bus_name)
		idx = 0

	_analyzer = AudioServer.get_bus_effect_instance(idx, effect_index) as AudioEffectSpectrumAnalyzerInstance
	if _analyzer == null:
		push_warning("AudioReactive: No SpectrumAnalyzer effect at index %d on bus %s. Add one in the Audio bus layout." % [effect_index, bus_name])

func _process(delta: float) -> void:
	if _analyzer == null:
		return

	var target_bass: float = _get_band(20.0, 150.0)
	var target_mids: float = _get_band(150.0, 2000.0)
	var target_highs: float = _get_band(2000.0, 16000.0)

	var smooth: float = clamp(10.0 * delta, 0.0, 1.0)
	bass = lerp(bass, target_bass, smooth)
	mids = lerp(mids, target_mids, smooth)
	highs = lerp(highs, target_highs, smooth)

func _get_band(f_min: float, f_max: float) -> float:
	if _analyzer == null:
		return 0.0

	var mag: Vector2 = _analyzer.get_magnitude_for_frequency_range(f_min, f_max)
	var len_val: float = mag.length()
	return clamp(len_val * 4.0, 0.0, 1.0)
