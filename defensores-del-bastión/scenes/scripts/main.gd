extends 	Node2D

@export var enemigos_por_oleada := 5
@export var escena_enemigo: PackedScene
@export var energia_maxima := 30
@export var energia_regeneracion := 1

var oleada_actual := 1
var enemigos_restantes := 0

var spawners: Array
@onready var oleada_label = $UI/OleadaLabel
var energia_actual := 15
@onready var energia_label = $UI/EnergiaLabel
@onready var cartas_ui = $UI/CartasUI
@onready var menu_pausa = $UI/MenuPausa
var juego_pausado := false
var saliendo := false
var reiniciando := false
var velocidad_juego := 1

@onready var menu_game_over = $UI/MenuGameOver
@onready var boton_velocidad = $UI/BotonVelocidad

func _ready() -> void:
	Engine.time_scale = 1.0
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	spawners = get_tree().get_nodes_in_group("spawners")
	generar_cartas_mazo()
	iniciar_oleada()
	actualizar_ui_energia()
	regenerar_energia()
	
	pass 

func _process(delta: float) -> void:
	pass

func iniciar_oleada():
	print("Oleada iniciada")
	actualizar_ui_oleada()
	
	enemigos_restantes = enemigos_por_oleada + (oleada_actual - 1) * 2
	
	spawnear_enemigos_progresivo()

func actualizar_ui_oleada():
	oleada_label.text = "Oleada: " + str(oleada_actual)


func spawnear_enemigo():
	var enemigo = escena_enemigo.instantiate()
	
	enemigo.vida_maxima += oleada_actual * 10
	enemigo.velocidad += oleada_actual * 5
	enemigo.dano += oleada_actual * 1.5
	
	enemigo.connect("tree_exited", Callable(self, "_on_enemigo_muerto"))
	
	add_child(enemigo)
	var spawner_aleatorio = spawners.pick_random()
	enemigo.global_position = spawner_aleatorio.global_position

func spawnear_enemigos_progresivo():

	for i in range(enemigos_restantes):

		if saliendo:
			return

		while juego_pausado:

			if saliendo or reiniciando:
				return

			if get_tree() == null:
				return

			await get_tree().process_frame

		spawnear_enemigo()

		await get_tree().create_timer(1.0).timeout


func _on_enemigo_muerto():
	enemigos_restantes -= 1
	if enemigos_restantes <= 0:
		print("Oleada completada")
		oleada_actual += 1
		esperar(5)
		iniciar_oleada()

func actualizar_ui_energia():
	energia_label.text = "Energía: " + str(energia_actual) + " / " + str(energia_maxima)

func regenerar_energia():

	while true:

		if saliendo:
			return

		while juego_pausado:

			if saliendo or reiniciando:
				return

			if get_tree() == null:
				return
				
			await get_tree().process_frame

		await get_tree().create_timer(1.0).timeout

		if energia_actual < energia_maxima:
			energia_actual += energia_regeneracion
			actualizar_ui_energia()

func generar_cartas_mazo():

	var escenas = {
		"arquero_hielo": preload("res://scenes/arquero_hielo.tscn"),
		"asustadizo": preload("res://scenes/asustadizo.tscn"),
		"central": preload("res://scenes/central.tscn"),
		"dragon": preload("res://scenes/dragon.tscn"),
		"laser": preload("res://scenes/laser.tscn"),
		"maestro_de_drones": preload("res://scenes/maestro_drones.tscn"),
		"mago_electrico": preload("res://scenes/mago_electrico.tscn"),
		"monarca_de_las_sombras": preload("res://scenes/monarca_de_las_sombras.tscn"),
		"paladin": preload("res://scenes/paladin.tscn"),
		"sniper": preload("res://scenes/sniper.tscn"),
		"tropa_base": preload("res://scenes/tropa_base.tscn")
	}

	for carta_id in GameManager.mazo_seleccionado:

		if not escenas.has(carta_id):
			print("No existe la carta:", carta_id)
			continue

		var nueva_carta = preload("res://scenes/carta.tscn").instantiate()

		nueva_carta.texture = load(
			"res://cartas/" + carta_id + ".png"
		)

		nueva_carta.custom_minimum_size = Vector2(100, 140)

		nueva_carta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		nueva_carta.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		nueva_carta.configurar(
			carta_id,
			escenas[carta_id]
		)

		cartas_ui.add_child(nueva_carta)

func aumentar_energia(cantidad):
	energia_actual = clamp(energia_actual + cantidad, 0, energia_maxima)
	actualizar_ui_energia()

func esperar(tiempo):
	if get_tree() == null:
		return
	await get_tree().create_timer(tiempo).timeout


func _on_boton_pausa_pressed():
	juego_pausado = true
	get_tree().paused = true
	menu_pausa.visible = true

func _on_continuar_pressed():
	juego_pausado = false
	get_tree().paused = false
	menu_pausa.visible = false

func _on_salir_pressed() -> void:

	saliendo = true

	get_tree().paused = false
	menu_pausa.visible = false
	menu_game_over.visible = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(
		"res://scenes/menu_principal.tscn"
	)
	
func game_over():

	juego_pausado = true

	get_tree().paused = true

	menu_game_over.visible = true


func _on_reintentar_pressed():

	reiniciando = true

	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _on_boton_velocidad_pressed():

	if velocidad_juego == 1:

		velocidad_juego = 2
		Engine.time_scale = 2.0

		boton_velocidad.text = "x2"
		boton_velocidad.add_theme_color_override(
			"font_color",
			Color.YELLOW
		)

	elif velocidad_juego == 2:

		velocidad_juego = 4
		Engine.time_scale = 4.0

		boton_velocidad.text = "x4"
		boton_velocidad.add_theme_color_override(
			"font_color",
			Color.RED
		)

	else:

		velocidad_juego = 1
		Engine.time_scale = 1.0

		boton_velocidad.text = "x1"
		boton_velocidad.add_theme_color_override(
			"font_color",
			Color.WHITE
		)
