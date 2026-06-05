extends CharacterBody2D

@export var dano := 10
@export var tiempo_ataque := 1.0
@export var vida_maxima := 100
@export var coste := 4

@export var dano_quemadura := 5
@export var duracion_quemadura := 4.0
@export var intervalo_quemadura := 0.5

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
	
	var objetivo = obtener_enemigo_mas_cercano()
	
	if is_instance_valid(objetivo):
		objetivo.recibir_dano(dano)
		
		if objetivo.has_method("aplicar_quemadura"):
			objetivo.aplicar_quemadura(dano_quemadura, duracion_quemadura, intervalo_quemadura)
	
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

func obtener_enemigo_mas_cercano():
	var mas_cercano = null
	var distancia_minima = INF
	
	for enemigo in enemigos_en_rango:
		if not is_instance_valid(enemigo):
			continue
		
		var distancia = global_position.distance_to(enemigo.global_position)
		
		if distancia < distancia_minima:
			distancia_minima = distancia
			mas_cercano = enemigo
	
	return mas_cercano

func mostrar_barra_temporal():
	await get_tree().create_timer(20.0).timeout
	barra_vida.visible = false
	
func morir():
	queue_free()
