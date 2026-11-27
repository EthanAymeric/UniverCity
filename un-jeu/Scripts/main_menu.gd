extends Control

## Scène principale du jeu lancée par le bouton "Jouer"
@export_file("*.tscn") var game_scene_path: String = "res://Scenes/scene1.tscn"

@onready var menu_panel: PanelContainer = $MenuPanel
@onready var jouer_button: Button = $MenuPanel/ContentMargin/VBox/ButtonsBox/JouerButton
@onready var parametres_button: Button = $MenuPanel/ContentMargin/VBox/ButtonsBox/ParametresButton
@onready var credits_button: Button = $MenuPanel/ContentMargin/VBox/ButtonsBox/CreditsButton
@onready var quitter_button: Button = $MenuPanel/ContentMargin/VBox/ButtonsBox/QuitterButton
@onready var fade_overlay: ColorRect = $FadeOverlay

var _is_transitioning: bool = false


func _ready() -> void:
	jouer_button.pressed.connect(_on_jouer_pressed)
	parametres_button.pressed.connect(_on_parametres_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quitter_button.pressed.connect(_on_quitter_pressed)

	_play_intro_animation()


func _play_intro_animation() -> void:
	menu_panel.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu_panel, "modulate:a", 1.0, 0.45)


func _on_jouer_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.28)
	tween.tween_callback(_load_game_scene)


func _load_game_scene() -> void:
	var err: Error = get_tree().change_scene_to_file(game_scene_path)
	if err != OK:
		push_error("Impossible de charger la scène du jeu : %s (erreur %d)" % [game_scene_path, err])
		_is_transitioning = false
		fade_overlay.color.a = 0.0


func _on_parametres_pressed() -> void:
	# TODO: Ouvrir la scène des paramètres lorsqu'elle sera développée.
	pass


func _on_credits_pressed() -> void:
	# TODO: Ouvrir la scène des crédits lorsqu'elle sera développée.
	pass


func _on_quitter_pressed() -> void:
	if _is_transitioning:
		return
	get_tree().quit()
