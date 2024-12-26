@tool
extends EditorPlugin

const stage_editor := preload("res://addons/gd_novel_plugin/StageEditor.tscn")
const dock_window := preload("res://addons/gd_novel_plugin/dock.tscn")
const icon := preload("res://addons/gd_novel_plugin/icons/diagram-3-fill.svg")
var dock:Node
var stage:Node


func _enter_tree() -> void:
	dock = dock_window.instantiate()
	stage = stage_editor.instantiate()
	dock.name = 'GD Novel'
	stage.name = 'GD Novel - stage'
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dock)
	
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(stage)
	# Hide the main panel. Very much required.
	_make_visible(false)
	
func _exit_tree() -> void:
	remove_control_from_docks(dock)
	#remove_control_from_bottom_panel(dock)
	dock.free()
	if stage:
		stage.queue_free()
	
func _has_main_screen():
	return true

func _make_visible(visible):
	if stage:
		stage.visible = visible	
	
func _get_plugin_name():
	return "GDN graph"

func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return icon
