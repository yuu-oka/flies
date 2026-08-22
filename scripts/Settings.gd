extends Node2D

const HIDDEN_BG_COLORS := [Color(0.302, 0.329, 0.106), Color(0.145, 0.114, 0.055)]
const HIDDEN_TEXT_COLOR := Color(0.82, 0.85, 0.55, 1)


func _ready() -> void:
	$CenterContainer/VBoxContainer/SfxRow/SfxToggle.button_pressed = GameState.sfx_enabled
	_set_toggle_text(GameState.sfx_enabled)
	$CenterContainer/VBoxContainer/VolumeRow/VolumeSlider.value = GameState.sfx_volume * 100.0
	_set_volume_label(GameState.sfx_volume)
	if GameState.hidden_mode:
		_apply_hidden_background()
		_apply_hidden_text_colors()


func _on_sfx_toggled(pressed: bool) -> void:
	GameState.set_sfx_enabled(pressed)
	_set_toggle_text(pressed)


func _on_volume_changed(value: float) -> void:
	var volume := value / 100.0
	GameState.set_sfx_volume(volume)
	_set_volume_label(volume)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Title.tscn")


func _set_toggle_text(enabled: bool) -> void:
	$CenterContainer/VBoxContainer/SfxRow/SfxToggle.text = "ON" if enabled else "OFF"


func _set_volume_label(volume: float) -> void:
	$CenterContainer/VBoxContainer/VolumeRow/VolumeValueLabel.text = "%d%%" % int(round(volume * 100.0))


func _apply_hidden_background() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray(HIDDEN_BG_COLORS)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_to = Vector2(0, 1)
	$Background.texture = texture


func _apply_hidden_text_colors() -> void:
	$CenterContainer/VBoxContainer/SfxRow/SfxLabel.add_theme_color_override("font_color", HIDDEN_TEXT_COLOR)
	$CenterContainer/VBoxContainer/VolumeRow/VolumeLabel.add_theme_color_override("font_color", HIDDEN_TEXT_COLOR)
	$CenterContainer/VBoxContainer/VolumeRow/VolumeValueLabel.add_theme_color_override("font_color", HIDDEN_TEXT_COLOR)
