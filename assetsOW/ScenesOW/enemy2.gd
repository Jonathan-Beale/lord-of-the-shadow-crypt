extends CharacterBody2D
# === Exported variables ===
@export var enemy_id: int = 1                # Unique ID per enemy
@export var walk_speed: float = 60
@export var chase_speed: float = 100
@export var wander_change_time: Vector2 = Vector2(1.5, 3.0)
@export var idle_time: Vector2 = Vector2(1.0, 2.0)
@export var player: NodePath                    # Reference to player
@export var enemy_manager_path: NodePath       # Reference to EnemyManager node
# === Node references ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision_area: Area2D = $VisionArea
# === Internal state ===
var enemy_manager: Node = null
var target: CharacterBody2D = null
var state: String = "wander"
var walk_timer: float = 0.0
var idle_timer: float = 0.0
var move_direction: Vector2 = Vector2.ZERO
var last_direction: String = "down"
var catch_cooldown: float = 0.0
# === Initialization ===
func _ready():
	randomize()
	# Get EnemyManager
	if enemy_manager_path != null:
		enemy_manager = get_node(enemy_manager_path)
	# Remove already defeated enemies immediately
	if enemy_manager != null and enemy_id in enemy_manager.defeated_enemies:
		queue_free()
		return
	# Get player node
	if player != null:
		target = get_node(player)
	# Connect vision signals
	if vision_area:
		vision_area.body_entered.connect(_on_body_entered)
		vision_area.body_exited.connect(_on_body_exited)
	_pick_new_direction()
# === Main physics loop ===
func _physics_process(delta):
	if catch_cooldown > 0:
		catch_cooldown -= delta
		return
	match state:
		"wander":
			_wander(delta)
		"idle":
			_idle(delta)
		"chase":
			_chase(delta)
	
	# THIS IS THE FIX - Call update_animation every frame
	update_animation()

# === Wandering logic ===
func _wander(delta):
	velocity = move_direction * walk_speed
	move_and_slide()
	walk_timer -= delta
	if walk_timer <= 0:
		velocity = Vector2.ZERO
		state = "idle"
		idle_timer = randf_range(idle_time.x, idle_time.y)
func _idle(delta):
	idle_timer -= delta
	if idle_timer <= 0:
		_pick_new_direction()
		state = "wander"
func _pick_new_direction():
	var dirs = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN,
		Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	]
	move_direction = dirs[randi() % dirs.size()]
	walk_timer = randf_range(wander_change_time.x, wander_change_time.y)
# === Chase logic ===
func _chase(delta):
	if target == null:
		state = "wander"
		return
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * chase_speed
	move_and_slide()
	if global_position.distance_to(target.global_position) < 12:
		_on_player_caught()
# === Vision signals ===
func _on_body_entered(body):
	if body.is_in_group("player"):
		target = body
		state = "chase"
func _on_body_exited(body):
	if body == target:
		target = null
		state = "wander"
# === Player caught logic ===
func _on_player_caught():
	print("Enemy caught: ", enemy_id)
	if enemy_manager != null:
		enemy_manager.defeat_enemy(enemy_id)
	queue_free()
# === Animation updates ===
func update_animation():
	if velocity.length() > 0.01:
		var dir = velocity.normalized()
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				animated_sprite.animation = "walk_right"
				animated_sprite.flip_h = false
				last_direction = "right"
			else:
				animated_sprite.animation = "walk_right"
				animated_sprite.flip_h = true
				last_direction = "left"
		else:
			if dir.y > 0:
				animated_sprite.animation = "walk_down"
				last_direction = "down"
			else:
				animated_sprite.animation = "walk_up"
				last_direction = "up"
		animated_sprite.play()
	else:
		match last_direction:
			"left":
				animated_sprite.animation = "idle_right"
				animated_sprite.flip_h = true
			"right":
				animated_sprite.animation = "idle_right"
				animated_sprite.flip_h = false
			"up":
				animated_sprite.animation = "idle_up"
			"down":
				animated_sprite.animation = "idle_down"
		animated_sprite.play()
