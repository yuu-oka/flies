extends Node2D

const LIFETIME := 1.8
const RISE_DISTANCE := 240.0
const WOBBLE_AMPLITUDE := 16.0
const HIDDEN_TINT := Color(0.647, 0.741, 0.494, 1)

var _age := 0.0
var _start_x := 0.0
var _wobble_phase := 0.0
var _wobble_speed := 3.0
var _rise_speed := 0.0


func _ready() -> void:
	add_to_group("heart")
	_start_x = position.x
	_wobble_phase = randf() * TAU
	_wobble_speed = randf_range(2.4, 3.6)
	_rise_speed = (RISE_DISTANCE * randf_range(0.8, 1.2)) / LIFETIME
	scale = Vector2.ONE * randf_range(0.16, 0.24)
	modulate.a = 0.0
	if GameState.hidden_mode:
		$Sprite2D.modulate = HIDDEN_TINT


func _process(delta: float) -> void:
	_age += delta
	var t := _age / LIFETIME
	if t >= 1.0:
		queue_free()
		return
	position.y -= _rise_speed * delta
	position.x = _start_x + sin(_age * _wobble_speed + _wobble_phase) * WOBBLE_AMPLITUDE
	modulate.a = clamp(minf(t * 5.0, (1.0 - t) * 2.5), 0.0, 1.0)
