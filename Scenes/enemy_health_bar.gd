# EnemyHealthBar.gd
class_name EnemyHealthBar
extends Control

@onready var fill: ColorRect = $Fill
@onready var grey: ColorRect = $Grey
@onready var backing: ColorRect = $Backdrop
@onready var shield: ColorRect = $Shield
@onready var overlay: TextureRect = $Overlay

var enemy: Enemy = null  # use your enemy type if available: var enemy: enemy
const BAR_W: float = 140.0
const BAR_H: float = 10.0

func _ready() -> void:
	# Ensure we size ourself, and children use left anchors
	size = Vector2(BAR_W, BAR_H)
	fill.position = Vector2(14,-112)
	grey.position = Vector2(14,-112)
	shield.position = Vector2(14,-112)
	backing.position = Vector2(14,-112)
	fill.size = Vector2(BAR_W, BAR_H)
	backing.size = Vector2(BAR_W, BAR_H)
	grey.size = Vector2(0.0, BAR_H)
	shield.size = Vector2(0.0, BAR_H)
	
	overlay.position = Vector2(-55,-123)
	overlay.size = Vector2(BAR_W, BAR_H)
	overlay.stretch_mode = TextureRect.STRETCH_SCALE
	overlay.z_index = 1
	
	fill.color = Color8(156, 0, 5)    # #9c0005
	grey.color = Color8(89, 89, 89)   # #595959
	shield.color = Color8(189, 189, 300)   # 
	backing.color = Color8(20, 20, 20)
	anchor_left = 0; anchor_top = 0; anchor_right = 0; anchor_bottom = 0

func set_enemy(p: Node) -> void:
	enemy = p
	# Connect once; use deferred to avoid duplicate connections on reload
	print("AHJHJHJHJJJJJJJJJJJJJJ")
	print(enemy.has_signal("damage_taken"))
	if enemy.has_signal("damage_taken"):
		enemy.damage_taken.disconnect(_on_damage) if enemy.is_connected("damage_taken", Callable(self, "_on_damage")) else null
		enemy.damage_taken.connect(_on_damage)
	if enemy.has_signal("healing_done"):
		enemy.healing_done.disconnect(_on_heal) if enemy.is_connected("healing_done", Callable(self, "_on_heal")) else null
		enemy.healing_done.connect(_on_heal)
	if enemy.has_signal("damage_blocked"):
		enemy.damage_blocked.connect(_on_heal)
	call_deferred("_update_visuals")

func _on_damage(_type, _amount, _target, _source) -> void:
	_update_visuals()

func _on_heal(_amount, _source) -> void:
	_update_visuals()

func _update_visuals() -> void:
	if enemy == null: return
	var cur := float(enemy.current_health)
	var maxh: float = max(1.0, float(enemy.max_health.total))
	var grey_pool: float = enemy.grey_health if "grey_health" in enemy else 0.0
	var f_shield: float = 0.0
	if enemy.shields["generic"].size() > 0:
		f_shield = enemy.shields["generic"][0].amount
		#print("displaying shields")

	var fill_w: float = clamp((cur / maxh) * BAR_W, 0.0, BAR_W)
	var shield_w: float = clamp((f_shield / maxh) * BAR_W, 0.0, BAR_W - fill_w)
	var grey_w: float = clamp((grey_pool / maxh) * BAR_W, 0.0, BAR_W - fill_w)

	grey.size.x = grey_w + fill_w + shield_w
	shield.size.x = shield_w + fill_w
	fill.size.x = fill_w
