extends CharacterBody2D

@export var dano := 10
@export var tiempo_ataque := 1.0
@export var vida_maxima := 100
@export var coste := 4

@onready var barra_vida = $BarraVida
@onready var sprite = $AnimatedSprite2D

var vida_actual := 100
var enemigos_en_rango: Array = []
var atacando := false
var slot_asignado = null

func _ready():
	vida_actual = vida_maxima

	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	barra_vida.visible = false

	sprite.play("idle")

	randomize()

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
		sprite.play("idle")
		return

	atacando = true

	sprite.play("attack")

	var objetivo = enemigos_en_rango[0]

	if is_instance_valid(objetivo):
		objetivo.recibir_dano(dano)

	await sprite.animation_finished

	sprite.play("idle")

	await get_tree().create_timer(tiempo_ataque).timeout

	atacar()

func recibir_dano(cantidad):

	vida_actual -= cantidad

	barra_vida.visible = true
	barra_vida.value = vida_actual

	mostrar_barra_temporal()

	if vida_actual > 0:
		cambiar_a_slot_aleatorio()

	if vida_actual <= 0:

		if slot_asignado != null:
			slot_asignado.ocupado = false

		morir()

func mostrar_barra_temporal():

	await get_tree().create_timer(20.0).timeout

	if is_instance_valid(barra_vida):
		barra_vida.visible = false

func morir():
	queue_free()

func cambiar_a_slot_aleatorio():

	var todos_slots = get_tree().get_nodes_in_group("slots")
	var slots_libres: Array = []

	for slot in todos_slots:
		if not slot.ocupado:
			slots_libres.append(slot)

	if slots_libres.size() == 0:
		return

	var nuevo_slot = slots_libres[randi() % slots_libres.size()]

	if slot_asignado != null:
		slot_asignado.ocupado = false

	global_position = nuevo_slot.global_position

	nuevo_slot.ocupado = true
	slot_asignado = nuevo_slot
