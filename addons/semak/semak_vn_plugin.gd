@tool
extends EditorPlugin

# Hold a reference to the loaded visual workspace scene
const WORKSPACE_SCENE = preload("res://addons/semak/vn_tree_workspace.tscn")
var workspace_instance: Control

func _enter_tree() -> void:
	# Instantiate our custom visual tree workspace
	workspace_instance = WORKSPACE_SCENE.instantiate()
	
	#Layout
	workspace_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	workspace_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workspace_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Add the workspace scene directly to the Editor Main Screen
	EditorInterface.get_editor_main_screen().add_child(workspace_instance)
	
	# Hide it initially so it doesn't render over active workspaces
	_make_visible(false)

func _exit_tree() -> void:
	# Clean up the node when the plugin is disabled or reloaded
	if workspace_instance:
		workspace_instance.queue_free()

# Required method to declare this as a top-level editor screen tab
func _has_main_screen() -> bool:
	return true

# Godot uses this to control toggling when switching tabs
func _make_visible(visible: bool) -> void:
	if workspace_instance:
		workspace_instance.visible = visible

# Defines the text string displayed on the main editor tab button
func _get_plugin_name() -> String:
	return "SeMaK VN Tree"

# Optional: Return a Texture2D to add an icon next to the tab name
func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("GraphEdit", "EditorIcons")
