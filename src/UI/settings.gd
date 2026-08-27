extends PanelContainer

const ACTION_BUTTONS := {
	"next": "Options/NextChat/Button",
	"toggle_auto_next": "Options/AutoNext/Button",
	"toggle_ui": "Options/HideMenu/Button",
	"toggle_transcript": "Options/OpenTranscript/Button",
	"pause": "Options/PauseButton/Button",
}

var listening_action: String = ""

@onready var listening_container = $ListeningContainer
@onready var listening_label = $ListeningContainer/HBox/Label
@onready var listening_cancel_btn = $ListeningContainer/HBox/CancelBtn



func _ready() -> void:
	# Convert PanelContainer into a full screen blurred overlay
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_FILL
	
	# Add a color rect for blur
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	move_child(dim, 0)
	
	# Create a centering container
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	move_child(center, 1)
	
	# Create a main panel
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(900, 700)
	center.add_child(panel)
	
	# Create tab container
	var tabs = TabContainer.new()
	tabs.set_anchors_preset(Control.PRESET_FULL_RECT)
	tabs.offset_left = 10
	tabs.offset_top = 10
	tabs.offset_right = -10
	tabs.offset_bottom = -10
	panel.add_child(tabs)
	
	# Move existing options into Settings Tab
	var options = get_node("Options")
	remove_child(options)
	
	var margin_settings = MarginContainer.new()
	margin_settings.name = "Settings"
	margin_settings.add_theme_constant_override("margin_left", 20)
	margin_settings.add_theme_constant_override("margin_top", 20)
	tabs.add_child(margin_settings)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin_settings.add_child(scroll)
	
	var scroll_center = CenterContainer.new()
	scroll_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(scroll_center)
	
	scroll_center.add_child(options)
	
	options.add_child(HSeparator.new())
	var quit_btn = Button.new()
	quit_btn.text = "Quit to Main Menu"
	quit_btn.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	quit_btn.pressed.connect(func():
		get_tree().paused = false
		if EventBus.has_signal("scene_change_requested"):
			var root_main = get_node_or_null("/root/Main")
			if root_main:
				EventBus.scene_change_requested.emit(root_main.starting_level, true)
	)
	options.add_child(quit_btn)
	
	# Re-parent listening container to top
	var listening = get_node("ListeningContainer")
	remove_child(listening)
	add_child(listening)
	
	_build_save_tab(tabs)
	_build_status_tab(tabs)
	_build_map_tab(tabs)
	
	_add_volume_sliders(options)
	
	_refresh_keybind_labels()

var save_grid: GridContainer
func _build_save_tab(tabs: TabContainer):
	var margin = MarginContainer.new()
	margin.name = "Save"
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	tabs.add_child(margin)
	
	save_grid = GridContainer.new()
	save_grid.columns = 3
	save_grid.add_theme_constant_override("h_separation", 20)
	save_grid.add_theme_constant_override("v_separation", 20)
	margin.add_child(save_grid)
	
	_refresh_save_ui()

func _refresh_save_ui():
	for c in save_grid.get_children(): c.queue_free()
	for i in range(1, 10):
		var slot = "Slot_" + str(i)
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(260, 120)
		var meta = SaveManager.get_save_metadata(slot)
		if meta.is_empty():
			btn.text = "Save " + str(i) + "\n[Empty]"
		else:
			btn.text = "Save " + str(i) + "\n" + meta["player_name"] + "\n" + meta["timestamp"]
		btn.pressed.connect(func():
			if get_tree().current_scene and get_tree().current_scene.has_node("VNPlayer"):
				GameState.resume_node_id = get_tree().current_scene.get_node("VNPlayer").current_node_id
			SaveManager.save_game(slot)
			_refresh_save_ui()
		)
		save_grid.add_child(btn)

var status_lbl: RichTextLabel
func _build_status_tab(tabs: TabContainer):
	var margin = MarginContainer.new()
	margin.name = "Status"
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	tabs.add_child(margin)
	
	status_lbl = RichTextLabel.new()
	status_lbl.bbcode_enabled = true
	margin.add_child(status_lbl)

func _build_map_tab(tabs: TabContainer):
	var margin = MarginContainer.new()
	margin.name = "Objectives"
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	tabs.add_child(margin)
	
	var lbl = RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.text = "[b]Current Location:[/b] Unknown\n\n[b]Active Quests:[/b]\n- Continue investigating..."
	margin.add_child(lbl)

func _add_volume_sliders(options: Node):
	var fs_btn = CheckButton.new()
	fs_btn.text = "Fullscreen"
	fs_btn.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	fs_btn.toggled.connect(func(t):
		if t: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	options.add_child(fs_btn)
	
	options.add_child(HSeparator.new())
	
	var buses = ["Master", "BGM", "SFX", "Voice"]
	for bus_name in buses:
		var bus_idx = AudioServer.get_bus_index(bus_name)
		if bus_idx == -1: continue
		
		var hbox = HBoxContainer.new()
		var lbl = Label.new()
		lbl.text = bus_name + " Volume"
		lbl.custom_minimum_size = Vector2(150, 0)
		hbox.add_child(lbl)
		
		var slider = HSlider.new()
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
		
		var current_db = AudioServer.get_bus_volume_db(bus_idx)
		slider.value = db_to_linear(current_db)
		
		slider.value_changed.connect(func(val):
			AudioServer.set_bus_volume_db(bus_idx, linear_to_db(val))
		)
		hbox.add_child(slider)
		options.add_child(hbox)

func _refresh_status():
	if not status_lbl: return
	var txt = "[font_size=24][b]Player:[/b] " + GameState.player_name + " (" + GameState.player_class + ")[/font_size]\n"
	txt += "[b]Money:[/b] $" + str(GameState.money) + "\n\n"
	txt += "[b]Stats:[/b]\n"
	for k in GameState.stats.keys():
		var mod = GameState.get_stat_modifier(k)
		txt += k + ": " + str(GameState.stats[k]) + " (+" + str(mod) + ")\n"
	status_lbl.text = txt



func _process(_delta: float) -> void :
	if listening_action != "":
		return

	if (Input.is_action_just_pressed("pause")) :
		if (get_tree().paused) :
			get_tree().paused = false
			hide()

		else :
			get_tree().paused = true
			_refresh_save_ui()
			_refresh_status()
			show()


func _input(event: InputEvent) -> void:
	if listening_action == "":
		return

	if event is InputEventKey and event.pressed and not event.echo:
		GameSettings.set_action_key(listening_action, event)
		_refresh_keybind_labels()
		_stop_listening()
		get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.pressed:
		if listening_cancel_btn.get_global_rect().has_point(event.global_position):
			return
		GameSettings.set_action_key(listening_action, event)
		_refresh_keybind_labels()
		_stop_listening()
		get_viewport().set_input_as_handled()


func _refresh_keybind_labels() -> void:
	for action in ACTION_BUTTONS:
		var btn = find_child(ACTION_BUTTONS[action].split("/")[-2], true, false)
		if btn and btn.has_node("Button"):
			btn.get_node("Button").text = GameSettings.get_action_text(action)


func _begin_listening(action: String) -> void:
	listening_action = action
	listening_label.text = "Listening: %s..." % action
	listening_container.visible = true


func _stop_listening() -> void:
	listening_action = ""
	listening_container.visible = false


func _on_next_chat_pressed() -> void:
	_begin_listening("next")


func _on_auto_next_pressed() -> void:
	_begin_listening("toggle_auto_next")


func _on_hide_menu_pressed() -> void:
	_begin_listening("toggle_ui")


func _on_open_transcript_pressed() -> void:
	_begin_listening("toggle_transcript")


func _on_pause_pressed() -> void:
	_begin_listening("pause")


func _on_slow_toggled(toggled_on: bool) -> void:
	if (toggled_on) :
		GameSettings.text_speed = GameSettings.TextSpeed.SLOW


func _on_medium_toggled(toggled_on: bool) -> void:
	if (toggled_on) :
		GameSettings.text_speed = GameSettings.TextSpeed.MEDIUM


func _on_fast_toggled(toggled_on: bool) -> void:
	if (toggled_on) :
		GameSettings.text_speed = GameSettings.TextSpeed.FAST
