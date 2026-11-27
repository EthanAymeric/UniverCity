extends Node2D

## Références aux nœuds de la scène
@onready var sol: TileMapLayer = $Sol
@onready var decoration: TileMapLayer = $Decoration
@onready var maisons: TileMapLayer = $Maisons
@onready var buildings_container: Node2D = $Buildings
@onready var preview_sprite: Sprite2D = $PreviewSprite

### Bouton de suppression de bâtiments
@onready var delete_btn: TextureButton = $CanvasLayer/BarreDelete/delete
### Bâtiments
@onready var ferme_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Ferme
@onready var usine_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Usine
@onready var gratte_ciel_btn: TextureButton = $"CanvasLayer/BarreBatiment/HBoxContainer/Gratte-ciel"
@onready var tour_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Tour
@onready var fusee_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Fusee
@onready var ecole_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Ecole
@onready var lycee_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Lycee
@onready var universite_btn: TextureButton = $CanvasLayer/BarreBatiment/HBoxContainer/Universite

# Bouton pour afficher la route des innovations
@onready var bouton_innovations: TextureButton = $CanvasLayer/PanneauGauche/VBoxContainer/BoutonInnovations

## Ressources : argent, science et population
@onready var money: Label = $CanvasLayer/PanelArgent/HBoxContainer/BoxArgent/Argent
@onready var progress_bar_science: ProgressBar = $CanvasLayer/PanelScience/ContainerScience/BoxScience/ProgressBarScience
@onready var science: Label = $CanvasLayer/PanelScience/ContainerScience/BoxScience/ProgressBarScience/Science
@onready var population_label: Label = $CanvasLayer/PanelPopulation/HBoxContainer/BoxPopulation/PopulationLabel
@onready var population_manager: PopulationManager = $PopulationManager

## Timer
# Label du timer qui affiche le temps à chaque fois
@onready var timer_live: Label = $CanvasLayer/PanneauTimer/HBoxContainer/BoxTimer/TimerLive
# WorldTimer
@onready var world_timer: GameTimer = $WorldTimer

## Autres
# Route des innovations
@onready var popup = $InnovationsZoom

# Bouton pour afficher les stats supplémentaires
@onready var extra_stats_toggle_btn: TextureButton = $CanvasLayer/ExtraStatsToggle
@onready var panneau_gauche: PanelContainer = $CanvasLayer/PanneauGauche
@onready var panel_argent: PanelContainer = $CanvasLayer/PanelArgent
@onready var panel_science: PanelContainer = $CanvasLayer/PanelScience
@onready var panel_population: PanelContainer = $CanvasLayer/PanelPopulation

# Boutons home et info
@onready var bouton_home : TextureButton = $CanvasLayer/HomeBtn
@onready var bouton_info: TextureButton = $CanvasLayer/InfosBtn

# Boutons pour les paramètres
@onready var slider_musique: HSlider = $FenetreParam/SliderMusique
@onready var slider_sfx: HSlider = $FenetreParam/SliderSFX

@onready var bouton_inno: TextureButton = $CanvasLayer/PanneauGauche/VBoxContainer/BoutonInnovations

# Possitions des éléments du panneau latéral gauche
@onready var position_argent: Vector2 = $CanvasLayer/PanelArgent.position
@onready var position_science: Vector2 = $CanvasLayer/PanelScience.position
@onready var position_population: Vector2 = $CanvasLayer/PanelPopulation.position

## Scène de bâtiment par défaut
@export var building_scene: PackedScene = preload("res://Scenes/Building.tscn")
@export var farm_scene: PackedScene = preload("res://Scenes/farm.tscn")


## Fenêtre Quitter
@onready var fenetre_exit: ConfirmationDialog = $FenetreExit

## Fenêtre Recommencer
@onready var fenetre_restart: ConfirmationDialog = $FenetreRestart

## Home Menu
@onready var fenetre_home: Window = $FenetreHome
@onready var infos_btn: TextureButton = $CanvasLayer/InfosBtn
# Boutons
@onready var quit_btn: TextureButton = $FenetreHome/QuitBtn
@onready var exit_btn: TextureButton = $FenetreHome/ExitBtn
@onready var restart_btn: TextureButton = $FenetreHome/RestartBtn
@onready var credits_btn: TextureButton = $FenetreHome/CreditsBtn
@onready var settings_btn: TextureButton = $FenetreHome/SettingsBtn

#Fenêtre Crédits
@onready var fenetre_credit: Window = $FenetreCredit

#Fenêtre Paramètres
@onready var fenetre_param: Window = $FenetreParam

#Fenêtre Innovation
@onready var fenetre_inno: Window = $InnovationsZoom

# Fenetre Palier et bouton de fermeture
@onready var fenetre_palier_succes: Window = $FenetrePalierSucces
@onready var skip_palier_btn: TextureButton = $FenetrePalierSucces/SkipPalierBtn
@onready var palier_succes: Label = $FenetrePalierSucces/PalierSucces
@onready var palier_debloque: Label = $FenetrePalierSucces/PalierDebloque
@onready var palier_desc: Label = $FenetrePalierSucces/PalierDesc

## Infos sur les bâtiments : ATTENTION A BIEN LES GARDER DANS LE MEME ORDRE 
## ENTRE BUILDING_BUTTONS ET BUILDING_NAMES
# Liste ordonnée de tous les boutons de bâtiments
@onready var building_buttons: Array[TextureButton] = [
	ferme_btn,
	usine_btn,
	gratte_ciel_btn,
	tour_btn,
	fusee_btn,
	ecole_btn,
	lycee_btn,
	universite_btn
]

# Noms affichés correspondant exactement à l'ordre de building_buttons
# DEPEND DE L'INDEX CORRESPONDANT DANS BUILDING_BUTTONS
var building_names: Array[String] = [
	"Ferme",
	"Usine",
	"Gratte-ciel",
	"Tour",
	"Fusée",
	"École",
	"Lycée",
	"Université"
]

### TUTORIEL
@onready var tutoriel_manager: TutorielManager = $TutorielOverlay

# Descriptions affichés correspondant exactement à l'ordre de building_buttons
# DEPEND DE L'INDEX CORRESPONDANT DANS BUILDING_BUTTONS
var building_descriptions: Array[String] = [
	# Description de la ferme
	"Née avec la révolution néolithique il y a plus de 10 000 ans, l'agriculture a permis aux sociétés de se sédentariser et de créer des surplus alimentaires, premier moteur de la croissance économique. En libérant progressivement une partie de la population du travail des champs, elle a rendu possible l'essor des villes et, bien plus tard, la scolarisation d'un plus grand nombre.",
	
	# Description de l'usine
	"Apparue à la fin du XVIIIe siècle avec la révolution industrielle, l'usine a concentré machines, énergie et main-d'œuvre pour produire en masse à moindre coût. Si le travail des enfants y fut longtemps fréquent, la complexité croissante des machines a peu à peu poussé à instruire davantage les travailleurs, alimentant à la fois la productivité et la montée de l'école.",
	
	# Description du gratte-ciel
	"Émergeant à la fin du XIXe siècle grâce à l'acier, au béton et à l'ascenseur, le gratte-ciel a concentré bureaux, banques et services au cœur des métropoles. Il incarne l'économie tertiaire et urbaine, qui exige des employés mieux formés et stimule la diffusion de l'instruction secondaire et supérieure.",
	
	# Description de la tour (data center)
	"Héritière des grandes infrastructures de communication et de calcul de l'ère numérique, le data center regroupe des milliers de serveurs qui stockent et traitent les données mondiales. Il soutient l'économie numérique, l'IA et les services à distance, tout en reposant sur une main-d'œuvre hautement qualifiée issue de la massification des études.",
	
	# Description de la fusée
	"Issue des avancées scientifiques et industrielles du XXe siècle, la fusée a ouvert l'accès à l'orbite et aux satellites. Ces technologies ont transformé l'économie mondiale (télécommunications, météo, GPS, observation) et illustré la valeur stratégique de la recherche et de l'enseignement scientifique de masse.",
	
	# Description de l'école
	"Longtemps réservée à une minorité, l'école s'est massifiée aux XIXe et XXe siècles avec l'instruction obligatoire. En élevant le niveau général de compétences et d'alphabétisation, elle a soutenu l'innovation, la mobilité sociale et la croissance économique de long terme.",
	
	# Description du lycée
	"Héritier des établissements secondaires réformés aux XIXe et XXe siècles, le lycée a accompagné la massification scolaire en formant des cohortes beaucoup plus larges aux savoirs généraux, techniques et scientifiques. Il prépare une main-d'œuvre qualifiée capable de s'adapter aux mutations économiques et industrielles.",
	
	# Description de l'université
	"Née au Moyen Âge puis largement ouverte au grand public au XXe siècle, l'université réunit enseignement supérieur et recherche. Sa massification a élargi l'accès aux métiers qualifiés, accéléré l'innovation technologique et renforcé la compétitivité des économies modernes."
]
### Musique et Bruitages
@onready var musique: AudioStreamPlayer = $Musique
@onready var placement_building: AudioStreamPlayer = $PlacementBuilding
@onready var destruction_building: AudioStreamPlayer = $DestructionBuilding
@onready var selection_objet: AudioStreamPlayer = $SelectionObjet
@onready var ouverture_menu: AudioStreamPlayer = $OuvertureMenu
@onready var menu_slide: AudioStreamPlayer = $MenuSlide

# Nombre de bâtiments actuellement débloqués (1 au début : uniquement la ferme)
var unlocked_building_count: int = 1

## Textures
# Boutons pour les extra stats
var text_plus: Texture2D = preload("res://Assets/Boutons/plus_icon.png")
var text_moins: Texture2D = preload("res://Assets/Boutons/close_icon.png")
var text_innovations: AtlasTexture



## Coût de placement d'un bâtiment
var current_building_cost: int = 100

## Variables d'état du placement
var is_placing: bool = false
var current_scene_to_place: PackedScene = null
var current_footprint: Vector2i = Vector2i(1, 1)

## Variables d'état de la suppression
var is_deleting: bool = false
var current_hovered_building: Building = null

# Variables de score
var score_money: int = 2000
var score_science: int = 0
# Nombre max de points de science pour atteindre la prochaine innovation
var max_science: int = 100;

## Registre des cases occupées : clé = Vector2i, valeur = Building
var occupied_cells: Dictionary = {}

func _ready() -> void:
	# Cache l'aperçu au démarrage
	preview_sprite.visible = false
	preview_sprite.z_index = 1
	
	# Connexion des boutons de bâtiment
	if not ferme_btn.pressed.is_connected(_on_ferme_pressed):
		ferme_btn.pressed.connect(_on_ferme_pressed)

	if not usine_btn.pressed.is_connected(_on_usine_pressed):
		usine_btn.pressed.connect(_on_usine_pressed)

	if not gratte_ciel_btn.pressed.is_connected(_on_gratteciel_pressed):
		gratte_ciel_btn.pressed.connect(_on_gratteciel_pressed)

	if not tour_btn.pressed.is_connected(_on_tour_pressed):
		tour_btn.pressed.connect(_on_tour_pressed)

	if not fusee_btn.pressed.is_connected(_on_fusee_pressed):
		fusee_btn.pressed.connect(_on_fusee_pressed)

	if not ecole_btn.pressed.is_connected(_on_ecole_pressed):
		ecole_btn.pressed.connect(_on_ecole_pressed)

	if not lycee_btn.pressed.is_connected(_on_lycee_pressed):
		lycee_btn.pressed.connect(_on_lycee_pressed)

	if not universite_btn.pressed.is_connected(_on_universite_pressed):
		universite_btn.pressed.connect(_on_universite_pressed)
	
	# Connexion du bouton de suppression des bâtiments
	delete_btn.pressed.connect(_on_delete_pressed)
	
	# Initialiser le verrouillage des bâtiments
	update_building_unlocks()
	

	# Initialiser les liens pour ouvrir/fermer la fenetre
	if fenetre_palier_succes:
		fenetre_palier_succes.hide()
		fenetre_palier_succes.close_requested.connect(_on_fermer_palier)
		
	if skip_palier_btn:
		skip_palier_btn.pressed.connect(_on_fermer_palier)
	
	# Sous-fenêtres de type Window (Paramètres, Crédits)
	if fenetre_param and not fenetre_param.close_requested.is_connected(_on_fenetre_param_close_requested):
		fenetre_param.close_requested.connect(_on_fenetre_param_close_requested)
	if fenetre_credit and not fenetre_credit.close_requested.is_connected(_on_fenetre_credit_close_requested):
		fenetre_credit.close_requested.connect(_on_fenetre_credit_close_requested)

	# Sous-fenêtres de type ConfirmationDialog (Quitter, Recommencer)
	if fenetre_exit and not fenetre_exit.canceled.is_connected(_on_fenetre_exit_canceled):
		fenetre_exit.canceled.connect(_on_fenetre_exit_canceled)
	if fenetre_restart and not fenetre_restart.canceled.is_connected(_on_fenetre_restart_canceled):
		fenetre_restart.canceled.connect(_on_fenetre_restart_canceled)

	# Paramètres
	if slider_musique:
		slider_musique.value = 1.0 # Volume max par défaut
		slider_musique.value_changed.connect(_on_slider_musique_value_changed)
	
	if slider_sfx:
		slider_sfx.value = 1.0
		slider_sfx.value_changed.connect(_on_slider_sfx_value_changed)

	
	# Affichage du score d'argent possédé
	show_money()
	
	show_science()
	
	# Prépare le bouton pour l'affichage de la fenêtre et cache cette dernière comme elle n'est pas encore appelée
	bouton_innovations.pressed.connect(_on_bouton_innovations_pressed)
	popup.hide()
	
	# Gestion de la texture des innovations : initialisation
	text_innovations = AtlasTexture.new()
	text_innovations.atlas = preload("res://Assets/Ressources/spritesheet_innovations.png")
	text_innovations.region = Rect2(0, 0, 300, 300)
	
	# Affichage initial et connexion de la population
	population_manager.population_changed.connect(_on_population_changed)
	show_population()
	
	# Affichage de la date initiale (1900/01/01) et lancement du Timer
	timer_live.text = world_timer.get_formatted_date()
	world_timer.second_tick.connect(_on_timer_tick)
	
	if bouton_info and tutoriel_manager:
		bouton_info.pressed.connect(tutoriel_manager.demarrer_tutoriel)


func _process(_delta: float) -> void:
	if is_placing:
		_process_placement()
	elif is_deleting:
		_process_deletion()
		
	# TESTS
	## DEBUG : Ajouter/Perdre des ressources
	a_add_money()
	z_lose_money()
	s_add_science()
	d_lose_science()

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
	
	## DEBUG : Touche P pour accélérer l'arrivée d'habitants et tester l'urbanisme
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		population_manager.add_citizens(4)

## Vérifie si toutes les cases requises sont sur le sol et non occupées
func can_place(top_left: Vector2i, footprint: Vector2i) -> bool:
	# Vérification de l'argent disponible : on ne peut pas placer le batiment si on n'a pas assez de sous :
	if score_money < current_building_cost:
		return false
	
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
			
			# 2. La case ne doit pas être déjà occupée par un bâtiment ou une habitation
			if occupied_cells.has(check_cell):
				return false
			
			if maisons and maisons.get_cell_source_id(check_cell) != -1:
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
		current_building_cost = temp_bld.building_cost # Récupère le coût depuis le bâtiment
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
		
	# Déduire l'argent et mettre à jour l'affichage
	lose_money(current_building_cost)
	show_money()
		
	var building: Building = current_scene_to_place.instantiate() as Building
	buildings_container.add_child(building)
	
	# Lance le SFX de placement
	if placement_building and placement_building.stream:
		placement_building.play()
	
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
		
	## Gestion du tutoriel
	if tutoriel_manager:
		tutoriel_manager.notifier_batiment_place()

## Annule le mode placement
func cancel_placement() -> void:
	# Eviter l'annulation de placement durant le tuto
	if tutoriel_manager and tutoriel_manager.placement_force_en_cours():
		return
		
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
		
	# Lance le SFX de destruction	
	if destruction_building and destruction_building.stream:
		destruction_building.play()
			
	building.queue_free()


func _on_delete_pressed() -> void:
	if is_deleting:
		cancel_deletion()
	else:
		start_deletion()
		
### Placement des bâtiments
## Par exemple, clic sur le bouton de la ferme dans l'interface
func _on_ferme_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(farm_scene)
	# Gestion du tutoriel : placement obligatoire d'une ferme
	if tutoriel_manager:
		tutoriel_manager.notifier_bouton_batiment_clique(ferme_btn)	
		
func _on_usine_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(building_scene)

func _on_gratteciel_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(building_scene)

func _on_tour_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(building_scene)

func _on_fusee_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(building_scene)

func _on_ecole_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(building_scene)

func _on_lycee_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(building_scene)

func _on_universite_pressed() -> void:
	# Lance le SFX de placement
	if selection_objet and selection_objet.stream:
		selection_objet.play()
	start_placement(building_scene)


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
	progress_bar_science.max_value = max_science
	progress_bar_science.value = score_science
	science.text = "%d / %d" % [score_science, max_science]
	
func add_science(score):
	# met à jour le score avec la valeur rajoutée
	score_science += score
	var palier_atteint: bool = false # pour savoir si on affiche la fenetre ou pas
	var dernier_batiment_debloque: String = "" # pour stocker le nom du dernier bâtiment
	var dernier_index_debloque: int = -1 # pour avoir l'index et récupérer la description correspondante
	
	# Tant qu'on atteint le palier et qu'il reste des bâtiments à débloquer
	while score_science >= max_science and unlocked_building_count < building_buttons.size():
		score_science -= max_science # Réinitialise la jauge tout en reportant le surplus
		
		# L'index du bâtiment qui vient d'être débloqué correspond à l'ancien unlocked_building_count
		var unlocked_index: int = unlocked_building_count
		unlocked_building_count += 1
		update_building_unlocks()
		palier_atteint = true
		dernier_index_debloque = unlocked_index
		
		# Vérification de l'index		
		if unlocked_index < building_names.size():
			dernier_batiment_debloque = building_names[unlocked_index] # Mise à jour de la variable avec le nom du batiment qu'on vient de debloquer
		elif unlocked_index < building_buttons.size() and is_instance_valid(building_buttons[unlocked_index]):
			dernier_batiment_debloque = building_buttons[unlocked_index].name
	
	# Si tous les bâtiments sont débloqués, on bloque la jauge au maximum
	if unlocked_building_count >= building_buttons.size() and score_science > max_science:
		score_science = max_science
	
	# Si le palier est atteint, on affiche la fenetre de succes
	if dernier_batiment_debloque != "" and palier_atteint:
		ouvrir_fenetre_palier(dernier_batiment_debloque, dernier_index_debloque)

func ouvrir_fenetre_palier(nom_batiment: String, index_batiment: int = -1):
	# Annule tout mode placement/suppression en cours avant la pause
	cancel_placement()
	cancel_deletion()
	
	# Mise à jour du texte
	if palier_debloque:
		palier_debloque.text = "Vous avez débloqué :\n %s \n %d / %d" % [nom_batiment, unlocked_building_count, building_buttons.size()]
		palier_desc.text = building_descriptions[index_batiment]
	else:
		palier_debloque.text = ""
		palier_desc.text = ""
	
	# Pause l'arbre : tous ce qui est lié aux noeuds
	get_tree().paused = true
	# Enfin, affiche la fenetre
	if fenetre_palier_succes:
		fenetre_palier_succes.popup_centered()

func _on_fermer_palier():
	if fenetre_palier_succes:
		fenetre_palier_succes.hide()
	get_tree().paused = false

## Active ou désactive l'intéractivité et l'affichage des boutons selon la progression
func update_building_unlocks() -> void:
	for i in range(building_buttons.size()):
		var btn = building_buttons[i]
		if i < unlocked_building_count:
			btn.disabled = false  # Débloqué : cliquable et affichage normal
		else:
			btn.disabled = true   # Verrouillé : bascule automatiquement sur texture_disabled (fermeLock.png)

func lose_science(score):
	# Empêcher d'entrer en dette (pour l'instant)
	if score_science <= 0:
		score_science = 0
	else:
		score_science -= score

### Gestion/Affichage de la population
func _on_population_changed(_total: int) -> void:
	show_population()

func show_population() -> void:
	population_label.text = "%d" % population_manager.get_total_population()

## Gestion du WorldTimer

func _on_timer_tick(formatted_time: String) -> void:
	# 1. Met à jour l'affichage du timer reçu du script séparé
	timer_live.text = formatted_time

	# 2. Calcule la science en interrogeant chaque bâtiment unique
	var unique_buildings = []
	var science_gain = 0
	
	for cell in occupied_cells:
		var bld = occupied_cells[cell]
		if is_instance_valid(bld) and not unique_buildings.has(bld):
			unique_buildings.append(bld)
			science_gain += bld.science_production # Utilise la production propre du bâtiment

	if science_gain > 0:
		add_science(science_gain)
		show_science()


## Boutons d'affichage
# Fermeture de la fenêtre des routes des innovations quand on clique sur la croix
func _on_innovations_zoom_close_requested():
	popup.hide()
	bouton_innovations.texture_normal = text_innovations

# Afficher/Cacher la route des innovations en appuyant sur le bouton	
func _on_bouton_innovations_pressed():
	if popup.visible:
		popup.hide()
		bouton_innovations.texture_normal = text_innovations
	else:
		popup.show()
		bouton_innovations.texture_normal = text_moins
	
	
# à modifier pour mon panneau lateral
func _on_extra_stats_toggle_pressed() -> void:
	if menu_slide and menu_slide.stream:
		menu_slide.play()
	if panneau_gauche.visible:
		panneau_gauche.hide()
		extra_stats_toggle_btn.texture_normal = text_plus
		panel_argent.position = Vector2(300,2); 
		panel_science.position = Vector2(2,2); 
		#panel_population.position = Vector2(600,2);
		bouton_home.visible = false;
		bouton_info.visible = false;
		
	else:
		panneau_gauche.show()
		extra_stats_toggle_btn.texture_normal = text_moins
		panel_argent.position = position_argent; 
		panel_science.position = position_science; 
		#panel_population.position = position_population; 
		bouton_home.visible = true;
		bouton_info.visible = true;
	
## Home Menu
func _on_home_btn_pressed() -> void:
	# Lance le SFX
	if ouverture_menu and ouverture_menu.stream:
		ouverture_menu.play()
	if fenetre_home.visible:
		_fermer_fenetre_home()
	else:
		_ouvrir_fenetre_home()
		
func _on_fenetre_home_close_requested() -> void:
	_fermer_fenetre_home()
	
func _on_fenetre_param_close_requested() -> void:
	fenetre_param.hide()
	_retour_menu_principal(fenetre_param) # réaffiche le menu principal
	
func _on_fenetre_credit_close_requested() -> void:
	fenetre_credit.hide()
	_retour_menu_principal(fenetre_credit) # réaffiche le menu principal

func _on_fenetre_exit_canceled() -> void:
	_retour_menu_principal(fenetre_exit) # réaffiche le menu principal

func _on_fenetre_restart_canceled() -> void:
	_retour_menu_principal(fenetre_restart) # réaffiche le menu principal

# Bouton Exit du Menu
func _on_exit_btn_pressed() -> void:
	# Ouvre la fenêtre de confirmation pour quitter le jeu
	fenetre_home.hide()
	fenetre_exit.popup_centered()
	
# Si on confirme...
func _on_fenetre_exit_confirmed():
	get_tree().quit()
	
# Bouton X du Menu
func _on_quit_btn_pressed() -> void:
	_fermer_fenetre_home()
	
func _on_restart_btn_pressed() -> void:
	fenetre_home.hide()
	fenetre_restart.popup_centered()
	
func _on_settings_btn_pressed() -> void:
	fenetre_home.hide()
	fenetre_param.popup_centered()
	fenetre_param.visible = true
	
func _on_credits_btn_pressed() -> void:
	fenetre_home.hide()
	fenetre_credit.popup_centered()
	fenetre_credit.visible = true


## Ferme une sous-fenêtre du menu et réaffiche le menu principal
func _retour_menu_principal(sous_fenetre: Node = null) -> void:
	# si la sous-fenetre est là, on la ferme
	if sous_fenetre and sous_fenetre.has_method("hide"):
		sous_fenetre.hide()
	# sinon on l'affiche
	_ouvrir_fenetre_home()

## Ouvre le menu principal et met le jeu en pause
func _ouvrir_fenetre_home() -> void:
	cancel_placement()
	cancel_deletion()
	get_tree().paused = true
	if fenetre_home:
		fenetre_home.popup_centered()

## Ferme le menu principal et relance le jeu (sauf si une autre fenêtre de pause est ouverte)
func _fermer_fenetre_home() -> void:
	if fenetre_home:
		fenetre_home.hide()
	# Sécurité : ne relance le jeu que si la fenêtre de palier n'est pas ouverte
	var palier_ouvert: bool = fenetre_palier_succes != null and fenetre_palier_succes.visible
	if not palier_ouvert:
		get_tree().paused = false


	
func _on_btn_inno_pressed() -> void:
	fenetre_inno.visible = true;

func _appliquer_volume_bus(nom_bus: String, value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(nom_bus)
	if bus_idx == -1:
		push_warning("Bus audio introuvable : " + nom_bus)
		return

	if value <= 0.001:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


func _on_slider_musique_value_changed(value: float) -> void:
	_appliquer_volume_bus("Musique", value)


func _on_slider_sfx_value_changed(value: float) -> void:
	for bus_name in ["Regular_SFX", "Loud_SFX"]:
		_appliquer_volume_bus(bus_name, value)
	
	

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
