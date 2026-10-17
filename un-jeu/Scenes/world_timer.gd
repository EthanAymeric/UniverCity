class_name GameTimer
extends Timer

## Signal émis à chaque seconde pour transmettre le texte formaté (MM:SS)
signal second_tick(formatted_time: String)

var game_seconds: int = 0

func _ready() -> void:
	wait_time = 1.0
	autostart = true
	
	if not timeout.is_connected(_on_timeout):
		timeout.connect(_on_timeout)

func _on_timeout() -> void:
	game_seconds += 1
	
	# Calcul du format MM:SS
	var minutes = game_seconds / 60
	var seconds = game_seconds % 60
	var formatted_time = "%02d:%02d" % [minutes, seconds]
	
	# Transmet l'information au GameManager
	emit_signal("second_tick", formatted_time)
