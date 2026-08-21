extends Node2D

const REQUIRED_LETTER_COUNT := 13
const HIDDEN_BG_COLORS := [Color(0.302, 0.329, 0.106), Color(0.145, 0.114, 0.055)]

var _letter_count := 0
var _normal_bg_texture: Texture2D


func _ready() -> void:
	_normal_bg_texture = $Background.texture
	_update_title_text()
	_update_background()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_A and event.keycode <= KEY_Z:
			_letter_count += 1
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if _letter_count >= REQUIRED_LETTER_COUNT:
				_letter_count = 0
				GameState.hidden_mode = not GameState.hidden_mode
				_update_title_text()
				_update_background()
				return
			_letter_count = 0

	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_tree().change_scene_to_file("res://scenes/Description.tscn")


func _update_title_text() -> void:
	$CenterContainer/VBoxContainer/TitleLabel.text = "バエが集る" if GameState.hidden_mode else "映え映えQ"


func _update_background() -> void:
	if not GameState.hidden_mode:
		$Background.texture = _normal_bg_texture
		return
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray(HIDDEN_BG_COLORS)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_to = Vector2(0, 1)
	$Background.texture = texture
