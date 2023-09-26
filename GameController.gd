extends Node2D

export(PackedScene) var futter_scene:PackedScene

var groesse = 10

func _ready():
	$FutterTimer.connect("timeout", self, "_on_FutterTimer_timeout")
	$Wurm.connect("geschrumpft", self, "neues_futter")
	
	for i in 10000:
		neues_futter()

func neues_futter(pos:Vector2 = Vector2(0,0)):
	var futter = futter_scene.instance()
	futter.position = pos
	while futter.position == Vector2(0,0) or futter.position.length() > 3850:
		futter.position = Vector2(randi()%8192 - 4096, randi()%8192 - 4096)
	add_child(futter)

func _on_FutterTimer_timeout():
	neues_futter()

func _process(delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	$"/root/HUD/laenge".text = String(int($Wurm.laenge))
