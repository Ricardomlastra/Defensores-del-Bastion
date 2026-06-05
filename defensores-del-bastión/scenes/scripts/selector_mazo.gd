extends Control

@onready var grid = $CartasDisponibles

@onready var slots = [
	$CartasSeleccionadas/slot1,
	$CartasSeleccionadas/slot2,
	$CartasSeleccionadas/slot3,
	$CartasSeleccionadas/slot4,
	$CartasSeleccionadas/slot5,
	$CartasSeleccionadas/slot6
]
@onready var label2 = $Label2
@onready var descripcion_panel = $DescripcionCarta
@onready var nombre_label = $DescripcionCarta/Nombre
@onready var descripcion_label = $DescripcionCarta/Descripcion

var seleccionadas: Array = []

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

var nombres_cartas = {
	"arquero_hielo": "Arquero de Hielo",
	"asustadizo": "Asustadizo",
	"central": "Central Energética",
	"dragon": "Dragón",
	"laser": "Ciborg Láser",
	"maestro_de_drones": "Maestro de Drones",
	"mago_electrico": "Mago Eléctrico",
	"monarca_de_las_sombras": "Monarca de las Sombras",
	"paladin": "Paladín",
	"sniper": "Francotirador",
	"tropa_base": "Caballero"
}

var descripciones = {
	"arquero_hielo": "Dispara flechas heladas una casilla por delante de si mismo que ralentizan enemigos.",
	"asustadizo": "Se teletransporta a otro slot cuando recibe daño.",
	"central": "Genera energía cada cierto tiempo.",
	"dragon": "Quema a los enemigos al atacar.",
	"laser": "Dispara rayos láser a distancia en cualquier linea donde vengan los enemigos.",
	"maestro_de_drones": "Invoca drones de apoyo que atacan a los enemigos tanto en la línea que esta como en las adyacentes.",
	"mago_electrico": "Los rayos rebotan entre enemigos cercanos. (limite: 3)",
	"monarca_de_las_sombras": "Invoca sombras al derrotar enemigos.",
	"paladin": "Gran resistencia y combate cuerpo a cuerpo.",
	"sniper": "Alcance enorme y daño elevado.",
	"tropa_base": "Lanza ataques de aire al pegar con su espada con una distancia media."
}

const TAMANO_CARTA = Vector2(120, 160)
const MAX_CARTAS = 6
const TEXTURA_VACIA = "res://cartas/carta_vacia.png"

func _ready():
	generar_cartas()

	for slot in slots:
		slot.gui_input.connect(func(event):
			_on_slot_click(event, slot)
		)

	actualizar_slots()

func _process(delta):

	if descripcion_panel.visible:

		var mouse = get_viewport().get_mouse_position()

		descripcion_panel.global_position = Vector2(
			mouse.x + 20,
			mouse.y - descripcion_panel.size.y - 20
		)

		if descripcion_panel.global_position.y < 0:
			descripcion_panel.global_position.y = 0

		if descripcion_panel.global_position.x + descripcion_panel.size.x > get_viewport_rect().size.x:
			descripcion_panel.global_position.x = mouse.x - descripcion_panel.size.x - 20

func generar_cartas():
	for carta_id in GameManager.cartas_disponibles:

		var contenedor = CenterContainer.new()
		contenedor.custom_minimum_size = TAMANO_CARTA

		var carta = TextureRect.new()
		carta.texture = load("res://cartas/" + carta_id + ".png")

		carta.custom_minimum_size = TAMANO_CARTA
		carta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		carta.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		carta.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				seleccionar_carta(carta_id)
		)

		contenedor.add_child(carta)
		grid.add_child(contenedor)
		carta.mouse_entered.connect(func():
			mostrar_descripcion(carta_id)
		)

		carta.mouse_exited.connect(func():
			ocultar_descripcion()
		)

func seleccionar_carta(carta_id):
	if seleccionadas.size() >= MAX_CARTAS:
		return

	if carta_id in seleccionadas:
		return

	seleccionadas.append(carta_id)

	actualizar_slots()

func quitar_carta(indice):
	if indice < 0 or indice >= seleccionadas.size():
		return

	seleccionadas.remove_at(indice)

	actualizar_slots()

func actualizar_slots():
	for i in range(MAX_CARTAS):

		if i < seleccionadas.size():

			var carta_id = seleccionadas[i]

			slots[i].texture = load(
				"res://cartas/" + carta_id + ".png"
			)

			slots[i].set_meta("indice", i)

		else:

			slots[i].texture = load(TEXTURA_VACIA)

			if slots[i].has_meta("indice"):
				slots[i].remove_meta("indice")

func _on_slot_click(event, slot):
	if event is InputEventMouseButton and event.pressed:

		if slot.has_meta("indice"):
			quitar_carta(slot.get_meta("indice"))

func _on_confirmar_pressed():
	if seleccionadas.size() != MAX_CARTAS:
		label2.visible = true
		return

	GameManager.mazo_seleccionado = seleccionadas.duplicate()

	print("Mazo guardado:", GameManager.mazo_seleccionado)

	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func mostrar_descripcion(carta_id):

	var escena = escenas[carta_id]
	var tropa = escena.instantiate()

	nombre_label.text = nombres_cartas[carta_id]

	var texto := ""

	if "dano" in tropa:
		texto += "[img=24]res://ui/icono_dano.png[/img] " + "Daño: " + str(tropa.dano) + "\n"

	if "tiempo_ataque" in tropa:
		texto += "[img=24]res://ui/icono_ataque.png[/img] " + "Velocidad de Ataque: " + str(tropa.tiempo_ataque) + " s\n"

	if "vida_maxima" in tropa:
		texto += "[img=24]res://ui/icono_vida.png[/img] " + "Vida: " + str(tropa.vida_maxima) + "\n"

	if "coste" in tropa:
		texto += "[img=24]res://ui/icono_coste.png[/img] " + "Coste de Energía: " + str(tropa.coste) + "\n"

	texto += "\n" + descripciones[carta_id]

	descripcion_label.text = texto
	await get_tree().process_frame

	descripcion_panel.custom_minimum_size.y = \
		nombre_label.get_minimum_size().y + \
		descripcion_label.get_minimum_size().y + 40

	tropa.queue_free()

	descripcion_panel.visible = true

func ocultar_descripcion():
	descripcion_panel.visible = false
