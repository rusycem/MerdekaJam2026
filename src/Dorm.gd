extends Control

# 1. Preload the custom font at the top
var custom_font = preload("res://assets/UIAssets/cc.otf")

@export_category("Story Routes")
@export var prologue_tree: Resource

@export_group("Chapters")
@export var mirul_chapters: Array[Resource]
@export var alyssa_chapters: Array[Resource]
@export var vihaan_chapters: Array[Resource]

@onready var chapter_list = $HBox/ChaptersPanel/VBox/ChapterList
@onready var btn_save_load = $HBox/RightPanel/SystemPanel/VBox/BtnSaveLoad
@onready var btn_main_menu = $HBox/RightPanel/SystemPanel/VBox/BtnMainMenu

func _ready():
	if Engine.has_singleton("SaveManager"):
		SaveManager.save_game("auto_save")
		
	btn_save_load.pressed.connect(_open_save_menu)
	btn_main_menu.pressed.connect(_quit_to_title)
	
	_rebuild_right_panel()
	_populate_chapters()

func _rebuild_right_panel():
	var right_panel = $HBox/RightPanel
	
	# Create TabContainer
	var tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Apply font to TabContainer
	tabs.add_theme_font_override("font", custom_font)
	tabs.add_theme_font_size_override("font_size", 24)
	
	# Create Character Stats tab
	var stats_tab = MarginContainer.new()
	stats_tab.name = "Character Info"
	stats_tab.add_theme_constant_override("margin_left", 20)
	stats_tab.add_theme_constant_override("margin_top", 20)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	stats_tab.add_child(vbox)
	
	var info = Label.new()
	info.text = "Name: %s\nClass: %s\nGender: %s\nMoney: %d\n" % [GameState.player_name, GameState.player_class, GameState.player_gender, GameState.money]
	
	# Apply font to info label
	info.add_theme_font_override("font", custom_font)
	info.add_theme_font_size_override("font_size", 24)
	vbox.add_child(info)
	
	for stat in GameState.stats.keys():
		var lbl = Label.new()
		lbl.text = "%s: %d" % [stat, GameState.stats[stat]]
		
		# Apply font to stat labels
		lbl.add_theme_font_override("font", custom_font)
		lbl.add_theme_font_size_override("font_size", 20)
		vbox.add_child(lbl)
		
	# Move existing panels into tabs
	var radio_panel = $HBox/RightPanel/RadioPanel
	var system_panel = $HBox/RightPanel/SystemPanel
	
	radio_panel.get_parent().remove_child(radio_panel)
	system_panel.get_parent().remove_child(system_panel)
	
	radio_panel.name = "Radio"
	system_panel.name = "System"
	
	# Remove their label titles since tabs have names
	radio_panel.get_node("VBox/Label").hide()
	radio_panel.get_node("VBox/HSeparator").hide()
	system_panel.get_node("VBox/Label").hide()
	system_panel.get_node("VBox/HSeparator").hide()
	
	tabs.add_child(stats_tab)
	tabs.add_child(radio_panel)
	tabs.add_child(system_panel)
	
	right_panel.add_child(tabs)
	
	_setup_radio_buttons(radio_panel.get_node("VBox"))
	
	if get_tree().root.has_node("AudioManager"):
		AudioManager.play_bgm(GameState.selected_radio_bgm)

func _populate_chapters():
	for c in chapter_list.get_children():
		c.queue_free()
		
	var has_companion = GameState.has_flag("companion_mirul") or GameState.has_flag("companion_alyssa") or GameState.has_flag("companion_vihaan")
	
	if prologue_tree and not has_companion:
		_add_chapter_button("Prologue", prologue_tree.resource_path, "completed_prologue")
		
	if GameState.has_flag("companion_mirul"):
		for i in range(mirul_chapters.size()):
			if mirul_chapters[i]:
				if i == 0 or GameState.has_flag("completed_mirul_ch%d" % i):
					_add_chapter_button("Chapter %d (Mirul)" % (i + 1), mirul_chapters[i].resource_path, "completed_mirul_ch%d" % (i + 1))
	elif GameState.has_flag("companion_alyssa"):
		for i in range(alyssa_chapters.size()):
			if alyssa_chapters[i]:
				if i == 0 or GameState.has_flag("completed_alyssa_ch%d" % i):
					_add_chapter_button("Chapter %d (Alyssa)" % (i + 1), alyssa_chapters[i].resource_path, "completed_alyssa_ch%d" % (i + 1))
	elif GameState.has_flag("companion_vihaan"):
		for i in range(vihaan_chapters.size()):
			if vihaan_chapters[i]:
				if i == 0 or GameState.has_flag("completed_vihaan_ch%d" % i):
					_add_chapter_button("Chapter %d (Vihaan)" % (i + 1), vihaan_chapters[i].resource_path, "completed_vihaan_ch%d" % (i + 1))
	else:
		var lbl = Label.new()
		lbl.text = "Play Prologue to unlock Chapters."
		
		# Apply font to fallback label
		lbl.add_theme_font_override("font", custom_font)
		lbl.add_theme_font_size_override("font_size", 24)
		chapter_list.add_child(lbl)

func _add_chapter_button(title: String, uid: String, completion_flag: String = ""):
	var btn = Button.new()
	btn.text = title
	
	# Apply font to chapter buttons
	btn.add_theme_font_override("font", custom_font)
	btn.add_theme_font_size_override("font_size", 28)
	
	if completion_flag != "" and GameState.has_flag(completion_flag):
		btn.disabled = true
		btn.text += " (Completed)"
	else:
		btn.pressed.connect(func(): _play_chapter(uid, completion_flag))
		
	chapter_list.add_child(btn)

func _play_chapter(uid: String, completion_flag: String):
	print("Dorm: Starting Chapter ", uid)
	# We automatically grant the completion flag right when they start it.
	# We DO NOT auto-save here. That way, if they quit mid-chapter, reloading
	# their save (which was created upon entering the Dorm) will still have it unlocked!
	if completion_flag != "":
		if not GameState.has_flag(completion_flag):
			GameState.flags.append(completion_flag)
			
	EventBus.play_visual_novel.emit(uid)

func _open_save_menu():
	var save_menu_res = load("res://scenes/UI/SaveMenu.tscn")
	if save_menu_res:
		var sm = save_menu_res.instantiate()
		add_child(sm)

func _quit_to_title():
	EventBus.scene_change_requested.emit("res://scenes/UI/main_menu.tscn", true)




func _setup_radio_buttons(vbox: VBoxContainer) -> void:
	var mapping = {
		"BtnRadio1": "res://assets/audio/bgm/SchoolOfOldLaughingPeople.ogg",
		"BtnRadio2": "res://assets/audio/bgm/Wednesday19th.ogg",
		"BtnRadio3": "res://assets/audio/bgm/PantsFor40RM.ogg",
		"BtnRadio4": "res://assets/audio/bgm/ADogInTurkey.ogg",
		"BtnRadio5": "res://assets/audio/bgm/7479.ogg",
		"BtnRadio6": "res://assets/audio/bgm/WhoTheHellAreYou.ogg"
	}
	
	for btn_name in mapping.keys():
		var btn = vbox.get_node(btn_name)
		if btn:
			var uid = mapping[btn_name]
			btn.pressed.connect(func():
				GameState.selected_radio_bgm = uid
				if get_tree().root.has_node("AudioManager"):
					AudioManager.play_bgm(uid)
			)
