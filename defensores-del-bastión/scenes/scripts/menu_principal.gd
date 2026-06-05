extends Control

@onready var label2 = $Label2

func _ready() -> void:
	label2.visible = false

func _process(delta: float) -> void:
	pass

func _on_button_pressed():

	if GameManager.mazo_seleccionado.is_empty():
		label2.visible = true
		return

	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/selector_mazo.tscn")


func _on_button_3_pressed() -> void:
	get_tree().quit()
