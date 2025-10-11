extends CharacterBody2D

@export var enemy_id: int = 0           
@export var walk_speed: float = 60
@export var chase_speed: float = 100
@export var wander_change_time: Vector2 = Vector2(1.5, 3.0)
@export var idle_time: Vector2 = Vector2(1.0, 2.0)

@export var player: NodePath                
@export var enemy_manager_path: NodePath 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision_area: Area2D = $VisionArea

var enemy_manager: Node = null
var target: CharacterBody2D = null
var state: String = "wander"
var walk_timer: float = 0.0
var idle_timer: float = 0.0
var move_direction: Vector2 = Vector2.ZERO
var last_direction: String = "down"
var catch_cooldown: float = 0.0


func _ready():
	randomize()
	if not enemy_manager_path.is_empty():
		enemy_manager = get_node(enemy_manager_path)
	else:
		enemy_manager = get_tree().root.find_child("EnemyManager", true, false)
	
	if enemy_manager != null and enemy_id in enemy_manager.defeated_enemies:
		queue_free()
		return
	
	if not player.is_empty():
		target = get_node(player)
	else:
		var player_node = get_tree().get_first_node_in_group("player")
		if player_node:
			target = player_node
	
	if vision_area:
		vision_area.body_entered.connect(_on_body_entered)
		vision_area.body_exited.connect(_on_body_exited)
	
	_pick_new_direction()

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
	
	update_animation()


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

func _chase(delta):
	if target == null:
		state = "wander"
		return
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * chase_speed
	move_and_slide()
	if global_position.distance_to(target.global_position) < 12:
		_on_player_caught()

func _on_body_entered(body):
	if body.is_in_group("player"):
		target = body
		state = "chase"

func _on_body_exited(body):
	if body == target:
		target = null
		state = "wander"

func _on_player_caught():
	if enemy_manager != null:
		var player_node = target if target else get_tree().get_first_node_in_group("player")
		if player_node:
			enemy_manager.start_battle(enemy_id, player_node.global_position)


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
