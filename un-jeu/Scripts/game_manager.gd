extends Node2D

## Références aux nœuds de la scène
@onready var sol: TileMapLayer = $Sol
@onready var decoration: TileMapLayer = $Decoration
@onready var buildings_container: Node2D = $Buildings
@onready var preview_sprite: Sprite2D = $PreviewSprite
@onready var batiment_1_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Batiment1
@onready var delete_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/delete
@onready var farm_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Batiment3

## Scène de bâtiment par défaut
@export var building_scene: PackedScene = preload("res://Scenes/Building.tscn")
@export var farm_scene: PackedScene = preload("res://Scenes/farm.tscn")

## Variables d'état du placement
var is_placing: bool = false
var current_scene_to_place: PackedScene = null
var current_footprint: Vector2i = Vector2i(1, 1)

## Variables d'état de la suppression
var is_deleting: bool = false
var current_hovered_building: Building = null

## Registre des cases occupées : clé = Vector2i, valeur = Building
var occupied_cells: Dictionary = {}

func _ready() -> void:
	# Cache l'aperçu au démarrage
	preview_sprite.visible = false
	preview_sprite.z_index = 10
	
	# Connexion du bouton de bâtiment
	batiment_1_btn.pressed.connect(_on_batiment_1_pressed)
	delete_btn.pressed.connect(_on_delete_pressed)
	farm_btn.pressed.connect(_on_batiment_3_pressed)

func _process(_delta: float) -> void:
	if is_placing:
		_process_placement()
	elif is_deleting:
		_process_deletion()

func _process_placement() -> void:
	# 1. Récupérer la position de la souris sur la grille
	var mouse_pos: Vector2 = sol.get_local_mouse_position()
	var cell: Vector2i = sol.local_to_map(mouse_pos)
	
	# 2. Centrer l'aperçu sur la zone occupée par le bâtiment (footprint)
	var bottom_right_cell = cell + current_footprint - Vector2i(1, 1)
	var center_pos = (sol.map_to_local(cell) + sol.map_to_local(bottom_right_cell)) / 2.0
	preview_sprite.position = center_pos
	
	# 3. Vérifier si l'emplacement est valide pour colorer l'aperçu
	if can_place(cell, current_footprint):
		preview_sprite.modulate = Color(0.3, 1.0, 0.3, 0.7) # Vert : constructible
	else:
		preview_sprite.modulate = Color(1.0, 0.25, 0.25, 0.7) # Rouge : impossible

func _process_deletion() -> void:
	var mouse_pos: Vector2 = sol.get_local_mouse_position()
	var cell: Vector2i = sol.local_to_map(mouse_pos)
	var building: Building = occupied_cells.get(cell, null)
	
	# Met en surbrillance rouge le bâtiment sous le curseur
	if building != current_hovered_building:
		if is_instance_valid(current_hovered_building):
			current_hovered_building.modulate = Color.WHITE
		current_hovered_building = building
		if is_instance_valid(current_hovered_building):
			current_hovered_building.modulate = Color(1.0, 0.35, 0.35, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if is_placing:
		# Clics de souris pour le placement
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos: Vector2 = sol.get_local_mouse_position()
				var cell: Vector2i = sol.local_to_map(mouse_pos)
				if can_place(cell, current_footprint):
					place_building(cell, current_footprint)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_placement()
		
		# Touche Échap pour annuler
		elif event.is_action_pressed("ui_cancel"):
			cancel_placement()
			
	elif is_deleting:
		# Clics de souris pour la suppression
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos: Vector2 = sol.get_local_mouse_position()
				var cell: Vector2i = sol.local_to_map(mouse_pos)
				delete_building_at(cell)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_deletion()
		
		# Touche Échap pour annuler
		elif event.is_action_pressed("ui_cancel"):
			cancel_deletion()

## Vérifie si toutes les cases requises sont sur le sol et non occupées
func can_place(top_left: Vector2i, footprint: Vector2i) -> bool:
	for x in range(footprint.x):
		for y in range(footprint.y):
			var check_cell = top_left + Vector2i(x, y)
			
			# 1. La case doit exister sur le sol (pas dans le vide)
			if sol.get_cell_source_id(check_cell) == -1:
				return false
			
			var tiledata = sol.get_cell_tile_data(check_cell)
			if tiledata == null or tiledata.get_custom_data("interdit"):
				return false
			
			if decoration and decoration.get_cell_source_id(check_cell) != -1:
				var tiledata_route = decoration.get_cell_tile_data(check_cell)
				if tiledata_route and tiledata_route.get_custom_data("interdit"):
					return false
			
			# 2. La case ne doit pas être déjà occupée par un bâtiment
			if occupied_cells.has(check_cell):
				return false
				
	return true

## Démarre le mode placement en copiant automatiquement le visuel et la taille de la scène
func start_placement(scene: PackedScene) -> void:
	cancel_deletion()
	current_scene_to_place = scene
	is_placing = true
	
	# Récupération automatique du sprite et du footprint depuis la scène du bâtiment
	var temp_bld = scene.instantiate() as Building
	if temp_bld:
		current_footprint = temp_bld.footprint
		var bld_sprite = temp_bld.get_node_or_null("Sprite2D")
		if bld_sprite:
			preview_sprite.texture = bld_sprite.texture
			preview_sprite.region_enabled = bld_sprite.region_enabled
			preview_sprite.region_rect = bld_sprite.region_rect
			preview_sprite.scale = bld_sprite.scale
		temp_bld.queue_free()
	
	preview_sprite.visible = true

## Pose définitivement le bâtiment dans le monde
func place_building(top_left: Vector2i, footprint: Vector2i) -> void:
	if not current_scene_to_place:
		return
		
	var building: Building = current_scene_to_place.instantiate() as Building
	buildings_container.add_child(building)
	
	# Positionnement au centre des cases
	var bottom_right_cell = top_left + footprint - Vector2i(1, 1)
	var center_pos = (sol.map_to_local(top_left) + sol.map_to_local(bottom_right_cell)) / 2.0
	building.position = center_pos
	
	# Enregistrement des cases occupées
	var cells: Array[Vector2i] = []
	for x in range(footprint.x):
		for y in range(footprint.y):
			var c = top_left + Vector2i(x, y)
			occupied_cells[c] = building
			cells.append(c)
			
	building.setup(cells)
	
	# Si Shift n'est pas enfoncé, on quitte le mode placement
	if not Input.is_key_pressed(KEY_SHIFT):
		cancel_placement()

## Annule le mode placement
func cancel_placement() -> void:
	is_placing = false
	current_scene_to_place = null
	preview_sprite.visible = false

## Active le mode suppression
func start_deletion() -> void:
	cancel_placement()
	is_deleting = true
	delete_btn.modulate = Color(1.0, 0.4, 0.4) # Indication visuelle que le mode suppression est activé

## Désactive le mode suppression
func cancel_deletion() -> void:
	is_deleting = false
	delete_btn.modulate = Color.WHITE
	if is_instance_valid(current_hovered_building):
		current_hovered_building.modulate = Color.WHITE
	current_hovered_building = null

## Supprime le bâtiment présent à la case donnée
func delete_building_at(cell: Vector2i) -> void:
	if occupied_cells.has(cell):
		delete_building(occupied_cells[cell])

## Supprime un bâtiment du monde et libère ses cases
func delete_building(building: Building) -> void:
	if not is_instance_valid(building):
		return
		
	if current_hovered_building == building:
		current_hovered_building = null
		
	# Libération de toutes les cases occupées par le bâtiment
	for cell in building.occupied_cells:
		occupied_cells.erase(cell)
		
	# Sécurité supplémentaire au cas où des cases feraient encore référence à ce bâtiment
	for cell in occupied_cells.keys():
		if occupied_cells[cell] == building:
			occupied_cells.erase(cell)
			
	building.queue_free()

## Clic sur le bouton de la ferme dans l'interface
func _on_batiment_1_pressed() -> void:
	start_placement(building_scene)
	
func _on_batiment_3_pressed()->void:
	start_placement(farm_scene)
	
func _on_delete_pressed() -> void:
	if is_deleting:
		cancel_deletion()
	else:
		start_deletion()
