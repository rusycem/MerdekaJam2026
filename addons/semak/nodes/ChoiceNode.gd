# ChoiceNode.gd
@tool
extends GraphNode

signal option_removed(node_name: StringName, slot_index: int)

@onready var preview_label: Label = $PreviewLabel

var prompt_text: String = "What will you do?..."

func _ready() -> void:
	title = "Player Branch Choices"
	
	# Slot 0 (PreviewLabel): Left Input entry point
	set_slot_enabled_left(0, true)
	set_slot_type_left(0, 0)
	set_slot_color_left(0, Color.WHITE)
	set_slot_enabled_right(0, false)
	update_preview()

# Dynamically spawns a new choice text row
func add_choice_option(initial_text: String = "", initial_flag: String = "", hide_if_locked: bool = false) -> void:
	var option_index = get_child_count()
	
	var row = Label.new()
	row.name = "ChoiceRow_" + str(option_index)
	row.custom_minimum_size = Vector2(250, 0)
	row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.set_meta("text", initial_text)
	row.set_meta("condition", initial_flag)
	row.set_meta("hide_if_locked", hide_if_locked)
	
	refresh_choice_row(row)
	add_child(row)
	
	# Enable an outbound Right channel tracking port matching this choice row
	set_slot_enabled_left(option_index, false)
	set_slot_enabled_right(option_index, true)
	set_slot_type_right(option_index, 0)
	set_slot_color_right(option_index, Color.YELLOW)

func refresh_choice_row(row: Label) -> void:
	var text_val = row.get_meta("text")
	var condition_val = row.get_meta("condition")
	row.text = "➔ " + (text_val if text_val != "" else "[Empty Option]")
	if condition_val != "":
		row.text += " (Requires: " + condition_val + ")"
	size = Vector2.ZERO

func _remove_option(row: Control) -> void:
	var slot_index = row.get_index()
	option_removed.emit(name, slot_index)
	row.queue_free()
	await row.tree_exited
	_update_slots()
	size = Vector2.ZERO

func _update_slots() -> void:
	var total = get_child_count()
	for i in range(total):
		if i == 0:
			set_slot_enabled_left(0, true)
			set_slot_type_left(0, 0)
			set_slot_color_left(0, Color.WHITE)
			set_slot_enabled_right(0, false)
		else:
			set_slot_enabled_left(i, false)
			set_slot_enabled_right(i, true)
			set_slot_type_right(i, 0)
			set_slot_color_right(i, Color.YELLOW)
	
	# Disable the slot that previously belonged to the deleted row
	set_slot_enabled_left(total, false)
	set_slot_enabled_right(total, false)

func set_node_data(data: Dictionary) -> void:
	if data.has("position"):
		position_offset = Vector2(data["position"][0], data["position"][1])
	
	prompt_text = data.get("prompt", prompt_text)
	
	# Clear existing choices immediately
	for child in get_children():
		if child != preview_label:
			child.free()
			
	# Clean up dangling slots
	for i in range(1, get_child_count() + 10):
		set_slot_enabled_left(i, false)
		set_slot_enabled_right(i, false)
	
	# Add saved choices
	var choices = data.get("choices", [])
	for choice in choices:
		var text = choice.get("text", "")
		var condition = choice.get("condition", "")
		var hide = choice.get("hide_if_locked", false)
		add_choice_option(text, condition, hide)
		
	update_preview()

func get_node_data() -> Dictionary:
	var choices_list: Array[Dictionary] = []
	
	for child in get_children():
		if child != preview_label and child.has_meta("text"):
			choices_list.append({
				"text": child.get_meta("text"),
				"condition": child.get_meta("condition"),
				"hide_if_locked": child.get_meta("hide_if_locked")
			})
			
	return {
		"type": "choice_branch",
		"node_name": name,
		"position": [position_offset.x, position_offset.y],
		"prompt": prompt_text,
		"choices": choices_list,
		"next_nodes": []
	}

func update_preview() -> void:
	if not is_inside_tree() or not preview_label: return
	preview_label.text = prompt_text if prompt_text != "" else "[Empty Prompt]"
	size = Vector2.ZERO
