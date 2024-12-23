@tool
extends Tree

@onready var tree = $"."
@onready var popup_menu: PopupMenu = $PopupMenu

const ROOT_NODE_ID = "0"
const TREE_DIR:String = "res://gd_novel";
const TREE_FILE_NAME:String = TREE_DIR + "/tree.json";
const TREE_DEFAULT:String = '{"nodes":{"'+ROOT_NODE_ID+'":{"text": "All"}}'

func make_default_tree_file()->void:
	var file:FileAccess = FileAccess.open(TREE_FILE_NAME, FileAccess.WRITE)
	file.store_string(TREE_DEFAULT)
	# it's not actually flushing before closed for me sometimes :\
	file.flush()
	file.close()
	fill_tree(TREE_DEFAULT)

func read_tree_file() -> void:
	print('reading file')
	var file:FileAccess = FileAccess.open(TREE_FILE_NAME, FileAccess.READ)
	var tree_data = file.get_as_text()
	file.close()
	fill_tree(tree_data)
	
func add_tree_node(nodes: Dictionary, node_id:String, parent_tree_item:TreeItem = null) -> void:
	var node = nodes[node_id]
	if typeof(node) != TYPE_DICTIONARY:
		return
	var text:String = "<Empty>"

	if node.has('text') and typeof(node.text) == TYPE_STRING:
		text = node.text
	var current_tree_item:TreeItem = tree.create_item(parent_tree_item)
	current_tree_item.set_text(0, text)
	
	if node.has('children') and typeof(node['children']) == TYPE_ARRAY:
		for child in node['children']:
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
	print('loading tree')
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
			popup_menu.popup_on_parent(Rect2(event.global_position, popup_menu.size))

func connect_tree_signals() -> void:
	tree.connect('empty_clicked', tree_empty_clicked);
	tree.connect('item_activated', tree_item_activated);
	tree.connect('item_mouse_selected', tree_item_mouse_selected);
	
func _ready() -> void:
	print('==READY==')
	load_tree()
	connect_tree_signals()
	
func tree_empty_clicked(click_position: Vector2, mouse_button_index: int) -> void:
	print('empty clicked', click_position, mouse_button_index)
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		tree.get_selected().deselect(0)
	
func tree_item_activated() -> void:
	print('item activated', tree.get_selected())

func tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	print('item mouse selected', tree.get_selected().get_text(0), mouse_button_index)
	
	
	
