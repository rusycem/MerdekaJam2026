extends CanvasLayer

@onready var save_slots_container = $Panel/VBox/SaveSlots
@onready var close_btn = $Panel/VBox/HBox/BtnClose

const SLOTS = ["auto_save", "slot_1", "slot_2", "slot_3"]

func _ready():
	close_btn.pressed.connect(queue_free)
	_refresh_slots()

func _refresh_slots():
	for c in save_slots_container.get_children():
		c.queue_free()
		
	var existing_saves = SaveManager.get_all_saves()
	
	for slot in SLOTS:
		var slot_exists = existing_saves.has(slot)
		var meta = {}
		if slot_exists:
			meta = SaveManager.get_save_metadata(slot)
			
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = slot.replace("_", " ").capitalize()
		if slot_exists and meta.size() > 0:
			label.text += " - %s (%s)\n%s" % [meta.get("player_name", "?"), meta.get("player_class", "?"), meta.get("timestamp", "")]
		else:
			label.text += " (Empty)"
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 20)
		
		var save_btn = Button.new()
		save_btn.text = "Save"
		save_btn.add_theme_font_size_override("font_size", 24)
		if slot == "auto_save":
			save_btn.disabled = true
		else:
			save_btn.pressed.connect(_on_save_pressed.bind(slot))
			
		var load_btn = Button.new()
		load_btn.text = "Load"
		load_btn.add_theme_font_size_override("font_size", 24)
		if not slot_exists:
			load_btn.disabled = true
		else:
			load_btn.pressed.connect(_on_load_pressed.bind(slot))
			
		hbox.add_child(label)
		hbox.add_child(save_btn)
		hbox.add_child(load_btn)
		
		save_slots_container.add_child(hbox)

func _on_save_pressed(slot_name: String):
	SaveManager.save_game(slot_name)
	_refresh_slots()

func _on_load_pressed(slot_name: String):
	if SaveManager.load_game(slot_name):
		# If loading from Main Menu or Dorm, we should transition to the Dorm to show stats
		EventBus.scene_change_requested.emit("res://src/Dorm.tscn", false)
		queue_free()
