extends CharacterBody2D

@export var velocidad := 100.0
@export var dano := 10
@export var tiempo_ataque := 1.0
@export var vida_maxima := 100
@onready var barra_vida = $BarraVida
var vida_actual := 100
var tiempo_ataque_actual := 1.0
var enemigos_en_rango: Array = []
var atacando := false
var velocidad_actual := 100.0
var ralentizado := false
var quemado := false

func _ready():
	vida_actual = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	velocidad_actual = velocidad
	tiempo_ataque_actual = tiempo_ataque
	barra_vida.visible = false


func _physics_process(delta):
	velocity.x = -velocidad_actual
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Base":
			collision.get_collider().recibir_dano(10)
			queue_free()

func _on_detector_body_entered(body):
	if body.is_in_group("tropas"):
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
		objetivo.recibir_dano(dano)
	
	await get_tree().create_timer(tiempo_ataque_actual).timeout
	
	atacar()

func recibir_dano(cantidad):
	vida_actual -= cantidad
	
	barra_vida.visible = true
	barra_vida.value = vida_actual
	
	mostrar_barra_temporal()
	
	if vida_actual <= 0:
		morir()
		return true
	
	return false


func mostrar_barra_temporal():
	await get_tree().create_timer(200.0).timeout
	barra_vida.visible = false

func aplicar_ralentizacion(factor, duracion):
	if ralentizado:
		return
	
	ralentizado = true
	
	velocidad_actual = velocidad * factor
	
	tiempo_ataque_actual = tiempo_ataque / factor
	
	modulate = Color(0.6, 0.8, 1)
	
	await get_tree().create_timer(duracion).timeout
	
	velocidad_actual = velocidad
	tiempo_ataque_actual = tiempo_ataque
	modulate = Color(1, 1, 1)
	
	ralentizado = false

func aplicar_quemadura(dano_por_tick, duracion, intervalo):
	if quemado:
		return
	
	quemado = true
	modulate = Color(1, 0.4, 0.4)
	
	var tiempo_total := 0.0
	
	while tiempo_total < duracion:
		if not is_instance_valid(self):
			return
		
		recibir_dano(dano_por_tick)
		
		await get_tree().create_timer(intervalo).timeout
		tiempo_total += intervalo
	
	modulate = Color(1, 1, 1)
	quemado = false

func morir():
	queue_free()
