extends CharacterBody2D

@export var dano := 30
@export var tiempo_ataque := 3
@export var vida_maxima := 100
@export var coste := 4

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
	
	var copia_enemigos = enemigos_en_rango.duplicate()
	
	for enemigo in copia_enemigos:
		if is_instance_valid(enemigo):
			enemigo.recibir_dano(dano)
	
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
	
func morir():
	queue_free()
