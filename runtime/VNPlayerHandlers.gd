class_name VNPlayerHandlers extends RefCounted

const VNDialogueHandler = preload("res://runtime/handlers/VNDialogueHandler.gd")
const VNChoiceHandler = preload("res://runtime/handlers/VNChoiceHandler.gd")
const VNDnDHandler = preload("res://runtime/handlers/VNDnDHandler.gd")
const VNCommandHandler = preload("res://runtime/handlers/VNCommandHandler.gd")
const VNActorHandler = preload("res://runtime/handlers/VNActorHandler.gd")
const VNConditionHandler = preload("res://runtime/handlers/VNConditionHandler.gd")

static func handle_dialogue(player: Node, data: Dictionary) -> void:
	VNDialogueHandler.handle(player, data)

static func handle_choice(player: Node, data: Dictionary) -> void:
	VNChoiceHandler.handle(player, data)

static func handle_dnd_check(player: Node, data: Dictionary) -> void:
	VNDnDHandler.handle(player, data)

static func handle_command(player: Node, data: Dictionary) -> void:
	VNCommandHandler.handle(player, data)

static func handle_actor(player: Node, data: Dictionary) -> void:
	VNActorHandler.handle(player, data)

static func handle_condition(player: Node, data: Dictionary) -> void:
	VNConditionHandler.handle(player, data)
