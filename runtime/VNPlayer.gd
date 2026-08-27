extends CanvasLayer

signal narrative_finished

@export var story_tree: Resource

@onready var background_rect = $BackgroundRect
@onready var background_rect_2 = $BackgroundRect2
@onready var blip_player = $BlipPlayer
@onready var voice_player = $VoicePlayer
@onready var character_container = $CharacterContainer

@onready var ui_control = $UI

@onready var dialogue_panel = $UI/DialoguePanel
@onready var speaker_label  = $UI/DialoguePanel/VBoxContainer/SpeakerLabel
@onready var text_label     = $UI/DialoguePanel/VBoxContainer/TextLabel
@onready var next_button    = $UI/DialoguePanel/VBoxContainer/NextButton

@onready var choices_panel 		 = $UI/ChoicesPanel
@onready var choice_prompt_label = $UI/ChoicesPanel/VBoxContainer/PromptLabel
@onready var choices_container   = $UI/ChoicesPanel/VBoxContainer/ChoicesContainer

@onready var dice_panel        = $UI/DicePanel
@onready var dice_result_label = $UI/DicePanel/VBoxContainer/ResultLabel
@onready var dice_continue_btn = $UI/DicePanel/VBoxContainer/ContinueBtn

var graph_data: Dictionary = {}
var current_node_id: String = ""
var current_node_type: String = ""
var last_visible_characters: int = -1
var current_blip_pitch: float = 1.0
var dialogue_history: Array[Dictionary] = []
var is_waiting: bool = false
var backlog_ui: Node
var active_profiles: Dictionary = {}
var type_tween: Tween
var auto_advance_delay: float = 0.8
var _auto_advance_pending: bool = false
var _auto_advance_time: float = 0.0

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("toggle_ui")) :
		_toggle_ui_visibility()	

	elif (Input.is_action_just_pressed("toggle_auto_next")) :
		_toggle_auto_next()

	elif (Input.is_action_just_pressed("next")) :
		_on_next_pressed()

	elif (Input.is_action_just_pressed("toggle_transcript")) :
		if backlog_ui and backlog_ui.visible:
			backlog_ui.close()
		elif backlog_ui:
			backlog_ui.open()


	if (GameSettings.auto_next_enabled) :
		if current_node_type == "dialogue":
			if (type_tween and type_tween.is_running()) or voice_player.playing:
				_auto_advance_pending = false
			else:
				if not _auto_advance_pending:
					_auto_advance_pending = true
					_auto_advance_time = auto_advance_delay
				else:
					_auto_advance_time -= _delta
					if _auto_advance_time <= 0.0:
						_auto_advance_pending = false
						_on_next_pressed()
	else:
		_auto_advance_pending = false


	if type_tween and type_tween.is_running() and not voice_player.playing:
		if text_label.visible_characters > last_visible_characters:
			last_visible_characters = text_label.visible_characters
			# Play blip every 2 characters for pacing
			if last_visible_characters % 2 == 0 and blip_player.stream:
				blip_player.pitch_scale = current_blip_pitch + randf_range(-0.05, 0.05)
				blip_player.play()


func _ready() -> void:
	hide_all()
	backlog_ui = preload("res://src/UI/BacklogUI.gd").new(self)
	add_child(backlog_ui)
	next_button.pressed.connect(_on_next_pressed)
	dice_continue_btn.pressed.connect(_on_dice_continue)
	
	if not blip_player.stream:
		# Generate a procedural blip
		var blip = AudioStreamWAV.new()
		blip.format = AudioStreamWAV.FORMAT_16_BITS
		blip.mix_rate = 44100
		blip.stereo = false
		var blip_data = PackedByteArray()
		for i in range(44100 * 0.05):
			var t = i / 44100.0
			var sample = int(sin(t * 2.0 * PI * 800.0) * 16000.0 * exp(-t * 30.0))
			blip_data.append(sample & 0xFF)
			blip_data.append((sample >> 8) & 0xFF)
		blip.data = blip_data
		blip_player.stream = blip
	blip_player.bus = "Voice"
	voice_player.bus = "Voice"
		
	# Auto-start only if this scene is run directly (F6) or not managed by Main
	if story_tree and get_parent() == get_tree().root:
		play()



func play(tree: Resource = null) -> void:
	if tree:
		story_tree = tree
	if not story_tree or not "graph_data" in story_tree:
		print("VNPlayer Error: Invalid or missing story tree!")
		return
		
	graph_data = story_tree.graph_data
	GameState.current_chapter_uid = story_tree.resource_path
	
	if GameState.resume_node_id != "":
		current_node_id = GameState.resume_node_id
		GameState.resume_node_id = "" # Clear it so it doesn't loop
		print("VNPlayer: Resuming from node ", current_node_id)
		_process_node()
		return
	
	# Find Start Node normally
	current_node_id = ""
	for node_id in graph_data.keys():
		if graph_data[node_id]["type"] == "start":
			current_node_id = node_id
			break
			
	if current_node_id == "":
		print("VNPlayer Error: No Start Node found!")
		return
		
	_process_node()


func add_to_history(speaker: String, text: String, voice_uid: String) -> void:
	dialogue_history.append({
		"speaker": speaker,
		"text": text,
		"voice_uid": voice_uid
	})

func _toggle_ui_visibility() -> void :
	ui_control.visible = !ui_control.visible


func _toggle_auto_next() -> void :
	GameSettings.auto_next_enabled = !GameSettings.auto_next_enabled


func hide_all() -> void:
	dialogue_panel.hide()
	choices_panel.hide()
	dice_panel.hide()


func _process_node() -> void:
	hide_all()
	
	# Godot 4 dictionaries often use StringName for keys in exported resources
	var sn_id = StringName(current_node_id)
	var str_id = String(current_node_id)
	
	var actual_id = ""
	if graph_data.has(sn_id):
		actual_id = sn_id
	elif graph_data.has(str_id):
		actual_id = str_id
		
	if actual_id == "":
		print("VNPlayer: Reached end of narrative tree. (Node not found: ", current_node_id, ")")
		current_node_type = ""
		if EventBus.has_signal("vn_ended"):
			EventBus.vn_ended.emit()
		return
		
	var data = graph_data[actual_id]
	var type = data["type"]
	current_node_type = type
	
	if type == "start":
		current_node_id = data["next_node"]
		_process_node()
		
	elif type == "dialogue":
		VNPlayerHandlers.handle_dialogue(self, data)
		
	elif type == "choice_branch":
		VNPlayerHandlers.handle_choice(self, data)
		
	elif type == "dnd_check":
		VNPlayerHandlers.handle_dnd_check(self, data)
		
	elif type == "command":
		VNPlayerHandlers.handle_command(self, data)
		
	elif type == "condition":
		VNPlayerHandlers.handle_condition(self, data)
		
	elif type == "actor":
		VNPlayerHandlers.handle_actor(self, data)
		
	elif type == "comment":
		pass


func _on_next_pressed() -> void:
	if is_waiting: return
	if type_tween and type_tween.is_running():
		type_tween.kill()
		text_label.visible_characters = -1
		if voice_player.playing:
			voice_player.stop()
	else:
		if voice_player.playing:
			voice_player.stop()
		_process_node()


var dice_target_node = ""
func _on_dice_continue() -> void:
	current_node_id = dice_target_node
	_process_node()
