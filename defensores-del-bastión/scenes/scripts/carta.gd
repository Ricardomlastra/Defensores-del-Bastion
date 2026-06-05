extends TextureRect

@export var escena_tropa: PackedScene

var posicion_original: Vector2
var arrastrando := false
var carta_id = ""
var coste := 0
var preview_tropa = null

func _ready():
	await get_tree().process_frame
	posicion_original = global_position

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		arrastrando = true
		visible = false
		mostrar_preview()

func _process(delta):

	if arrastrando:

		global_position = get_global_mouse_position()

		if preview_tropa:
			preview_tropa.global_position = get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton and not event.pressed and arrastrando:
		arrastrando = false
		intentar_colocar()
		ocultar_preview()

func intentar_colocar():

	var slots = get_tree().get_nodes_in_group("slots")
	var mouse_pos = get_global_mouse_position()

	for slot in slots:

		var distancia = slot.global_position.distance_to(mouse_pos)

		if distancia < 40:
			colocar_tropa(slot)
			return

	volver()

func colocar_tropa(slot):

	var main = get_tree().current_scene
	var tropa = escena_tropa.instantiate()

	var coste_tropa = tropa.coste

	if slot.ocupado:
		print("Slot ocupado")
		volver()
		return

	if main.energia_actual < coste_tropa:
		print("No hay energía suficiente")
		volver()
		return

	main.energia_actual -= coste_tropa
	main.actualizar_ui_energia()

	main.add_child(tropa)

	tropa.global_position = slot.global_position
	tropa.slot_asignado = slot

	slot.ocupado = true

	volver()

func volver():
	global_position = posicion_original

func configurar(id, tropa_scene):

	carta_id = id
	escena_tropa = tropa_scene

	var tropa_temp = escena_tropa.instantiate()

	if "coste" in tropa_temp:
		coste = tropa_temp.coste
	else:
		coste = 0

	tropa_temp.queue_free()

func mostrar_preview():

	var previews = {
		"arquero_hielo": preload("res://previews/preview_arquero_hielo.tscn"),
		"asustadizo": preload("res://previews/preview_asustadizo.tscn"),
		"central": preload("res://previews/preview_central.tscn"),
		"dragon": preload("res://previews/preview_dragon.tscn"),
		"laser": preload("res://previews/preview_laser.tscn"),
		"maestro_de_drones": preload("res://previews/preview_maestro_de_drones.tscn"),
		"mago_electrico": preload("res://previews/preview_mago_electrico.tscn"),
		"monarca_de_las_sombras": preload("res://previews/preview_monarca_de_las_sombras.tscn"),
		"paladin": preload("res://previews/preview_paladin.tscn"),
		"sniper": preload("res://previews/preview_sniper.tscn"),
		"tropa_base": preload("res://previews/preview_tropa_base.tscn")
	}

	if not previews.has(carta_id):
		return

	preview_tropa = previews[carta_id].instantiate()

	get_tree().current_scene.add_child(preview_tropa)

	preview_tropa.global_position = get_global_mouse_position()

	preview_tropa.modulate.a = 0.8

func ocultar_preview():

	visible = true

	if preview_tropa:
		preview_tropa.queue_free()
		preview_tropa = null
