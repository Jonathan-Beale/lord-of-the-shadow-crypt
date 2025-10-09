class_name Camera
extends Camera2D

const INIT_ZOOM: Vector2 = Vector2.ONE *2.9
const INIT_OFFSET: Vector2 = Vector2.ZERO

var cur_zoom: Vector2 = INIT_ZOOM
var cur_offset: Vector2 = INIT_OFFSET

var shake_recov_fac: float = 1
var zoom_recov_fac: float = 1

func _ready():
	zoom = INIT_ZOOM
	offset = INIT_OFFSET

func _process(delta):
	recover_zoom(delta)
	recover_offset_and_shake(delta)

func recover_offset_and_shake(delta: float) -> void:
	cur_offset = lerp(cur_offset, INIT_OFFSET, delta * shake_recov_fac)
	cur_offset.x = randf_range(cur_offset.x * -1, cur_offset.x * 1)
	cur_offset.y = randf_range(cur_offset.y * -1, cur_offset.y * 1)
	offset = cur_offset

func recover_zoom(delta: float) -> void:
	cur_zoom = lerp(cur_zoom, INIT_ZOOM, delta * zoom_recov_fac)
	zoom = cur_zoom

func set_zoom_str(zoom_str: float) -> void:
	cur_zoom *= zoom_str

func set_shake_str(shake_val: Vector2) -> void:
	cur_offset += shake_val
