@tool
extends EditorPlugin

const dock_window = preload("res://addons/gd_novel_plugin/dock.tscn")
var dock 

func _enter_tree() -> void:
	dock = dock_window.instantiate()
	dock.name = 'GD Novel'
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dock)
	#add_control_to_bottom_panel(dock, 'GD Novel')

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	#remove_control_from_bottom_panel(dock)
	dock.free()
