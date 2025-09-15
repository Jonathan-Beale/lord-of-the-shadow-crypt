class_name PlayerState
extends State

@onready var player: Player = get_tree().get_first_node_in_group("Player")

const JUMP_FORCE: float = 400
const AIR_SPEED: float = 20
const MOVE_SPEED: float = 320
const MAX_SPEED: float = 160

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 9.8)

var idle_anim: String = "Idle"
var walk_anim: String = "Walk"
var jump_anim: String = "Jump"
var fall_anim: String = "Fall"

@export_group("States")
@export var idle_state: PlayerState
@export var walk_state: PlayerState
@export var jump_state: PlayerState
@export var fall_state: PlayerState

var sprite_flipped: bool = false

var movement_key: String = "Movement"
var left_key: String = "ui_left"
var right_key: String = "ui_right"
var jump_key: String = "ui_up"

var left_actions: Array = [InputMap.action_get_events(left_key).map(func(action: InputEvent) -> String:
	return action.as_text().get_slice(" (", 0))[-1]]
var right_actions: Array = [InputMap.action_get_events(right_key).map(func(action: InputEvent) -> String:
	return action.as_text().get_slice(" (", 0))[-1]]


func determine_sprite_flipped(event_text: String) -> void:
	if left_actions.find(event_text) != -1: sprite_flipped = true
	if right_actions.find(event_text) != -1: sprite_flipped = false
	player.sprite.flip_h = sprite_flipped
	pass

func process_physics(delta: float) -> State:
	super(delta)
	player.velocity.y += gravity * delta
	do_move(get_move_dir())
	#player.velocity.x = lerp(player.velocity.x, 0.0, friction)
	player.move_and_slide()
	return null

func do_move(move_dir: float) -> void:
	if player.is_on_floor():
		if abs(player.velocity.x) < MAX_SPEED:
			player.velocity.x += move_dir * MOVE_SPEED
	else:
		player.velocity.x += move_dir * AIR_SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(left_key, right_key)
	#print("Direction: ",  dir)
	return dir

func exit(new_state: State = null):
	super()
	if new_state:
		new_state.sprite_flipped = sprite_flipped
