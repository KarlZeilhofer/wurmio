extends Node2D

export(PackedScene) var futter_scene:PackedScene

var groesse = 10

func _ready():
	$FutterTimer.connect("timeout", self, "_on_FutterTimer_timeout")
	
	for i in 1000:
		neues_futter()

func neues_futter():
	var futter = futter_scene.instance()
	futter.position = Vector2(randi()%8192 - 4096, randi()%8192 - 4096)
	add_child(futter)

func _on_FutterTimer_timeout():
	neues_futter()

func _process(delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
