extends Camera2D

@export var speed: float = 250.0

## Marge sur les bords de l'écran (en pixels)
@export var edge_margin: float = 8.0


@onready var sol: TileMapLayer = $"../Sol"

var min_cam_pos: Vector2 = Vector2.ZERO
var max_cam_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Calcule automatiquement les limites d'après les tuiles réelles du Sol
	if sol and sol.tile_set:
		var rect: Rect2i = sol.get_used_rect()
		var tile_size = sol.tile_set.tile_size
		var map_min = Vector2(rect.position * tile_size)
		var map_max = Vector2(rect.end * tile_size)
		
		# Taille de la demi-vue en coordonnées locales (divisée par le scale x3 du parent)
		var parent_scale = get_parent().scale.x if get_parent() else 1.0
		var vp_half = get_viewport_rect().size / (2.0 * parent_scale)
		
		min_cam_pos = map_min + vp_half
		max_cam_pos = map_max - vp_half
		
		# Sécurité si la carte est plus petite que l'écran
		if min_cam_pos.x > max_cam_pos.x:
			var mid_x = (map_min.x + map_max.x) / 2.0
			min_cam_pos.x = mid_x
			max_cam_pos.x = mid_x
		if min_cam_pos.y > max_cam_pos.y:
			var mid_y = (map_min.y + map_max.y) / 2.0
			min_cam_pos.y = mid_y
			max_cam_pos.y = mid_y
		
		# On place la caméra au centre de la carte au démarrage
		position = (map_min + map_max) / 2.0

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var move_dir := Vector2.ZERO

	if mouse_pos.x >= 0 and mouse_pos.x <= viewport_size.x and mouse_pos.y >= 0 and mouse_pos.y <= viewport_size.y:
		# Gauche / Droite
		if mouse_pos.x <= edge_margin:
			move_dir.x -= 1
		elif mouse_pos.x >= viewport_size.x - edge_margin:
			move_dir.x += 1

		# Haut / Bas
		if mouse_pos.y <= edge_margin:
			move_dir.y -= 1
		elif mouse_pos.y >= viewport_size.y - edge_margin:
			move_dir.y += 1

	if move_dir != Vector2.ZERO:
		position += move_dir.normalized() * speed * delta

		# Bloque la caméra aux limites réelles de la carte
		position.x = clamp(position.x, min_cam_pos.x, max_cam_pos.x)
		position.y = clamp(position.y, min_cam_pos.y, max_cam_pos.y)
