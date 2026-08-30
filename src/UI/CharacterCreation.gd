extends Control

@onready var name_input = $Paper/VBox/HBoxName/NameInput
@onready var class_option = $Paper/VBox/HBoxClass/ClassOption
@onready var hbox_class = $Paper/VBox/HBoxClass
# 1. Grab the new GenderOption node from your scene
@onready var gender_option = $Paper/VBox/HBoxGender/GenderOption 
@onready var points_label = $Paper/VBox/PointsLabel
@onready var stats_container = $Paper/VBox/StatsContainer
@onready var btn_finish = $Paper/VBox/BtnFinish
@onready var animation = $AnimationPlayer

var available_points: int = 4
var base_stats: Dictionary = {
	"Charm": 5,
	"Intelligence": 5,
	"Courage": 5,
	"Dexterity": 5
}
var allocated_points: Dictionary = {
	"Charm": 0,
	"Intelligence": 0,
	"Courage": 0,
	"Dexterity": 0
}

var classes = {
	"Academician": {"Charm": -3, "Intelligence": 2, "Courage": 0, "Dexterity": 0},
	"Athlete": {"Charm": 0, "Intelligence": -3, "Courage": 0, "Dexterity": 2},
	"Class Clown": {"Charm": 5, "Intelligence": -3, "Courage": 0, "Dexterity": -3}
}

func _ready():
	class_option.add_item("Academician")
	class_option.add_item("Athlete")
	class_option.add_item("Class Clown")
	class_option.item_selected.connect(func(_idx): _update_ui())
	
	# 2. Add the items here (if you haven't already added them in the Godot Inspector!)
	gender_option.add_item("Male")
	gender_option.add_item("Female")
	
	# ALL the dynamic HBoxGender generation code has been removed from here!
	
	btn_finish.pressed.connect(_on_finish)
	
	for stat in base_stats.keys():
		_create_stat_row(stat)
		
	_update_ui()

func _create_stat_row(stat_name: String):
	var hbox = HBoxContainer.new()
	
	var lbl = Label.new()
	lbl.theme = load("res://assets/UIAssets/ui.tres")
	lbl.custom_minimum_size = Vector2(200, 0)
	lbl.add_theme_font_size_override("font_size", 20)
	hbox.add_child(lbl)
	
	var btn_minus = TextureButton.new()
	#btn_minus.text = " - "
	btn_minus.texture_normal = load("res://assets/UIAssets/minus_button.png")
	btn_minus.add_theme_font_size_override("font_size", 24)
	btn_minus.pressed.connect(func(): _modify_stat(stat_name, -1))
	hbox.add_child(btn_minus)
	
	var val_lbl = Label.new()
	val_lbl.theme = load("res://assets/UIAssets/ui.tres")
	val_lbl.custom_minimum_size = Vector2(50, 0)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	val_lbl.add_theme_font_size_override("font_size", 28)
	hbox.add_child(val_lbl)
	
	var btn_plus = TextureButton.new()
	#btn_plus.text = " + "
	btn_plus.texture_normal = load("res://assets/UIAssets/plus_button.png")
	btn_plus.add_theme_font_size_override("font_size", 24)
	btn_plus.pressed.connect(func(): _modify_stat(stat_name, 1))
	hbox.add_child(btn_plus)
	
	# Store references dynamically
	hbox.set_meta("stat_name", stat_name)
	hbox.set_meta("lbl", lbl)
	hbox.set_meta("val_lbl", val_lbl)
	
	stats_container.add_child(hbox)

func _modify_stat(stat_name: String, amount: int):
	var current = allocated_points[stat_name]
	
	if amount > 0 and available_points > 0:
		allocated_points[stat_name] += 1
		available_points -= 1
	elif amount < 0 and current > 0:
		allocated_points[stat_name] -= 1
		available_points += 1
		
	_update_ui()

func _update_ui():
	points_label.text = "Points Remaining: %d" % available_points
	btn_finish.disabled = (available_points > 0)
	
	var selected_class = class_option.get_item_text(class_option.selected)
	var mods = classes[selected_class]
	
	for hbox in stats_container.get_children():
		var stat_name = hbox.get_meta("stat_name")
		var lbl: Label = hbox.get_meta("lbl")
		var val_lbl: Label = hbox.get_meta("val_lbl")
		
		var mod = mods[stat_name]
		var mod_str = ""
		if mod > 0:
			mod_str = " (+%d from Class)" % mod
		elif mod < 0:
			mod_str = " (%d from Class)" % mod
			
		lbl.text = stat_name + mod_str
		val_lbl.text = str(base_stats[stat_name] + allocated_points[stat_name] + mod)

func _on_finish():
	GameState.reset_state()
	
	if name_input.text.strip_edges() == "":
		name_input.text = "Student"
		
	var selected_class = class_option.get_item_text(class_option.selected)
	var mods = classes[selected_class]
	
	GameState.player_name = name_input.text.strip_edges()
	GameState.player_class = selected_class
	GameState.player_gender = gender_option.get_item_text(gender_option.selected)
	
	for stat in GameState.stats.keys():
		GameState.stats[stat] = base_stats[stat] + allocated_points[stat] + mods[stat]
		
	print("Character Created: ", GameState.player_name, " the ", GameState.player_class)
	print("Stats: ", GameState.stats)
	
	var stats_res = load("res://assets/DataAssets/player1_stats.tres")
	if stats_res:
		stats_res.character_name = GameState.player_name
		stats_res.gender = GameState.player_gender
		stats_res.dexterity = GameState.stats["Dexterity"]
		stats_res.intelligence = GameState.stats["Intelligence"]
		stats_res.charisma = GameState.stats["Charm"]
		ResourceSaver.save(stats_res, "res://assets/DataAssets/player1_stats.tres")
	
	# In a real game, this would go to prologue.tres.
	# For now, we will route to the Dorm where they can manually pick Prologue/Chapter 1
	animation.play("outro")
	await animation.animation_finished
	EventBus.scene_change_requested.emit("res://src/Dorm.tscn", false)
