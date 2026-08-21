extends Area2D

signal points_earned(amount: float)

const MIN_LIFETIME := 5.0
const MAX_LIFETIME := 10.0
const POINTS_PER_SECOND := 1.0
const NPC_BONUS_PER_SECOND := 1.0
const ICONS := [
	preload("res://assets/icons/tapioca_milk_tea.svg"),
	preload("res://assets/icons/donut.svg"),
	preload("res://assets/icons/cake.svg"),
	preload("res://assets/icons/ice_cream.svg"),
	preload("res://assets/icons/coffee.svg"),
	preload("res://assets/icons/pancake.svg"),
	preload("res://assets/icons/macaron.svg"),
	preload("res://assets/icons/parfait.svg"),
	preload("res://assets/icons/waffle.svg"),
	preload("res://assets/icons/crepe.svg"),
	preload("res://assets/icons/cupcake.svg"),
	preload("res://assets/icons/shaved_ice.svg"),
	preload("res://assets/icons/smoothie.svg"),
]

var _player_nearby := false
var _qualifying_npcs := {}


func _ready() -> void:
	add_to_group("item")
	$Visual.texture = ICONS.pick_random()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	get_tree().create_timer(randf_range(MIN_LIFETIME, MAX_LIFETIME)).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	if _player_nearby:
		var rate := POINTS_PER_SECOND + NPC_BONUS_PER_SECOND * _qualifying_npcs.size()
		points_earned.emit(rate * delta)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
	elif body.is_in_group("npc"):
		# Only NPCs that arrive after the player is already here count for the bonus.
		if _player_nearby:
			_qualifying_npcs[body] = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		_qualifying_npcs.clear()
	elif body.is_in_group("npc"):
		_qualifying_npcs.erase(body)
