class_name Building
extends Node2D

## Taille en cases de grille (1x1 pour une tuile 16x16, 2x2 pour 32x32, etc.)
@export var footprint: Vector2i = Vector2i(1, 1)

## Attributs propres au bâtiment
@export var building_cost: int = 100
@export var science_production: int = 10

@onready var sprite: Sprite2D = $Sprite2D

## Coordonnées des cases de grille occupées par ce bâtiment
var occupied_cells: Array[Vector2i] = []

func setup(cells: Array[Vector2i]) -> void:
	occupied_cells = cells
