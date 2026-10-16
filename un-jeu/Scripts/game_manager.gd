extends Node2D

## Références aux nœuds de la scène
@onready var sol: TileMapLayer = $Sol
@onready var buildings_container: Node2D = $Buildings
@onready var preview_sprite: Sprite2D = $PreviewSprite
@onready var batiment_1_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Batiment1

@onready var money: Label = $CanvasLayer/PanneauGauche/VBoxContainer/Ressources/Argent
@onready var science: Label = $CanvasLayer/PanneauGauche/VBoxContainer/Ressources/Science

## Scène de bâtiment par défaut
@export var farm_scene: PackedScene = preload("res://Scenes/Building.tscn")

## Variables d'état du placement
var is_placing: bool = false
var current_scene_to_place: PackedScene = null
var current_footprint: Vector2i = Vector2i(1, 1)

# Variables de score
var score_money = 0
var score_science = 0

## Registre des cases occupées : clé = Vector2i, valeur = Building
var occupied_cells: Dictionary = {}

func _ready() -> void:
	# Cache l'aperçu au démarrage
	preview_sprite.visible = false
	preview_sprite.z_index = 10
	
	# Connexion du bouton de bâtiment
	batiment_1_btn.pressed.connect(_on_batiment_1_pressed)
	
	# Affichage du score d'argent possédé
	# TESTS
	add_money(3)
	show_money()
	
	show_science()
	

func _process(_delta: float) -> void:
	# TESTS
	a_add_money()
	z_lose_money()
	s_add_science()
	d_lose_science()
	
	if not is_placing:
		return
	
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
		
	

func _unhandled_input(event: InputEvent) -> void:
	if not is_placing:
		return
	
	# Clics de souris
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

## Vérifie si toutes les cases requises sont sur le sol et non occupées
func can_place(top_left: Vector2i, footprint: Vector2i) -> bool:
	for x in range(footprint.x):
		for y in range(footprint.y):
			var check_cell = top_left + Vector2i(x, y)
			
			# 1. La case doit exister sur le sol (pas dans le vide)
			if sol.get_cell_source_id(check_cell) == -1:
				return false
			
			# 2. La case ne doit pas être déjà occupée par un bâtiment
			if occupied_cells.has(check_cell):
				return false
				
	return true

## Démarre le mode placement en copiant automatiquement le visuel et la taille de la scène
func start_placement(scene: PackedScene) -> void:
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

## Clic sur le bouton de la ferme dans l'interface
func _on_batiment_1_pressed() -> void:
	start_placement(farm_scene)


### Gestion/Affichage de l'argent gagné

# Affichage du score
func show_money():
	money.text = str(score_money) + " €"
	
# Ajout d'une somme 'score' choisi par le jeu d'argent
func add_money(score):
	score_money += score
	
func lose_money(score):
	# Empêcher d'entrer en dette (pour l'instant)
	if score_money <= 0:
		score_money = 0
	else:
		score_money -= score

### Gestion/Affichage des points de science gagnés
func show_science():
	science.text = str(score_science) + " pts de science"
	
func add_science(score):
	score_science += score

func lose_science(score):
	# Empêcher d'entrer en dette (pour l'instant)
	if score_science <= 0:
		score_science = 0
	else:
		score_science -= score

## DEBUG TOOLS
# Augmente l'argent gagné de 1 en appuyant sur la touche espace et l'affiche
# TESTS
func a_add_money():
	if Input.is_key_pressed(KEY_A):
		add_money(200)
		show_money()
		
func z_lose_money():
	if Input.is_key_pressed(KEY_Z):
		lose_money(200)
		show_money()
		
func s_add_science():
	if Input.is_key_pressed(KEY_S):
		add_science(1)
		show_science()
		
func d_lose_science():
	if Input.is_key_pressed(KEY_D):
		lose_science(1)
		show_science()
