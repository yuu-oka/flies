extends CharacterBody2D

const SPEED := 150.0
const MIN_SPEED_FACTOR := 1.5
const MAX_SPEED_FACTOR := 3.0
const REACH_RADIUS := 60.0
const CLUSTER_OFFSET_RADIUS := 20.0
const PULLED_SPEED_MULTIPLIER := 3.0
const INFLUENCER_CHANCE := 0.08
const INFLUENCER_PULL_RATIO := 0.8
const DESPAWN_MARGIN := 80.0
const GLOW_COLOR := Color(1.0, 0.95, 0.3)
const RANDOM_DESPAWN_CHANCE := 0.05
const RANDOM_DESPAWN_MIN_DELAY := 5.0
const RANDOM_DESPAWN_MAX_DELAY := 20.0
const SELFIE_SPEED_FACTOR := 0.15
const ARRIVAL_THRESHOLD := 4.0

const CHARACTERS := [
	{
		"normal": preload("res://assets/npc/girl_a_normal.svg"),
		"selfie": preload("res://assets/npc/girl_a_selfie.svg"),
	},
	{
		"normal": preload("res://assets/npc/girl_b_normal.svg"),
		"selfie": preload("res://assets/npc/girl_b_selfie.svg"),
	},
	{
		"normal": preload("res://assets/npc/girl_c_normal.svg"),
		"selfie": preload("res://assets/npc/girl_c_selfie.svg"),
	},
	{
		"normal": preload("res://assets/npc/girl_d_normal.svg"),
		"selfie": preload("res://assets/npc/girl_d_selfie.svg"),
	},
]

var target: Node2D = null
var is_influencer := false

var _character: Dictionary
var _taking_selfie := false
var _glowing := false
var _despawning := false
var _despawn_point := Vector2.ZERO
var _speed_multiplier := 1.0
var _target_offset := Vector2.ZERO
var _speed := SPEED


func _ready() -> void:
	add_to_group("npc")
	_character = CHARACTERS.pick_random()
	$Visual.texture = _character["normal"]
	_speed = SPEED * randf_range(MIN_SPEED_FACTOR, MAX_SPEED_FACTOR)
	is_influencer = randf() < INFLUENCER_CHANCE
	if randf() < RANDOM_DESPAWN_CHANCE:
		var delay := randf_range(RANDOM_DESPAWN_MIN_DELAY, RANDOM_DESPAWN_MAX_DELAY)
		get_tree().create_timer(delay).timeout.connect(_on_random_despawn_timeout)


func _physics_process(_delta: float) -> void:
	if _despawning:
		_process_despawn()
		return

	if target == null or not is_instance_valid(target):
		if is_influencer and _glowing:
			_start_despawn()
			return
		_pick_new_target()

	if target != null and is_instance_valid(target):
		var dist := global_position.distance_to(target.global_position)
		var near := dist <= REACH_RADIUS
		_update_selfie_pose(near)
		if is_influencer and not _glowing and near:
			_start_glowing()
		var goal := target.global_position + _target_offset
		var to_goal := goal - global_position
		var current_speed := _speed * _speed_multiplier
		if _taking_selfie:
			current_speed *= SELFIE_SPEED_FACTOR
		if to_goal.length() <= ARRIVAL_THRESHOLD:
			velocity = Vector2.ZERO
		else:
			velocity = to_goal.normalized() * current_speed
	else:
		_update_selfie_pose(false)
		velocity = Vector2.ZERO
	move_and_slide()


func _update_selfie_pose(near: bool) -> void:
	if near == _taking_selfie:
		return
	_taking_selfie = near
	$Visual.texture = _character["selfie"] if near else _character["normal"]


func pull_toward(item: Node2D) -> void:
	if _glowing or _despawning:
		return
	target = item
	_speed_multiplier = PULLED_SPEED_MULTIPLIER
	_target_offset = _random_cluster_offset()


func _pick_new_target() -> void:
	_speed_multiplier = 1.0
	var items := get_tree().get_nodes_in_group("item")
	target = items.pick_random() if not items.is_empty() else null
	_target_offset = _random_cluster_offset()


func _random_cluster_offset() -> Vector2:
	var angle := randf() * TAU
	var radius := randf_range(0.0, CLUSTER_OFFSET_RADIUS)
	return Vector2(cos(angle), sin(angle)) * radius


func _start_glowing() -> void:
	_glowing = true
	$Visual.modulate = GLOW_COLOR
	_pull_other_npcs()


func _pull_other_npcs() -> void:
	var npcs := get_tree().get_nodes_in_group("npc")
	npcs.erase(self)
	npcs.shuffle()
	var count := int(round(npcs.size() * INFLUENCER_PULL_RATIO))
	for i in range(min(count, npcs.size())):
		var npc: Node = npcs[i]
		if npc.has_method("pull_toward"):
			npc.pull_toward(target)


func _on_random_despawn_timeout() -> void:
	if not _despawning:
		_start_despawn()


func _start_despawn() -> void:
	_despawning = true
	var viewport_size := get_viewport_rect().size
	var center := viewport_size / 2.0
	var dir := (global_position - center).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	_despawn_point = global_position + dir * viewport_size.length()


func _process_despawn() -> void:
	velocity = (_despawn_point - global_position).normalized() * _speed * PULLED_SPEED_MULTIPLIER
	move_and_slide()
	var viewport_size := get_viewport_rect().size
	if global_position.x < -DESPAWN_MARGIN or global_position.x > viewport_size.x + DESPAWN_MARGIN \
			or global_position.y < -DESPAWN_MARGIN or global_position.y > viewport_size.y + DESPAWN_MARGIN:
		queue_free()
