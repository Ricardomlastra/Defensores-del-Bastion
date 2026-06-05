extends CharacterBody2D

@export var dano := 20
@export var tiempo_ataque := 1.0
@export var vida_maxima := 100
@export var coste := 5

@export var max_saltos := 3
@export var reduccion_por_salto := 0.7
@export var radio_salto := 150.0
@export var tiempo_entre_saltos := 0.15

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
		await hacer_cadena(objetivo)
	
	await get_tree().create_timer(tiempo_ataque).timeout
	
	atacar()

func hacer_cadena(enemigo_inicial):
	var enemigo_actual = enemigo_inicial
	var dano_actual = dano
	var afectados: Array = []
	
	for i in range(max_saltos):
		if enemigo_actual == null:
			break
		
		if not is_instance_valid(enemigo_actual):
			break
		
		enemigo_actual.recibir_dano(dano_actual)
		afectados.append(enemigo_actual)
		
		await get_tree().create_timer(tiempo_entre_saltos).timeout
		
		if not is_instance_valid(enemigo_actual):
			break

		dano_actual *= reduccion_por_salto
		
		enemigo_actual = buscar_siguiente(enemigo_actual, afectados)


func buscar_siguiente(enemigo_base, excluidos):
	if not is_instance_valid(enemigo_base):
		return null
	
	var mas_cercano = null
	var distancia_minima = radio_salto
	
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		
		if not is_instance_valid(enemigo):
			continue
		
		if enemigo in excluidos:
			continue
		
		if not is_instance_valid(enemigo_base):
			continue
		
		var distancia = enemigo.global_position.distance_to(enemigo_base.global_position)
		
		if distancia < distancia_minima:
			distancia_minima = distancia
			mas_cercano = enemigo
	
	return mas_cercano


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

func morir():
	queue_free()
