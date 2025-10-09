extends ColorRect

@onready var versus_btn = $Versus
var background_color: Color = Color("#2c2c64")

signal versus_match(players: int)
signal dungeon(players: int)

func _ready():
	# Match viewport size
	size = get_viewport().get_visible_rect().size
	
	# Ensure it stays updated if the window is resized
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Set background color
	color = background_color
	
	# Connect button
	versus_btn.pressed.connect(_versus)

func _on_viewport_resized():
	size = get_viewport().get_visible_rect().size

func _versus():
	emit_signal("versus_match", 2)
	print("Versus button pressed")

func _dungeon():
	emit_signal("dungeon", 1)
	print("Entering the dungeon")
