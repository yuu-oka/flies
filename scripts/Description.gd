extends Node2D

const HIDDEN_TEXTS := {
	"Content/Row1/Label": "矢印キーで自分のハエ（あなた＝足元の光る印が目印）を操作しよう",
	"Content/Row2/Label": "画面に現れるゴミに近づくと「たかりポイント」がもらえる（1秒ごとに+1）",
	"Content/Row3/Label": "他のハエ（NPC）もゴミに集まってくる",
	"Content/Row4/Label": "自分が先にいるゴミに、後から集まったハエの数だけボーナス！",
	"Content/Row5": "制限時間1分でどれだけ「たかりポイント」を稼げるか挑戦しよう！",
}

const HIDDEN_ICONS := {
	"Content/Row1/Icon": preload("res://assets/player/fly_player.svg"),
	"Content/Row2/Icon1": preload("res://assets/icons/hidden/trash_bag.svg"),
	"Content/Row2/Icon2": preload("res://assets/icons/hidden/moldy_bread.svg"),
	"Content/Row3/Icon": preload("res://assets/npc/fly_normal.svg"),
	"Content/Row4/Icon": preload("res://assets/npc/fly_normal.svg"),
}

const HIDDEN_TEXT_COLOR_PATHS := [
	"Content/Row1/Label",
	"Content/Row2/Label",
	"Content/Row3/Label",
	"Content/Row4/Label",
	"Content/StartLabel",
]


func _ready() -> void:
	if not GameState.hidden_mode:
		return
	for path in HIDDEN_TEXTS:
		get_node(path).text = HIDDEN_TEXTS[path]
	for path in HIDDEN_ICONS:
		get_node(path).texture = HIDDEN_ICONS[path]
	for path in HIDDEN_TEXT_COLOR_PATHS:
		get_node(path).add_theme_color_override("font_color", Color(0.82, 0.85, 0.55, 1))
	_apply_hidden_background()


func _apply_hidden_background() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0.302, 0.329, 0.106), Color(0.145, 0.114, 0.055)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_to = Vector2(0, 1)
	$Background.texture = texture


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
