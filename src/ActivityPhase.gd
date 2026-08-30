extends Control

@onready var turns_label = $TurnsLabel
@onready var stat_labels_container = $StatsPanel/VBox/StatLabels

func _ready():
	$ActivitiesPanel/VBox/BtnStudy.pressed.connect(_on_activity.bind("Intelligence", 2))
	$ActivitiesPanel/VBox/BtnWorkout.pressed.connect(_on_activity.bind("Dexterity", 2))
	$ActivitiesPanel/VBox/BtnSocialize.pressed.connect(_on_activity.bind("Charm", 2))
	$ActivitiesPanel/VBox/BtnExplore.pressed.connect(_on_activity.bind("Courage", 2))
	
	_update_ui()

func _update_ui():
	turns_label.text = "Turns: %d" % GameState.hub_turns_remaining
	
	# Clear old labels
	for c in stat_labels_container.get_children():
		c.queue_free()
		
	# Rebuild labels
	for stat in GameState.stats.keys():
		var lbl = Label.new()
		lbl.text = "%s: %d" % [stat, GameState.stats[stat]]
		lbl.add_theme_font_size_override("font_size", 24)
		stat_labels_container.add_child(lbl)
		
	var money_lbl = Label.new()
	money_lbl.text = "Money: %d" % GameState.money
	money_lbl.add_theme_font_size_override("font_size", 24)
	money_lbl.add_theme_color_override("font_color", Color.GOLD)
	stat_labels_container.add_child(money_lbl)

func _on_activity(stat_name: String, amount: int):
	if GameState.hub_turns_remaining <= 0:
		return
		
	# Deduct turn
	GameState.hub_turns_remaining -= 1
	
	# Add stat
	GameState.stats[stat_name] += amount
	
	# Try to inject into VN backlog!
	if get_node_or_null("/root/Main") and get_node("/root/Main").cached_vn:
		var vn = get_node("/root/Main").cached_vn
		if vn.has_method("add_to_history"):
			vn.add_to_history("System", "+%d %s (Activity)" % [amount, stat_name], "")
			
	# Refresh UI
	_update_ui()
	
	# Spawn floating text near mouse
	_spawn_floating_text("+%d %s" % [amount, stat_name], get_global_mouse_position())
	
	# Check if out of turns
	if GameState.hub_turns_remaining <= 0:
		_transition_to_next_chapter()

func _spawn_floating_text(msg: String, pos: Vector2):
	var lbl = Label.new()
	lbl.text = msg
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	lbl.add_theme_constant_override("outline_size", 4)
	
	# Center it on the mouse roughly
	lbl.position = pos - Vector2(50, 20)
	add_child(lbl)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 100, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(lbl, "modulate:a", 0.0, 1.5).set_ease(Tween.EASE_IN)
	tw.set_parallel(false)
	tw.tween_callback(lbl.queue_free)

func _transition_to_next_chapter():
	# Disable buttons
	for btn in $ActivitiesPanel/VBox.get_children():
		if btn is Button:
			btn.disabled = true
			
	print("Lobby: Out of turns! Resuming Visual Novel...")
	
	# Wait a tiny bit so they can see the final floating text
	await get_tree().create_timer(1.0).timeout
	
	EventBus.resume_vn.emit()
	queue_free()
