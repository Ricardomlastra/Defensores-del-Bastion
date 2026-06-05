extends CharacterBody2D

@export var dano := 20
@export var tiempo_ataque := 1.0
@export var vida_maxima := 100
@export var coste := 5

@export var escena_sombra : PackedScene

@onready var barra_vida = $BarraVida

var vida_actual := 100
var enemigos_en_rango: Array = []
var atacando := false
var slot_asignado = null

func _ready():
	vida_actual = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	barra_vida.visible = false

func _process(delta):
	z_index = int(global_position.y)

func _on_detector_body_entered(body):
	if body.is_in_group("enemigos"):
		enemigos_en_rango.append(body)
		if not atacando:
			atacar()

func _on_detector_body_exited(body):
	if body in enemigos_en_rango:
		enemigos_en_rango.erase(body)

func atacar():
	if enemigos_en_rango.size() == 0:
		atacando = false
		return
		
	atacando = true
	
	var objetivo = enemigos_en_rango[0]
	
	if is_instance_valid(objetivo):
		var murio = objetivo.recibir_dano(dano)
		if murio:
			invocar_sombra()
	
	await get_tree().create_timer(tiempo_ataque).timeout
	
	atacar()

func recibir_dano(cantidad):
	vida_actual -= cantidad
	
	barra_vida.visible = true
	barra_vida.value = vida_actual
	
	mostrar_barra_temporal()
	
	if vida_actual <= 0:
		if slot_asignado != null:
			slot_asignado.ocupado = false
		morir()
		
func mostrar_barra_temporal():
	await get_tree().create_timer(20.0).timeout
	barra_vida.visible = false

func invocar_sombra():

	if escena_sombra == null:
		return

	var slots = get_tree().get_nodes_in_group("slots")

	var slot_derecha = null

	for slot in slots:

		# Misma fila (ajusta 10 si hace falta)
		if abs(slot.global_position.y - global_position.y) > 10:
			continue

		# Debe estar a la derecha
		if slot.global_position.x <= global_position.x:
			continue

		if slot_derecha == null:
			slot_derecha = slot
		elif slot.global_position.x < slot_derecha.global_position.x:
			slot_derecha = slot

	if slot_derecha == null:
		return

	if slot_derecha.ocupado:
		return

	var sombra = escena_sombra.instantiate()

	get_tree().current_scene.add_child(sombra)

	sombra.global_position = slot_derecha.global_position

	sombra.slot_asignado = slot_derecha

	slot_derecha.ocupado = true


func morir():
	queue_free()
