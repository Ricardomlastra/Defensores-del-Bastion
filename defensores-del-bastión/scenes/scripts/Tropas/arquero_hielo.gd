extends CharacterBody2D

@export var dano := 10
@export var tiempo_ataque := 2
@export var vida_maxima := 100
@export var coste := 3

@export var factor_ralentizacion := 0.5
@export var duracion_ralentizacion := 2.0

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

		if objetivo.has_method("aplicar_ralentizacion"):
			objetivo.aplicar_ralentizacion(
				factor_ralentizacion,
				duracion_ralentizacion
			)

	await sprite.animation_finished

	sprite.play("idle")

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

	if is_instance_valid(barra_vida):
		barra_vida.visible = false

func morir():
	queue_free()
