extends Control

@onready var name_input = $VBox/HBoxName/NameInput
@onready var class_option = $VBox/HBoxClass/ClassOption
@onready var points_label = $VBox/PointsLabel
@onready var stats_container = $VBox/StatsContainer
@onready var btn_finish = $VBox/BtnFinish

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
	
	btn_finish.pressed.connect(_on_finish)
	
	for stat in base_stats.keys():
		_create_stat_row(stat)
		
	_update_ui()

func _create_stat_row(stat_name: String):
	var hbox = HBoxContainer.new()
	
	var lbl = Label.new()
	lbl.custom_minimum_size = Vector2(200, 0)
	lbl.add_theme_font_size_override("font_size", 24)
	hbox.add_child(lbl)
	
	var btn_minus = Button.new()
	btn_minus.text = " - "
	btn_minus.add_theme_font_size_override("font_size", 24)
	btn_minus.pressed.connect(func(): _modify_stat(stat_name, -1))
	hbox.add_child(btn_minus)
	
	var val_lbl = Label.new()
	val_lbl.custom_minimum_size = Vector2(50, 0)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	val_lbl.add_theme_font_size_override("font_size", 28)
	hbox.add_child(val_lbl)
	
	var btn_plus = Button.new()
	btn_plus.text = " + "
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
	
	for stat in GameState.stats.keys():
		GameState.stats[stat] = base_stats[stat] + allocated_points[stat] + mods[stat]
		
	print("Character Created: ", GameState.player_name, " the ", GameState.player_class)
	print("Stats: ", GameState.stats)
	
	# In a real game, this would go to prologue.tres.
	# For now, we will route to the Dorm where they can manually pick Prologue/Chapter 1
	EventBus.scene_change_requested.emit("res://src/Dorm.tscn", false)
