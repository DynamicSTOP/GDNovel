@tool
extends Tree

@onready var tree = $"."
@onready var popup_menu: PopupMenu = $PopupMenu
@onready var add_button:Button = $PopupMenu/VBoxContainer/AddButton
@onready var rename_button:Button = $PopupMenu/VBoxContainer/RenameButton
@onready var remove_button:Button = $PopupMenu/VBoxContainer/RemoveButton
@onready var icon: Resource = preload("res://addons/gd_novel_plugin/icons/filter-circle.svg")

const ROOT_NODE_ID = "0"
const TREE_DIR:String = "res://gd_novel"
const TREE_FILE_NAME:String = TREE_DIR + "/tree.json"
const TREE_DEFAULT:String = '{"nodes":{"'+ROOT_NODE_ID+'":{"text": "All"}}'
const NEW_ITEM_TEXT:String = "<Empty>"
const META_TEXT = 'text'
const META_ID = 'id'

func make_default_tree_file()->void:
	var file:FileAccess = FileAccess.open(TREE_FILE_NAME, FileAccess.WRITE)
	file.store_string(TREE_DEFAULT)
	# it's not actually flushing before closed for me sometimes :\
	file.flush()
	file.close()
	fill_tree(TREE_DEFAULT)

func save_tree_to_file() -> void:
	var root = tree.get_root()
	var json: Dictionary = {'nodes':{}}
	if root == null:
		return
	add_node_to_json(json, root)
	var file:FileAccess = FileAccess.open(TREE_FILE_NAME, FileAccess.WRITE)
	file.store_string(JSON.stringify(json))
	file.flush()
	file.close()

func add_node_to_json(json:Dictionary, node:TreeItem) -> void:	
	var node_json = {'text':node.get_text(0)}
	var children:Array[String] = []
	for child in node.get_children():
		children.push_back(child.get_meta(META_ID))
		add_node_to_json(json, child)
	if children.size() > 0:
		node_json['children'] = children
	json['nodes'][node.get_meta(META_ID)] = node_json
	
func read_tree_file() -> void:
	var file:FileAccess = FileAccess.open(TREE_FILE_NAME, FileAccess.READ)
	var tree_data = file.get_as_text()
	file.close()
	fill_tree(tree_data)
	
func add_tree_node(nodes: Dictionary, node_id:String, parent_tree_item:TreeItem = null) -> void:
	var node = nodes[node_id]
	if typeof(node) != TYPE_DICTIONARY:
		return
	var text:String = NEW_ITEM_TEXT

	if node.has('text') and typeof(node.text) == TYPE_STRING:
		text = node.text
	var current_tree_item:TreeItem = tree.create_item(parent_tree_item)
	current_tree_item.set_text(0, text)
	#current_tree_item.set_icon(0, icon)
	current_tree_item.set_meta(META_TEXT, text)
	current_tree_item.set_meta(META_ID, node_id)
	
	if node.has('children') and typeof(node['children']) == TYPE_ARRAY:
		for child in node['children']:
			if typeof(child) == TYPE_STRING:
				add_tree_node(nodes, child, current_tree_item)
	
func fill_tree(tree_json:String) -> void:
	var json = JSON.new()
	var error = json.parse(tree_json)
	if error == OK:
		var tree_data = json.data
		if ( typeof(tree_data) == TYPE_DICTIONARY 
			and typeof(tree_data.nodes) == TYPE_DICTIONARY 
			and typeof(tree_data.nodes["0"]) == TYPE_DICTIONARY ):
			add_tree_node(tree_data.nodes, "0")
		else:
			print("Unexpected data")
	else:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", tree_json, " at line ", json.get_error_line())
	
func load_tree() -> void:
	if not DirAccess.dir_exists_absolute(TREE_DIR):
		DirAccess.make_dir_recursive_absolute(TREE_DIR)
		
	if FileAccess.file_exists(TREE_FILE_NAME):
		read_tree_file()
	else:
		make_default_tree_file()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var item = get_item_at_position(event.position)
			if item == null:
				return
			item.select(0)
			var is_root_node:bool = item.get_meta(META_ID) == ROOT_NODE_ID
			rename_button.visible = !is_root_node
			remove_button.visible = !is_root_node
			# this is dumb... yet it doesn't want to resize on it's own
			var size = Vector2i(100, add_button.size.y)
			if !is_root_node:
				size.y = add_button.size.y * 3 + 8
			popup_menu.popup_on_parent(Rect2(event.global_position, size ))
	
func _ready() -> void:
	drop_mode_flags = DROP_MODE_DISABLED
	print_debug('==GD NOVEL READY==')
	load_tree()


func start_rename_item(item:TreeItem) -> void:
	if(popup_menu.visible):
		await(popup_menu.popup_hide)
	item.set_editable(0, true)
	item.select(0)
	tree.edit_selected(true)
	await(tree.item_edited)
	item.set_editable(0, false)
	item.select(0)
	var old:Variant = null
	if(item.has_meta(META_TEXT)):
		old = item.get_meta(META_TEXT)
	if old == null or typeof(old) != TYPE_STRING or old != item.get_text(0):
		save_tree_to_file()
	item.set_meta(META_TEXT, item.get_text(0))

func _on_add_button_button_down() -> void:
	var current_item:TreeItem = tree.get_selected()
	if current_item == null:
		return
	var new_item:TreeItem = tree.create_item(current_item, 0)
	new_item.set_text(0, NEW_ITEM_TEXT)
	new_item.set_meta(META_ID, str(int(Time.get_unix_time_from_system())))
	start_rename_item(new_item)
	
func _on_empty_clicked(click_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		var selected:TreeItem = tree.get_selected()
		if selected != null:
			selected.deselect(0)

func _on_item_activated() -> void:
	var current_item:TreeItem = tree.get_selected()
	if current_item == null:
		return
	print('item activated', current_item,' ',current_item.get_meta(META_ID),' ', current_item.get_meta(META_TEXT))
	
func _on_rename_button_button_down() -> void:
	var current_item:TreeItem = tree.get_selected()
	if current_item == null:
		return
	current_item.get_text(0)
	start_rename_item(current_item)

func _on_remove_button_button_down() -> void:
	var current_item:TreeItem = tree.get_selected()
	if current_item == null:
		return
	#TODO check inner scenes, ask if any exist
	current_item.free()
	save_tree_to_file()


func _get_drag_data(_at_position: Vector2) -> Variant:
	var current:TreeItem = tree.get_selected()
	# if nothing selected 
	if current == null:
		return
	# if trying to drag root 
	if current.has_meta(META_ID) and current.get_meta(META_ID) == ROOT_NODE_ID:
		return
	
	var v := VBoxContainer.new()
	var l := Label.new()
	l.text = current.get_text(0)
	v.add_child(l)
	
	set_drag_preview(v)
	return current

func _can_drop_data(at_position: Vector2, dragged: Variant) -> bool:
	drop_mode_flags = Tree.DROP_MODE_INBETWEEN << Tree.DROP_MODE_ON_ITEM
	
	var drop_section := get_drop_section_at_position(at_position)	
	var item_at_pos := get_item_at_position(at_position)
	
	# trying to put before root
	if (item_at_pos != null and drop_section == -1  
		and item_at_pos.has_meta(META_ID) and item_at_pos.get_meta(META_ID) == ROOT_NODE_ID):
		return false  
	
	# if we are trying to drop item on itself
	if item_at_pos == dragged:
		return false
		
	# TODO block dropping before and after itself
		
	# if we are trying to drop inside itself
	while item_at_pos:
		if item_at_pos.get_parent() == dragged:
			return false
		item_at_pos = item_at_pos.get_parent()
		
	return true

func _drop_data(at_position: Vector2, dragged: Variant) -> void:
	var drop_section := get_drop_section_at_position(at_position)
	var other_item := get_item_at_position(at_position)
	var sprite_groups := []
	
	if other_item == null:
		return
	
	if drop_section == 0:
		dragged.get_parent().remove_child(dragged)
		other_item.add_child(dragged)
	elif drop_section == -1:
		dragged.move_before(other_item)
	else:
		dragged.move_after(other_item)
	
	save_tree_to_file()
