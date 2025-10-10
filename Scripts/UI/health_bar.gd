# HealthBar.gd
class_name HealthBar
extends Control

@onready var fill: ColorRect = $Fill
@onready var grey: ColorRect = $Grey
@onready var backing: ColorRect = $Backdrop
@onready var shield: ColorRect = $Shield
@onready var overlay: TextureRect = $Overlay

var player: Player = null  # use your Player type if available: var player: Player
const BAR_W: float = 140.0
const BAR_H: float = 10.0

func _ready() -> void:
	# Ensure we size ourself, and children use left anchors
	size = Vector2(BAR_W, BAR_H)
	fill.position = Vector2(25,0)
	grey.position = Vector2(25,0)
	shield.position = Vector2(25,0)
	backing.position = Vector2(25,0)
	fill.size = Vector2(BAR_W, BAR_H)
	backing.size = Vector2(BAR_W, BAR_H)
	grey.size = Vector2(0.0, BAR_H)
	shield.size = Vector2(0.0, BAR_H)
	
	overlay.position = Vector2(-14,-10)
	overlay.size = Vector2(BAR_W, BAR_H)
	overlay.stretch_mode = TextureRect.STRETCH_SCALE
	overlay.z_index = 1
	
	fill.color = Color8(156, 0, 5)    # #9c0005
	grey.color = Color8(89, 89, 89)   # #595959
	shield.color = Color8(189, 189, 300)   # 
	backing.color = Color8(20, 20, 20)
	anchor_left = 0; anchor_top = 0; anchor_right = 0; anchor_bottom = 0

func set_player(p: Node) -> void:
	player = p
	# Connect once; use deferred to avoid duplicate connections on reload
	if player.has_signal("damage_taken"):
		print("DAMAAAAGEE")
		player.damage_taken.disconnect(_on_damage) if player.is_connected("damage_taken", Callable(self, "_on_damage")) else null
		player.damage_taken.connect(_on_damage)
	if player.has_signal("healing_done"):
		player.healing_done.disconnect(_on_heal) if player.is_connected("healing_done", Callable(self, "_on_heal")) else null
		player.healing_done.connect(_on_heal)
	if player.has_signal("damage_blocked"):
		player.damage_blocked.connect(_on_heal)
	_update_visuals()

func _on_damage(_type, _amount, _target, _source) -> void:
	_update_visuals()

func _on_heal(_amount, _source) -> void:
	_update_visuals()

func _update_visuals() -> void:
	if player == null: return
	var cur := float(player.current_health)
	var maxh: float = max(1.0, float(player.max_health.total))
	var grey_pool: float = player.grey_health if "grey_health" in player else 0.0
	var f_shield: float = 0.0
	if player.shields["generic"].size() > 0:
		f_shield = player.shields["generic"][0].amount
		#print("displaying shields")

	var fill_w: float = clamp((cur / maxh) * BAR_W, 0.0, BAR_W)
	var shield_w: float = clamp((f_shield / maxh) * BAR_W, 0.0, BAR_W - fill_w)
	var grey_w: float = clamp((grey_pool / maxh) * BAR_W, 0.0, BAR_W - fill_w)

	grey.size.x = grey_w + fill_w + shield_w
	shield.size.x = shield_w + fill_w
	fill.size.x = fill_w
