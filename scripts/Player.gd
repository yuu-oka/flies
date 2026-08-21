extends CharacterBody2D

const SPEED := 300.0
const HIDDEN_TEXTURE := preload("res://assets/player/fly_player.svg")


func _ready() -> void:
	add_to_group("player")
	if GameState.hidden_mode:
		$Sprite2D.texture = HIDDEN_TEXTURE


func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * SPEED
	move_and_slide()
