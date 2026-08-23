extends CanvasLayer

signal narrative_finished

@export var story_tree: Resource

@onready var background_rect = $BackgroundRect
@onready var background_rect_2 = $BackgroundRect2
@onready var blip_player = $BlipPlayer
@onready var voice_player = $VoicePlayer
@onready var character_container = $CharacterContainer

@onready var dialogue_panel = $DialoguePanel
@onready var speaker_label = $DialoguePanel/VBoxContainer/SpeakerLabel
@onready var text_label = $DialoguePanel/VBoxContainer/TextLabel
@onready var next_button = $DialoguePanel/VBoxContainer/NextButton

@onready var choices_panel = $ChoicesPanel
@onready var choice_prompt_label = $ChoicesPanel/VBoxContainer/PromptLabel
@onready var choices_container = $ChoicesPanel/VBoxContainer/ChoicesContainer

@onready var dice_panel = $DicePanel
@onready var dice_result_label = $DicePanel/VBoxContainer/ResultLabel
@onready var dice_continue_btn = $DicePanel/VBoxContainer/ContinueBtn

var graph_data: Dictionary = {}
var current_node_id: String = ""
var last_visible_characters: int = -1
var current_blip_pitch: float = 1.0
var active_profiles: Dictionary = {}

func _process(_delta: float) -> void:
	if type_tween and type_tween.is_running() and not voice_player.playing:
		if text_label.visible_characters > last_visible_characters:
			last_visible_characters = text_label.visible_characters
			# Play blip every 2 characters for pacing
			if last_visible_characters % 2 == 0 and blip_player.stream:
				blip_player.pitch_scale = current_blip_pitch + randf_range(-0.05, 0.05)
				blip_player.play()


func _ready() -> void:
	hide_all()
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
		if EventBus.has_signal("vn_ended"):
			EventBus.vn_ended.emit()
		return
		
	var data = graph_data[actual_id]
	var type = data["type"]
	
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

var type_tween: Tween

func _on_next_pressed() -> void:
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
