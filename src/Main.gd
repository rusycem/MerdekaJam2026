# Main.gd
extends Node

@onready var level_container = $LevelContainer
@onready var menu_container = $UI/MenuContainer
@onready var fader = $TransitionLayer/ColorRect

@export_file("*.tscn") var starting_level: String

var cached_vn: Node = null

func _ready() -> void:
	EventBus.scene_change_requested.connect(_on_scene_change_requested)
	EventBus.play_visual_novel.connect(_on_play_visual_novel)
	EventBus.vn_ended.connect(_on_vn_ended)
	EventBus.start_minigame.connect(_on_start_minigame)
	EventBus.start_hub.connect(_on_start_hub)
	EventBus.resume_vn.connect(_on_resume_vn)
	fader.modulate.a = 0.0 
	
	# Start the game by loading the Main Menu into the MenuContainer
	_on_scene_change_requested(starting_level, true)

func _on_scene_change_requested(scene_path: String, is_menu: bool) -> void:
	# 1. Fade to black
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.5)
	await tween.finished

	# 2. Clear out EVERYTHING (both old menus and old levels)
	for child in level_container.get_children():
		child.queue_free()
	for child in menu_container.get_children():
		child.queue_free()

	# 3. Load the new scene
	var new_scene = load(scene_path)
	if new_scene:
		var instance = new_scene.instantiate()
		
		# 4. Route it to the correct container based on the 'is_menu' flag
		if is_menu:
			menu_container.add_child(instance)
		else:
			level_container.add_child(instance)

	# 5. Fade back in
	tween = create_tween()
	tween.tween_property(fader, "modulate:a", 0.0, 0.5)

func _on_play_visual_novel(tres_path: String) -> void:
	if cached_vn:
		cached_vn.queue_free()
		cached_vn = null
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	for child in level_container.get_children():
		child.queue_free()
	for child in menu_container.get_children():
		child.queue_free()
		
	var vn_scene = load("res://runtime/VNPlayer.tscn")
	var instance = vn_scene.instantiate()
	level_container.add_child(instance)
	
	# Try to load the requested tree and pass it to VNPlayer
	var story_tree = load(tres_path)
	if story_tree:
		instance.play(story_tree)
	else:
		push_error("Failed to load VN tree at: " + tres_path)
		
	tween = create_tween()
	tween.tween_property(fader, "modulate:a", 0.0, 0.5)

func _on_vn_ended() -> void:
	# When VN is done, return to the Dorm!
	_on_scene_change_requested("res://src/Dorm.tscn", false)

func _on_start_minigame(minigame_id: String) -> void:
	var path = ""
	if minigame_id == "clicker":
		path = "res://minigames/ClickerGame.tscn"
	elif minigame_id == "error_hunt" or minigame_id == "errorhunt" or minigame_id == "english":
		path = "res://minigames/ErrorHuntGame.tscn"
	# add more minigames here
	
	if path != "":
		var mg_scene = load(path)
		if mg_scene:
			var instance = mg_scene.instantiate()
			# Add minigame ON TOP of the VNPlayer so the VNPlayer sits paused underneath
			menu_container.add_child(instance)
		else:
			push_error("Main.gd: Could not load minigame at " + path)
			EventBus.minigame_finished.emit() # Fail safe resume
	else:
		push_error("Main.gd: Unknown minigame id: " + minigame_id)
		EventBus.minigame_finished.emit() # Fail safe resume


func _on_start_hub() -> void:
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	for child in level_container.get_children():
		if child.name == "VNPlayer" or child.has_method("play"):
			level_container.remove_child(child)
			cached_vn = child
		else:
			child.queue_free()
			
	for child in menu_container.get_children():
		child.queue_free()
		
	var hub_scene = load("res://src/ActivityPhase.tscn")
	var instance = hub_scene.instantiate()
	level_container.add_child(instance)
	
	tween = create_tween()
	tween.tween_property(fader, "modulate:a", 0.0, 0.5)

func _on_resume_vn() -> void:
	var tween = create_tween()
	tween.tween_property(fader, "modulate:a", 1.0, 0.5)
	await tween.finished

	for child in level_container.get_children():
		child.queue_free()
	for child in menu_container.get_children():
		child.queue_free()
		
	if cached_vn:
		level_container.add_child(cached_vn)
		if cached_vn.has_method("play"):
			cached_vn.play()
		cached_vn = null
	else:
		if GameState.current_chapter_uid != "":
			_on_play_visual_novel(GameState.current_chapter_uid)
		else:
			push_error("Main.gd: Cannot resume VN because current_chapter_uid is empty!")
			
	tween = create_tween()
	tween.tween_property(fader, "modulate:a", 0.0, 0.5)
