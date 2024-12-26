@tool

extends PanelContainer

const card_scene := preload("res://addons/gd_novel_plugin/StageCard.tscn")
@onready var cards_container := $CardsContainer

@onready var dragged:Node = null
@onready var resizing:Node = null
@onready var offset:Vector2 = Vector2(0,0)

func fill_blanks() -> void:
	var rnd = RandomNumberGenerator.new()
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
		cards_container.add_child(newCard)


func end_card(card: Node) -> void:
	dragged = null
	resizing = null

func start_card_drag(card: Node) -> void:
	if card == null:
		return
	update_focus_stack(card)
	offset = get_local_mouse_position() - card.position
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

func _process(delta: float) -> void:
	if dragged != null:
		dragged.position = get_local_mouse_position() - offset
	if resizing != null:
		var local_mouse = get_local_mouse_position()
		resizing.size = Vector2i(
			max(local_mouse.x - offset.x, resizing.custom_minimum_size.x),
			max(local_mouse.y - offset.y, resizing.custom_minimum_size.y)
		)
