class_name SaveSlot
extends Resource

@export var slot_id: int = 0
@export var timestamp: String = ""

# Persistent narrative footprint
@export var current_node_id: String = ""
@export var unlocked_flags: Array[String] = []

# Relationships mapping (e.g. "Principal" -> 10)
@export var relationships: Dictionary = {}
