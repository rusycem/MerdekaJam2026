
extends SceneTree

func _init():
	print("Has C++ singleton Time? ", Engine.has_singleton("Time"))
	print("Has C++ singleton Input? ", Engine.has_singleton("Input"))
	print("Has user singleton AudioManager? ", Engine.has_singleton("AudioManager"))
	quit()
