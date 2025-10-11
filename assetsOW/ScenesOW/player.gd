extends CharacterBody2D

@export var speed: float = 60
@export var chase_speed: float = 100
@export var vision_range: float = 100
@export var player: NodePath

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision_area: Area2D = $VisionArea

var target: CharacterBody2D = null
var state = "patrol"
var patrol_points = []
var current_patrol_index = 0

func _ready():
	if player != null:
		target = get_node(player)
		
	# Connect vision signals
#	vision_area.body_entered.connect(_on_body_entered)
#	vision_area.body_exited.connect(_on_body_exited)
	
	# Optional: create random patrol points nearby
	for i in range(3):
		patrol_points.append(global_position + Vector2(randf_range(-64, 64), randf_range(-64, 64)))


func _physics_process(delta):
	match state:
		"patrol":
			patrol(delta)
		"chase":
			chase(delta)


func patrol(delta):
	if patrol_points.is_empty():
		return
	var target_point = patrol_points[current_patrol_index]
	var dir = (target_point - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	if global_position.distance_to(target_point) < 4:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()


func chase(delta):
	if target == null:
		state = "patrol"
		return
	
	var dir = (target.global_position - global_position).normalized()
	velocity = dir * chase_speed
	move_and_slide()
	
	# If close enough to the player → trigger encounter
	if global_position.distance_to(target.global_position) < 12:
		start_encounter()


func _on_body_entered(body):
	if body.is_in_group("player"):
		target = body
		state = "chase"


func _on_body_exited(body):
	if body == target:
		target = null
		state = "patrol"


func start_encounter():
	# Prevent moving multiple times
	set_physics_process(false)
	velocity = Vector2.ZERO
	print("Encounter triggered!")
	
	# Load your battle scene
	get_tree().change_scene_to_file("res://Scenes/BattleScene.tscn")
