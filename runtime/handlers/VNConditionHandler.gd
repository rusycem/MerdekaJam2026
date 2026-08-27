class_name VNConditionHandler extends RefCounted

static func handle(player: Node, data: Dictionary) -> void:
	var cond = data.get("condition", "")
	if GameState.evaluate_condition(cond):
		player.current_node_id = data.get("next_true", "")
	else:
		player.current_node_id = data.get("next_false", "")
		
	player._process_node()

