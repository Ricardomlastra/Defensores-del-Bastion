extends Node2D

func _ready():

	var tropa = preload("res://scenes/maestro_drones.tscn").instantiate()

	var shape = tropa.get_node("Detector/CollisionShape2D").shape
	var shape2 = tropa.get_node("Detector/CollisionShape2D2").shape
	var shape3 = tropa.get_node("Detector/CollisionShape2D3").shape

	if shape is RectangleShape2D:
		$Alcance.size = shape.size
		$Alcance2.size = shape2.size
		$Alcance3.size = shape3.size

	tropa.queue_free()
