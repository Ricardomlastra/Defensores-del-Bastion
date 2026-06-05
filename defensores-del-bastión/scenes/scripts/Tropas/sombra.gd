extends CharacterBody2D

@export var velocidad := 120.0
@export var dano := 10
@export var tiempo_ataque := 0.8
@export var vida_maxima := 1
var slot_asignado = null
@onready var barra_vida = $BarraVida

var vida_actual := 20
var enemigos_en_rango: Array = []
var atacando := false

func _ready():
	vida_actual = vida_maxima

func _process(delta):
	z_index = int(global_position.y)

func _physics_process(delta):
	if not atacando:
		velocity.x = velocidad
		move_and_slide()

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
	velocity.x = 0
	
	var objetivo = enemigos_en_rango[0]
	
	if is_instance_valid(objetivo):
		objetivo.recibir_dano(dano)
	
	await get_tree().create_timer(tiempo_ataque).timeout
	
	atacar()

func recibir_dano(cantidad):
	vida_actual -= cantidad
	
	barra_vida.visible = true
	barra_vida.value = vida_actual
	
	mostrar_barra_temporal()
	
	if vida_actual <= 0:
		morir()
		
func mostrar_barra_temporal():
	await get_tree().create_timer(20.0).timeout
	barra_vida.visible = false
	
func morir():

	if slot_asignado != null:
		slot_asignado.ocupado = false

	queue_free()
