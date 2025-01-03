@tool

extends PanelContainer

const card_scene := preload("res://addons/gd_novel_plugin/StageCard.tscn")
const card_connector_scene := preload("res://addons/gd_novel_plugin/CardsConnector.tscn")

@onready var cards_container := $CardsContainer
@onready var cards_connector_container := $CardsConnectorsContainer


@onready var dragged:Control = null
@onready var resizing:Control = null
@onready var offset:Vector2 = Vector2(0,0)

func fill_blanks() -> void:
	var rnd = RandomNumberGenerator.new()
	var last = null
	for i in range(5):
		var newCard := card_scene.instantiate()
		var card_info = {"title": 'My Card '+ str(i), "meta":{}}
		
		var max_metas = rnd.randi_range(2,5)
		for m in range(max_metas):
			card_info['meta']['meta name '+str(m)] ='val'+str(m)
		newCard.set_card_info(card_info)
		newCard.position = Vector2i(rnd.randi_range(50, 1000), rnd.randi_range(50, 1000));
		newCard.start_drag.connect(start_card_drag)
		newCard.start_resize.connect(start_card_resize)
		newCard.end_drag.connect(end_card)
		newCard.end_resize.connect(end_card)
		newCard.focused.connect(update_focus_stack)
		if last != null:
			var connector = card_connector_scene.instantiate()
			connector.from_card = last
			connector.to_card = newCard
			cards_connector_container.add_child(connector)
		
		cards_container.add_child(newCard)
		last = newCard


func end_card(card: Node) -> void:
	dragged = null
	resizing = null

func start_card_drag(card: Node) -> void:
	if card == null:
		return
	update_focus_stack(card)
	var k = 1.0 / cards_container.scale.x
	var local_mouse = get_local_mouse_position() * k
	offset = local_mouse - card.position
	dragged = card

func start_card_resize(card: Node) -> void:
	if card == null:
		return
	resizing = card
	offset = card.position 

func update_focus_stack(card:Node) -> void:
	var children := cards_container.get_children()
	for child in children :
		if child != card:
			child.z_index = 0
	card.z_index = 1

func _ready() -> void:
	fill_blanks()

func queue_cards_connector_redraw() -> void:
	for children in cards_connector_container.get_children():
		children.queue_redraw()
		children.update_points()

func _process(delta: float) -> void:
	if dragged != null:
		var k = 1.0 / cards_container.scale.x
		var local_mouse = get_local_mouse_position() * k
		dragged.position = local_mouse - offset
		queue_cards_connector_redraw()
	if resizing != null:
		var k = 1.0 / cards_container.scale.x
		var local_mouse = get_local_mouse_position() * k
		resizing.size = Vector2i(
			max((local_mouse.x - offset.x), resizing.custom_minimum_size.x),
			max((local_mouse.y - offset.y), resizing.custom_minimum_size.y)
		)
		queue_cards_connector_redraw()



func _gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		var new_scale = Vector2(min(10, cards_container.scale.x +0.1), min(10, cards_container.scale.y +0.1)) 
		cards_container.scale = new_scale
		cards_connector_container.scale = new_scale
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		var new_scale = Vector2(max(0.1 , cards_container.scale.x - 0.1), max(0.1 , cards_container.scale.y - 0.1)) 
		cards_container.scale = new_scale
		cards_connector_container.scale = new_scale



var start_move_pos := Vector2.ZERO
var dragging_canvas := false

func parse_mouse_button(event: InputEventMouseButton) -> void:
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		start_move_pos = get_global_mouse_position()
		dragging_canvas = true
	elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		dragging_canvas = false
	
func parse_mouse_move(event: InputEventMouseMotion) -> void:
	if dragging_canvas:
		var diff = (get_global_mouse_position() - start_move_pos) * (1 / cards_container.scale.x)
		start_move_pos = get_global_mouse_position()
		for child in cards_container.get_children():
			child.position = child.position + diff
		queue_cards_connector_redraw()

func _on_cards_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		parse_mouse_button(event)
	if event is InputEventMouseMotion:
		parse_mouse_move(event)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		parse_mouse_button(event)
	if event is InputEventMouseMotion:
		parse_mouse_move(event)
