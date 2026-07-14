extends Node2D


func _ready() -> void:
	print("PIGEON_EMPIRE_STARTUP_OK")
	if DisplayServer.get_name() == "headless":
		get_tree().quit()
