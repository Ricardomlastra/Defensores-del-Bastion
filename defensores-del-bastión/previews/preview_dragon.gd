extends Node2D

func _ready():

	var tropa = preload("res://scenes/dragon.tscn").instantiate()

	var shape = tropa.get_node("Detector/CollisionShape2D").shape

	if shape is RectangleShape2D:
		$Alcance.size = shape.size

	tropa.queue_free()
