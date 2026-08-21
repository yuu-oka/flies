extends CharacterBody2D

const SPEED := 300.0
const HIDDEN_TEXTURE := preload("res://assets/player/fly_player.svg")
const ARRIVE_THRESHOLD := 6.0
const MARKER_PULSE_SPEED := 4.0
const MARKER_PULSE_AMOUNT := 0.08

var _fly_buzz_sound := preload("res://assets/audio/fly_buzz.wav")

var _click_target := Vector2.ZERO
var _has_click_target := false
var _marker_pulse_age := 0.0
var _buzz_player: AudioStreamPlayer


func _ready() -> void:
	add_to_group("player")
	if GameState.hidden_mode:
		$Sprite2D.texture = HIDDEN_TEXTURE
		_fly_buzz_sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_buzz_player = AudioStreamPlayer.new()
		_buzz_player.stream = _fly_buzz_sound
		add_child(_buzz_player)
	$TargetMarker.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_click_target(get_global_mouse_position())


func _set_click_target(target: Vector2) -> void:
	_click_target = target
	_has_click_target = true
	_marker_pulse_age = 0.0
	$TargetMarker.global_position = _click_target
	$TargetMarker.visible = true


func _process(delta: float) -> void:
	if $TargetMarker.visible:
		_marker_pulse_age += delta
		var pulse := 1.0 + sin(_marker_pulse_age * MARKER_PULSE_SPEED) * MARKER_PULSE_AMOUNT
		$TargetMarker.scale = Vector2.ONE * 0.45 * pulse


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		_clear_click_target()
		velocity = input_vector * SPEED
	elif _has_click_target:
		var to_target := _click_target - global_position
		if to_target.length() <= ARRIVE_THRESHOLD:
			_clear_click_target()
			velocity = Vector2.ZERO
		else:
			velocity = to_target.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	_update_buzz_sound()


func _update_buzz_sound() -> void:
	if _buzz_player == null:
		return
	if velocity != Vector2.ZERO:
		if not _buzz_player.playing:
			_buzz_player.play()
	elif _buzz_player.playing:
		_buzz_player.stop()


func _clear_click_target() -> void:
	_has_click_target = false
	$TargetMarker.visible = false
