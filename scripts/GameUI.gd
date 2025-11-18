extends CanvasLayer

@export var music_player: AudioStreamPlayer2D
@export var wave_controller: Node
@export var boat: Node

@onready var panel: Control = $Panel
@onready var choose_track_button: Button = $Panel/ChooseTrackButton
@onready var track_name_label: Label = $Panel/TrackNameLabel
@onready var file_dialog: FileDialog = $FileDialog

@onready var wave_amp_slider: HSlider = $Panel/MarginContainer/VBoxContainer/WaveAmpRow/WaveAmpSlider
@onready var bass_boost_slider: HSlider = $Panel/MarginContainer/VBoxContainer/BassBoostRow/BassBoostSlider
@onready var chop_amp_slider: HSlider = $Panel/MarginContainer/VBoxContainer/ChopAmpRow/ChopAmpSlider
@onready var follow_slider: HSlider = $Panel/MarginContainer/VBoxContainer/FollowRow/FollowSlider
@onready var damping_slider: HSlider = $Panel/MarginContainer/VBoxContainer/DampingRow/DampingSlider

func _ready() -> void:
	# Start hidden
	panel.visible = false

	# Configure FileDialog for audio files
	if file_dialog:
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.filters = PackedStringArray([
            "*.ogg, *.wav, *.mp3, *.flac; Audio Files"
		])

	# Initialize sliders from current values
	if wave_controller:
		if "base_amp" in wave_controller:
			wave_amp_slider.value = wave_controller.base_amp
		if "bass_amp_boost" in wave_controller:
			bass_boost_slider.value = wave_controller.bass_amp_boost
		if "chop_amp" in wave_controller:
			chop_amp_slider.value = wave_controller.chop_amp

	if boat:
		if "vertical_follow_strength" in boat:
			follow_slider.value = boat.vertical_follow_strength
		if "vertical_damping" in boat:
			damping_slider.value = boat.vertical_damping

	# Connect signals
	if choose_track_button:
		choose_track_button.pressed.connect(Callable(self, "_on_choose_track_pressed"))
	if file_dialog:
		file_dialog.file_selected.connect(Callable(self, "_on_file_selected"))

	wave_amp_slider.value_changed.connect(Callable(self, "_on_wave_amp_changed"))
	bass_boost_slider.value_changed.connect(Callable(self, "_on_bass_boost_changed"))
	chop_amp_slider.value_changed.connect(Callable(self, "_on_chop_amp_changed"))
	follow_slider.value_changed.connect(Callable(self, "_on_follow_changed"))
	damping_slider.value_changed.connect(Callable(self, "_on_damping_changed"))

func _input(event: InputEvent) -> void:
	# Toggle UI with F1
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			panel.visible = !panel.visible


# ───── Track selection via FileDialog ──────────────────────────────



func _on_file_selected(path: String) -> void:
	if music_player == null:
		push_warning("GameUI: music_player is not assigned.")
		return

	var stream := ResourceLoader.load(path) as AudioStream
	if stream == null:
		push_warning("GameUI: Failed to load audio stream from: %s" % path)
		return

	music_player.stream = stream
	music_player.play()

	if track_name_label:
		track_name_label.text = path.get_file()


# ───── Slider handlers ──────────────────────────────

func _on_wave_amp_changed(value: float) -> void:
	if wave_controller and "base_amp" in wave_controller:
		wave_controller.base_amp = value

func _on_bass_boost_changed(value: float) -> void:
	if wave_controller and "bass_amp_boost" in wave_controller:
		wave_controller.bass_amp_boost = value

func _on_chop_amp_changed(value: float) -> void:
	if wave_controller and "chop_amp" in wave_controller:
		wave_controller.chop_amp = value

func _on_follow_changed(value: float) -> void:
	if boat and "vertical_follow_strength" in boat:
		boat.vertical_follow_strength = value

func _on_damping_changed(value: float) -> void:
	if boat and "vertical_damping" in boat:
		boat.vertical_damping = value


func _on_choose_track_button_pressed() -> void:
	if file_dialog:
		file_dialog.popup_centered()
