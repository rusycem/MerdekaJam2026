extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void :
	var camera = get_viewport().get_camera_2d()
	if (camera):
		var rect = get_used_rect()
		var block_size = tile_set.tile_size
		
		camera.limit_left = rect.position.x * block_size.x
		camera.limit_top  = rect.position.y * block_size.y
		
		camera.limit_right  = rect.end.x * block_size.x
		camera.limit_bottom = rect.end.y * block_size.y
