extends CanvasLayer
class_name TutorielManager

signal tutoriel_termine

## Références à assigner dans l'Inspecteur (ou via start_tutoriel)
@export var game_manager: Node2D
@export var camera: Camera2D

@onready var bloqueur_clics: Control = $BloqueurClics
@onready var personnage_tuto: TextureRect = $PersonnageTuto
@onready var bulle: PanelContainer = $Bulle
@onready var texte_bulle: Label = $Bulle/VBoxContainer/TexteBulle
@onready var bouton_suivant: BaseButton = $Bulle/VBoxContainer/BoutonSuivant
@onready var fleche: TextureRect = $Fleche

## Types d'actions autorisées pour une étape
enum TypeEtape {
	TEXTE_SEUL,        # Le joueur ne peut qu'appuyer sur "Suivant"
	PLACER_BATIMENT    # Le joueur doit sélectionner un bâtiment précis puis le poser sur la carte
}

var _etapes: Array[Dictionary] = []
var _index_courant: int = -1
var _actif: bool = false
var _sous_etape_placement: int = 0 # 0 = doit cliquer sur le bouton du bâtiment, 1 = doit poser sur la carte
var _tween_fleche: Tween

func _ready() -> void:
	layer = 10
	if bouton_suivant and not bouton_suivant.pressed.is_connected(_on_bouton_suivant_pressed):
		bouton_suivant.pressed.connect(_on_bouton_suivant_pressed)
	if fleche:
		fleche.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if personnage_tuto:
		personnage_tuto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arreter_tutoriel()

## Point d'entrée principal pour démarrer le tutoriel
func demarrer_tutoriel() -> void:
	_etapes = _construire_liste_etapes()
	_actif = true
	visible = true
	_index_courant = -1
	_passer_etape_suivante()

## Construit la séquence complète : Début + Étapes intermédiaires + Fin
func _construire_liste_etapes() -> Array[Dictionary]:
	var liste: Array[Dictionary] = []

	# =========================================================================
	# 1. DÉBUT (Obligatoire)
	# =========================================================================
	liste.append({
		"id": "debut_mission",
		"type": TypeEtape.TEXTE_SEUL,
		"texte": "Bienvenue ! Votre mission est de développer votre ville et de faire progresser votre société à travers les grandes innovations.",
		"cam_pos": Vector2(242.33, 149.0),
		"cam_zoom": Vector2(1.0, 1.0)
	})

	# =========================================================================
	# 2. ÉTAPES INTERMÉDIAIRES (Ajoutez, modifiez ou supprimez des blocs ici)
	# =========================================================================
	liste.append({
		"id": "ressources",
		"type": TypeEtape.TEXTE_SEUL,
		"texte": "En haut à gauche se trouvent vos ressources : l'Argent (€) pour construire, et les Points de Science pour débloquer de nouvelles innovations.",
		"cible_ui": game_manager.panel_argent if game_manager else null,
		"cam_pos": Vector2(242.33, 149.0),
		"cam_zoom": Vector2(1.0, 1.0)
	})

	liste.append({
		"id": "placer_ferme",
		"type": TypeEtape.PLACER_BATIMENT,
		"texte": "Commençons par nourrir la population ! Cliquez sur la Ferme en bas, puis placez-la où vous voulez sur la carte.",
		"texte_pose": "Parfait ! Cliquez maintenant sur une case verte de la carte pour construire votre Ferme.",
		"bouton_batiment": game_manager.ferme_btn if game_manager else null,
		"cam_pos": Vector2(242.33, 149.0),
		"cam_zoom": Vector2(1.25, 1.25)
	})

	liste.append({
		"id": "innovations",
		"type": TypeEtape.TEXTE_SEUL,
		"texte": "Vos bâtiments produisent de la science avec le temps. Dès que la jauge est pleine, vous débloquez une nouvelle innovation !",
		"cible_ui": game_manager.bouton_innovations if game_manager else null,
		"cam_pos": Vector2(242.33, 149.0),
		"cam_zoom": Vector2(1.0, 1.0)
	})

	# =========================================================================
	# 3. FIN (Obligatoire)
	# =========================================================================
	liste.append({
		"id": "fin_tuto",
		"type": TypeEtape.TEXTE_SEUL,
		"texte": "Vous savez maintenant tout ce qu'il faut pour bâtir une civilisation prospère. Bon courage !",
		"texte_bouton": "Terminer",
		"cam_pos": Vector2(242.33, 149.0),
		"cam_zoom": Vector2(1.0, 1.0)
	})

	return liste

func _passer_etape_suivante() -> void:
	_index_courant += 1
	if _index_courant >= _etapes.size():
		arreter_tutoriel()
		return

	var etape: Dictionary = _etapes[_index_courant]
	var type_etape: int = etape.get("type", TypeEtape.TEXTE_SEUL)
	_sous_etape_placement = 0

	# Texte de la bulle
	texte_bulle.text = etape.get("texte", "")

	# Caméra (zoom et recentrage)
	if camera and camera.has_method("focus_on") and etape.has("cam_pos"):
		camera.focus_on(etape["cam_pos"], etape.get("cam_zoom", Vector2.ONE))

	# Verrouillage strict selon le type d'étape
	_appliquer_restrictions_etape(etape, type_etape)

func _appliquer_restrictions_etape(etape: Dictionary, type_etape: int) -> void:
	# Par défaut, on verrouille toute l'UI du jeu
	_definir_ui_jeu_active(false)

	match type_etape:
		TypeEtape.TEXTE_SEUL:
			# Le joueur ne peut RIEN faire d'autre que cliquer sur "Suivant"
			bloqueur_clics.visible = true
			bouton_suivant.visible = true
			bouton_suivant.disabled = false
			bouton_suivant.text = etape.get("texte_bouton", "Suivant")
			_pointer_fleche_sur(etape.get("cible_ui", null))

		TypeEtape.PLACER_BATIMENT:
			# Le joueur peut uniquement cliquer sur le bâtiment demandé, puis le poser
			bloqueur_clics.visible = false
			bouton_suivant.visible = false
			var btn_cible: TextureButton = etape.get("bouton_batiment", null)
			if is_instance_valid(btn_cible):
				btn_cible.disabled = false
				_pointer_fleche_sur(btn_cible)

## Active ou désactive tous les boutons interactifs du jeu principal
func _definir_ui_jeu_active(actif: bool) -> void:
	if not game_manager:
		return

	for btn in game_manager.building_buttons:
		if is_instance_valid(btn):
			btn.disabled = not actif

	var autres_boutons: Array = [
		game_manager.delete_btn,
		game_manager.bouton_innovations,
		game_manager.bouton_home,
		game_manager.bouton_info,
		game_manager.extra_stats_toggle_btn
	]
	for btn in autres_boutons:
		if is_instance_valid(btn):
			btn.disabled = not actif

	# À la réactivation normale du jeu, on rétablit le verrouillage réel des bâtiments débloqués
	if actif and game_manager.has_method("update_building_unlocks"):
		game_manager.update_building_unlocks()

func _pointer_fleche_sur(cible: Control) -> void:
	if not fleche:
		return
	if _tween_fleche and _tween_fleche.is_valid():
		_tween_fleche.kill()

	if not is_instance_valid(cible) or not cible.is_visible_in_tree():
		fleche.visible = false
		return

	fleche.visible = true
	var pos_base := cible.global_position + Vector2(cible.size.x * 0.5 - fleche.size.x * 0.5, -fleche.size.y - 8.0)
	fleche.position = pos_base

	_tween_fleche = create_tween().set_loops()
	_tween_fleche.tween_property(fleche, "position:y", pos_base.y - 10.0, 0.45).set_trans(Tween.TRANS_SINE)
	_tween_fleche.tween_property(fleche, "position:y", pos_base.y, 0.45).set_trans(Tween.TRANS_SINE)

func _on_bouton_suivant_pressed() -> void:
	if not _actif:
		return
	var etape: Dictionary = _etapes[_index_courant]
	if etape.get("type") == TypeEtape.TEXTE_SEUL:
		_passer_etape_suivante()

## Appelé par game_manager.gd quand le joueur clique sur un bouton de bâtiment
func notifier_bouton_batiment_clique(bouton: TextureButton) -> void:
	if not _actif or _index_courant < 0 or _index_courant >= _etapes.size():
		return

	var etape: Dictionary = _etapes[_index_courant]
	if etape.get("type") == TypeEtape.PLACER_BATIMENT and _sous_etape_placement == 0:
		if etape.get("bouton_batiment") == bouton:
			_sous_etape_placement = 1
			# On re-verrouille le bouton pour empêcher de recliquer ailleurs et on cache la flèche UI
			bouton.disabled = true
			if fleche:
				fleche.visible = false
			if etape.has("texte_pose"):
				texte_bulle.text = etape["texte_pose"]

## Appelé par game_manager.gd quand un bâtiment est effectivement posé sur la grille
func notifier_batiment_place() -> void:
	if not _actif or _index_courant < 0 or _index_courant >= _etapes.size():
		return

	var etape: Dictionary = _etapes[_index_courant]
	if etape.get("type") == TypeEtape.PLACER_BATIMENT and _sous_etape_placement == 1:
		_passer_etape_suivante()

## Indique au game_manager s'il doit bloquer l'annulation du placement (clic droit / Échap)
func placement_force_en_cours() -> bool:
	if not _actif or _index_courant < 0 or _index_courant >= _etapes.size():
		return false
	var etape: Dictionary = _etapes[_index_courant]
	return etape.get("type") == TypeEtape.PLACER_BATIMENT and _sous_etape_placement == 1

func arreter_tutoriel() -> void:
	_actif = false
	visible = false
	if bloqueur_clics:
		bloqueur_clics.visible = false
	if fleche:
		fleche.visible = false
	if _tween_fleche and _tween_fleche.is_valid():
		_tween_fleche.kill()
	_definir_ui_jeu_active(true)
	if camera and camera.has_method("release_tutorial_focus"):
		camera.release_tutorial_focus()
	tutoriel_termine.emit()
