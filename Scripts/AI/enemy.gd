class_name Enemy
extends Fighter

@onready var state_machine: StateMachine = $StateMachine
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite

var team = "Enemy"

func _ready():
	self.add_to_group(team)
	state_machine.init()

func _process(delta):
	super(delta)
	state_machine.process_frame(delta)

func _physics_process(delta):
	state_machine.process_physics(delta)
