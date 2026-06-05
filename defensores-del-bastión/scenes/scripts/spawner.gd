extends Node2D

@export var enemigo_escena: PackedScene
@export var tiempo_spawn := 2.0

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(tiempo_spawn).timeout
		spawn_enemigo()

func spawn_enemigo():
	var enemigo = enemigo_escena.instantiate()
	enemigo.position = Vector2(1344, 448)
	get_parent().add_child(enemigo)
