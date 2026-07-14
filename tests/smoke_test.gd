extends SceneTree


func _initialize() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("Unable to load main scene")
		quit(1)
		return
	var instance := packed.instantiate()
	if instance == null:
		push_error("Unable to instantiate main scene")
		quit(1)
		return
	print("PIGEON_EMPIRE_SMOKE_OK")
	instance.free()
	quit(0)
