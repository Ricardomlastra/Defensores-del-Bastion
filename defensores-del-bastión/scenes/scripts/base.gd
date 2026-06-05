extends Node2D

@export var vida_maxima := 200

var vida_actual := 0

@onready var barra_vida = $BarraVida

func _ready():

	vida_actual = vida_maxima

	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual

func recibir_dano(cantidad):

	vida_actual -= cantidad

	barra_vida.value = vida_actual

	if vida_actual <= 0:

		var main = get_tree().current_scene

		if main.has_method("game_over"):
			main.game_over()

		queue_free()

func game_over():
	print("GAME OVER")
