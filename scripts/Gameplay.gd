extends Node2D

const ItemScene := preload("res://scenes/Item.tscn")
const NpcScene := preload("res://scenes/Npc.tscn")
const HeartScene := preload("res://scenes/Heart.tscn")
const LikeSound := preload("res://assets/audio/like_chime.wav")
const SPAWN_INTERVAL := 1.5
const NPC_SPAWN_INTERVAL := 1.0
const SCREEN_MARGIN := 60.0
const OFFSCREEN_MARGIN := 40.0
const MIN_ITEM_DISTANCE := 150.0
const MAX_ITEM_SPAWN_ATTEMPTS := 20
const TIME_LIMIT := 60
const HEART_POINT_THRESHOLD := 1.5
const MAX_ACTIVE_HEARTS := 16
const HEART_SIDE_MARGIN := 50.0
const HEART_BOTTOM_MARGIN := 24.0
const FINALE_TIME_THRESHOLD := 15
const FINALE_SPAWN_SPEED_MULTIPLIER := 1.5
const FINALE_MIN_NPC_BURST := 3
const FINALE_MAX_NPC_BURST := 10
const FINALE_ITEM_SPAWN_MULTIPLIER := 1.5
const FINALE_MIN_ITEM_BURST := 2
const FINALE_MAX_ITEM_BURST := 3
const FINALE_TIMER_COLOR_A := Color(1.0, 0.15, 0.15, 1)
const FINALE_TIMER_COLOR_B := Color(1.0, 0.65, 0.0, 1)
const FINALE_TIMER_PULSE_SPEED := 6.0

const BGM_NORMAL_PATH := "res://assets/audio/bgm_normal.wav"
const BGM_HIDDEN_PATH := "res://assets/audio/bgm_hidden.wav"

var score := 0.0
var _time_remaining := TIME_LIMIT
var _heart_accumulator := 0.0
var _finale_active := false
var _finale_pulse_age := 0.0


func _ready() -> void:
	_apply_hidden_background()

	var like_sound_player := AudioStreamPlayer.new()
	like_sound_player.name = "LikeSoundPlayer"
	like_sound_player.stream = LikeSound
	like_sound_player.bus = GameState.SFX_BUS_NAME
	add_child(like_sound_player)

	var bgm_stream: AudioStreamWAV = load(BGM_HIDDEN_PATH if GameState.hidden_mode else BGM_NORMAL_PATH).duplicate()
	bgm_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	bgm_stream.loop_end = int(bgm_stream.get_length() * bgm_stream.mix_rate)
	var bgm_player := AudioStreamPlayer.new()
	bgm_player.name = "BgmPlayer"
	bgm_player.stream = bgm_stream
	bgm_player.bus = GameState.BGM_BUS_NAME
	add_child(bgm_player)
	bgm_player.play()

	var item_timer := Timer.new()
	item_timer.name = "ItemTimer"
	item_timer.wait_time = SPAWN_INTERVAL
	item_timer.autostart = true
	item_timer.timeout.connect(_spawn_item)
	add_child(item_timer)

	var npc_timer := Timer.new()
	npc_timer.name = "NpcTimer"
	npc_timer.wait_time = NPC_SPAWN_INTERVAL
	npc_timer.autostart = true
	npc_timer.timeout.connect(_spawn_npc)
	add_child(npc_timer)

	var countdown_timer := Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.autostart = true
	countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(countdown_timer)

	_update_score_label()
	_update_timer_label()


func _process(delta: float) -> void:
	if not _finale_active:
		return
	_finale_pulse_age += delta
	var t := (sin(_finale_pulse_age * FINALE_TIMER_PULSE_SPEED) + 1.0) / 2.0
	$TimerLabel.add_theme_color_override("font_color", FINALE_TIMER_COLOR_A.lerp(FINALE_TIMER_COLOR_B, t))


func _apply_hidden_background() -> void:
	if not GameState.hidden_mode:
		return
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0.302, 0.329, 0.106), Color(0.145, 0.114, 0.055)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_to = Vector2(0, 1)
	$Background.texture = texture


func _spawn_item() -> void:
	var count := randi_range(FINALE_MIN_ITEM_BURST, FINALE_MAX_ITEM_BURST) if _finale_active else 1
	for i in count:
		var item := ItemScene.instantiate()
		item.position = _find_item_spawn_position()
		item.points_earned.connect(_on_points_earned)
		add_child(item)


func _find_item_spawn_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var pos := Vector2.ZERO
	for attempt in MAX_ITEM_SPAWN_ATTEMPTS:
		pos = Vector2(
			randf_range(SCREEN_MARGIN, viewport_size.x - SCREEN_MARGIN),
			randf_range(SCREEN_MARGIN, viewport_size.y - SCREEN_MARGIN)
		)
		if _far_enough_from_items(pos):
			break
	return pos


func _far_enough_from_items(pos: Vector2) -> bool:
	for existing in get_tree().get_nodes_in_group("item"):
		if pos.distance_to(existing.global_position) < MIN_ITEM_DISTANCE:
			return false
	return true


func _spawn_npc() -> void:
	var count := randi_range(FINALE_MIN_NPC_BURST, FINALE_MAX_NPC_BURST) if _finale_active else 1
	for i in count:
		var npc := NpcScene.instantiate()
		npc.position = _random_offscreen_position()
		add_child(npc)


func _random_offscreen_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	match randi() % 4:
		0:
			return Vector2(randf_range(0, viewport_size.x), -OFFSCREEN_MARGIN)
		1:
			return Vector2(randf_range(0, viewport_size.x), viewport_size.y + OFFSCREEN_MARGIN)
		2:
			return Vector2(-OFFSCREEN_MARGIN, randf_range(0, viewport_size.y))
		_:
			return Vector2(viewport_size.x + OFFSCREEN_MARGIN, randf_range(0, viewport_size.y))


func _on_points_earned(amount: float) -> void:
	score += amount
	_update_score_label()
	_heart_accumulator += amount
	while _heart_accumulator >= HEART_POINT_THRESHOLD:
		_heart_accumulator -= HEART_POINT_THRESHOLD
		_spawn_heart()


func _spawn_heart() -> void:
	$LikeSoundPlayer.play()
	if get_tree().get_nodes_in_group("heart").size() >= MAX_ACTIVE_HEARTS:
		return
	var heart := HeartScene.instantiate()
	var viewport_size := get_viewport_rect().size
	heart.position = Vector2(
		randf_range(HEART_SIDE_MARGIN, viewport_size.x - HEART_SIDE_MARGIN),
		viewport_size.y - HEART_BOTTOM_MARGIN
	)
	add_child(heart)


func _on_countdown_tick() -> void:
	_time_remaining -= 1
	_update_timer_label()
	if not _finale_active and _time_remaining <= FINALE_TIME_THRESHOLD:
		_activate_finale()
	if _time_remaining <= 0:
		_end_game()


func _activate_finale() -> void:
	_finale_active = true
	$NpcTimer.wait_time = NPC_SPAWN_INTERVAL / FINALE_SPAWN_SPEED_MULTIPLIER
	$ItemTimer.wait_time = SPAWN_INTERVAL / FINALE_ITEM_SPAWN_MULTIPLIER


func _update_score_label() -> void:
	var label := "たかりポイント" if GameState.hidden_mode else "スコア"
	$ScoreLabel.text = "%s: %d" % [label, int(score)]


func _update_timer_label() -> void:
	var minutes := _time_remaining / 60
	var seconds := _time_remaining % 60
	$TimerLabel.text = "残り時間 %d:%02d" % [minutes, seconds]


func _end_game() -> void:
	GameState.last_score = score
	get_tree().change_scene_to_file("res://scenes/Result.tscn")
