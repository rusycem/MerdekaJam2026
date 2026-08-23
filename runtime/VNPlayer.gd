extends CanvasLayer

signal narrative_finished

@export var story_tree: Resource

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

func _ready() -> void:
	hide_all()
	next_button.pressed.connect(_on_next_pressed)
	dice_continue_btn.pressed.connect(_on_dice_continue)
	
	# Auto-start if a tree was assigned in the Inspector!
	if story_tree:
		play()

func play(tree: Resource = null) -> void:
	if tree:
		story_tree = tree
	if not story_tree or not "graph_data" in story_tree:
		print("VNPlayer Error: Invalid or missing story tree!")
		return
		
	graph_data = story_tree.graph_data
	
	# Find Start Node
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
	if current_node_id == "" or not graph_data.has(current_node_id):
		print("VNPlayer: Reached end of narrative tree.")
		narrative_finished.emit()
		return
		
	var data = graph_data[current_node_id]
	var type = data["type"]
	
	if type == "start":
		current_node_id = data["next_node"]
		_process_node()
		
	elif type == "dialogue":
		_handle_dialogue(data)
		
	elif type == "choice_branch":
		_handle_choice(data)
		
	elif type == "dnd_check":
		_handle_dnd_check(data)
		
	elif type == "comment":
		pass

func _handle_dialogue(data: Dictionary) -> void:
	dialogue_panel.show()
	speaker_label.text = data.get("speaker", "")
	text_label.text = data.get("text", "")
	
	if data.has("set_flags") and data["set_flags"] != "":
		GameState.grant_flags(data["set_flags"])
		
	current_node_id = data.get("next_node", "")

func _on_next_pressed() -> void:
	_process_node()

func _handle_choice(data: Dictionary) -> void:
	choices_panel.show()
	choice_prompt_label.text = data.get("prompt", "")
	
	# Clear old choices
	for child in choices_container.get_children():
		child.queue_free()
		
	var choices = data.get("choices", [])
	var next_nodes = data.get("next_nodes", [])
	
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = choice.get("text", "")
		
		var condition = choice.get("condition", "")
		var hide_if_locked = choice.get("hide_if_locked", false)
		var can_select = true
		
		if condition != "":
			var conditions = condition.split(",")
			for cond in conditions:
				if not GameState.has_flag(cond.strip_edges()):
					can_select = false
					break
					
		if not can_select:
			if hide_if_locked:
				continue
			else:
				btn.disabled = true
				btn.text += " (Locked)"
				
		var target_node = ""
		if i < next_nodes.size():
			target_node = next_nodes[i]
			
		btn.pressed.connect(func():
			current_node_id = target_node
			_process_node()
		)
		choices_container.add_child(btn)

var dice_target_node = ""

func _handle_dnd_check(data: Dictionary) -> void:
	dice_panel.show()
	var stat = data.get("target_stat", "STR")
	var dc = data.get("dc_value", 10)
	
	var roll = randi() % 20 + 1
	var mod = GameState.get_stat_modifier(stat)
	var total = roll + mod
	
	var result_text = "Rolling %s Check...\n" % stat
	result_text += "d20 Roll: %d\n" % roll
	result_text += "%s Modifier: %+d\n" % [stat, mod]
	result_text += "Total: %d vs DC %d\n\n" % [total, dc]
	
	if total >= dc:
		result_text += "[color=green]SUCCESS![/color]"
		dice_target_node = data.get("next_pass", "")
	else:
		result_text += "[color=red]FAILURE![/color]"
		dice_target_node = data.get("next_fail", "")
		
	dice_result_label.text = result_text

func _on_dice_continue() -> void:
	current_node_id = dice_target_node
	_process_node()
