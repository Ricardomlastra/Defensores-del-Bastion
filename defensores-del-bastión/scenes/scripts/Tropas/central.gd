extends CharacterBody2D

@export var vida_maxima := 120
@export var coste := 3

@export var energia_por_tick := 2
@export var tiempo_generacion := 3.0

@onready var barra_vida = $BarraVida

var vida_actual := 120
var slot_asignado = null
var activo := true

func _ready():
	vida_actual = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	barra_vida.visible = false
	
	generar_energia()

func _process(delta):
	z_index = int(global_position.y)
	
func generar_energia():
	while activo:
		await get_tree().create_timer(tiempo_generacion).timeout
		
		if not activo:
			return
		
		var main = get_tree().get_root().get_node("Main")
		
		if main:
			main.aumentar_energia(energia_por_tick)

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
	await get_tree().create_timer(2.0).timeout
	barra_vida.visible = false

func morir():
	activo = false
	queue_free()
