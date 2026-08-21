extends Node2D


func _ready() -> void:
	$CenterContainer/VBoxContainer/SubtitleLabel.text = "獲得いいね数: %d" % int(GameState.last_score)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
