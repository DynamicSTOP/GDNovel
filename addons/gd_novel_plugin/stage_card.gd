@tool
extends PanelContainer

signal start_drag(node:Node)
signal end_drag(node:Node)
signal start_resize(node:Node)
signal end_resize(node:Node)
signal focused(node:Node)

@onready var card_title_label: Label = $MarginContainer/VBoxContainer/HeaderContainer/CardTitleLabel
@onready var meta_container: VBoxContainer = $MarginContainer/VBoxContainer/BodyContainer/ScrollContainer/MetaContainer
@onready var is_hovering := false

const CARD_INFO_TITLE = 'title'
const CARD_INFO_METAS = 'meta'

var card_info: Dictionary = {}
@onready var cards_next: Array[Control] = []

func set_card_info(info: Dictionary) -> void:
	card_info = info

func _ready() -> void:
	if card_info.has(CARD_INFO_TITLE) and typeof(card_info[CARD_INFO_TITLE])==TYPE_STRING:
		var card_title = card_info[CARD_INFO_TITLE]
		card_title_label.text = card_title
	
	if card_info.has(CARD_INFO_METAS) and typeof(card_info[CARD_INFO_METAS]) == TYPE_DICTIONARY:
		var card_metas = card_info[CARD_INFO_METAS]
		for key in card_metas:
			var val = card_metas[key]
			if typeof(val) == TYPE_FLOAT or typeof(val) == TYPE_INT:
				add_meta_line(key, str(val))
			elif typeof(val) == TYPE_STRING:
				add_meta_line(key, val)
			else:
				add_meta_line(key, JSON.stringify(val)) 
	
	updateMinSize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func add_meta_line(meta_name:String, metaValue:String, focus:bool = false) -> void:
	var h_split_container = HSplitContainer.new()
	var label = Label.new()
	label.text = meta_name
	h_split_container.add_child(label)
	var line_edit = LineEdit.new()
	line_edit.text = metaValue
	#todo do i need to disconnect?
	line_edit.focus_entered.connect(emit_focused)
	h_split_container.add_child(line_edit)
	meta_container.add_child(h_split_container)
	if focus:
		line_edit.select()

func updateMinSize() -> void:
	$".".custom_minimum_size = $MarginContainer.size

func _on_move_button_button_down() -> void:
	emit_signal('start_drag', self)

func _on_move_button_button_up() -> void:
	emit_signal('end_drag', self)

func _on_add_meta_line_pressed() -> void:
	add_meta_line('Name', '', true)


func _on_clear_meta_button_pressed() -> void:
	var children := meta_container.get_children()
	for child in children:
		child.queue_free()


func _on_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton or !is_hovering or event.button_index != MOUSE_BUTTON_LEFT:
		return 
	if event.is_pressed():
		emit_focused()
	if event.is_released():
		emit_signal("end_drag", self)
		emit_signal("end_resize", self)
		
func emit_focused() -> void:
	emit_signal("focused", self)

func _on_mouse_entered() -> void:
	is_hovering = true
	
func _on_mouse_exited() -> void:
	is_hovering = false
	
func _on_resize_button_button_down() -> void:
	emit_signal("start_resize", self)

func _on_resize_button_button_up() -> void:
	emit_signal("end_resize", self)
	
func add_card_next(node:Node) -> void:
	if !cards_next.has(node):
		cards_next.push_back(node)

func draw_line_to(node:Control) -> void:
	var from = Vector2(size.x, size.y/2)
	var to = node.global_position - global_position + Vector2(0, node.size.y/2)
	draw_line(from, to, Color.WHITE, 4, true)
	
func _draw() -> void:
	for next in cards_next:
		draw_line_to(next)
		
