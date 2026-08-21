extends Node2D


func _ready() -> void:
	$CenterContainer/VBoxContainer/SubtitleLabel.text = "獲得いいね数: %d" % int(GameState.last_score)
	if GameState.hidden_mode:
		_apply_hidden_background()
		var color := Color(0.82, 0.85, 0.55, 1)
		$CenterContainer/VBoxContainer/SubtitleLabel.add_theme_color_override("font_color", color)
		$CenterContainer/VBoxContainer/PromptLabel.add_theme_color_override("font_color", color)


func _apply_hidden_background() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0.302, 0.329, 0.106), Color(0.145, 0.114, 0.055)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_to = Vector2(0, 1)
	$Background.texture = texture


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
