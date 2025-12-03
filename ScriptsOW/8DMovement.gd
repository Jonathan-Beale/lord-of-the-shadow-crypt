extends CharacterBody2D

var character_direction: Vector2
@export var speed = 100
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var inv: Inv


var last_direction := "down"
var is_attacking := false

func _ready():
	add_to_group("player")
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func get_input():
	# Using ui_ actions which are built-in to Godot
	character_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = character_direction * speed

func _physics_process(delta: float):
	# If attacking, don't allow movement/animation changes
	if is_attacking:
		move_and_slide()
		return
	
	get_input()
	
	if Input.is_action_just_pressed("attack_1") and not is_attacking:  # Changed from "attack"
		play_attack()
		return
	
	if character_direction.x < 0:
		animated_sprite_2d.animation = "walk_right1"
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play()
		last_direction = "left"
	elif character_direction.x > 0:
		animated_sprite_2d.animation = "walk_right1"
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play()
		last_direction = "right"
	elif character_direction.y < 0:
		animated_sprite_2d.animation = "walk_up1"
		animated_sprite_2d.play()
		last_direction = "up"
	elif character_direction.y > 0:
		animated_sprite_2d.animation = "walk_down1"
		animated_sprite_2d.play()
		last_direction = "down"
	else:
		match last_direction:
			"left":
				animated_sprite_2d.animation = "idle_right1"
				animated_sprite_2d.flip_h = true
			"right":
				animated_sprite_2d.animation = "idle_right1"
				animated_sprite_2d.flip_h = false
			"up":
				animated_sprite_2d.animation = "idle_up1"
			"down":
				animated_sprite_2d.animation = "idle_down1"
		animated_sprite_2d.play()
	
	move_and_slide()

func _on_animation_finished():
	match animated_sprite_2d.animation:
		"attack_right", "attack_up", "attack_down":
			is_attacking = false

func play_attack():
	is_attacking = true
	velocity = Vector2.ZERO
	
	match last_direction:
		"left":
			animated_sprite_2d.animation = "attack_right"
			animated_sprite_2d.flip_h = true
		"right":
			animated_sprite_2d.animation = "attack_right"
			animated_sprite_2d.flip_h = false
		"up":
			animated_sprite_2d.animation = "attack_up"
		"down":
			animated_sprite_2d.animation = "attack_down"
	
	animated_sprite_2d.play()

func collect(item):
	inv.insert(item)
