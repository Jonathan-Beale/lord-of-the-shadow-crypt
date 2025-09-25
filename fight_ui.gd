extends Control

@onready var p1_health_bar: ColorRect = $ColorRect/ColorRect/P1HealthBar
@onready var p2_health_bar: ColorRect = $ColorRect/ColorRect2/P2HealthBar
@onready var p1: Player = $"../Player"
#@onready var p2: Player = $"../Player2"

const HEALTH_BAR_LENGTH = 150

func _ready():
	p1.current_health = p1.START_HEALTH / 2
	#p2.current_health = p2.START_HEALTH / 2

func _process(delta: float) -> void:
	if p1:
		p1_health_bar.size.x = HEALTH_BAR_LENGTH * p1.current_health / p1.max_health
	#if p2:
		#p2_health_bar.size.x = HEALTH_BAR_LENGTH * p2.current_health / p2.max_health
