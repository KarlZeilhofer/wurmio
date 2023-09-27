
# Wurmio
# 
# Wurmio ist eine Fortführung von Slither.io
# Wurmio wurde entwickelt mittels Godot Engine und Inkscape
# 
# Features:
#   * Lenken
#   * Sprinten
#   * kreisrunde Arena mit roter Begrenzung
#   * leuchtendes Futter
# 
# Todos:
#   * Staubsaugereffekt beim Fressen
#   * KI-Gegner
#   * Netzwerkfähigkeit über WebSocket
#   * Lobby/Gameover
#   * List der größten Würmer




extends Node2D

export(PackedScene) var futter_scene:PackedScene
export(PackedScene) var wurm_scene:PackedScene

var groesse = 10
var zoom:float = 2

var ki_wuermer = []
var futter_liste = []

var World_Size = 4096 # Radius


func _ready():
	$Background.rect_position = Vector2(-World_Size, -World_Size)
	$Background.rect_size = Vector2(2*World_Size-1, 2*World_Size-1)
	$Background/Arena.rect_scale = Vector2(World_Size/4096.0*2, World_Size/4096.0*2)
	
	$FutterTimer.connect("timeout", self, "_on_FutterTimer_timeout")
	$Wurm.connect("geschrumpft", self, "neues_futter")
	
	for i in 3000:
		neues_futter()
	
	for i in 10:
		var wurm = wurm_scene.instance()
		wurm.spieler = $Wurm
		wurm.connect("geschrumpft", self, "neues_futter")
		add_child(wurm)
		ki_wuermer.append(wurm)
	
	$Wurm/Kopf/Camera2D.current = true
	$Wurm.ki = false
	
func neues_futter(pos:Vector2 = Vector2(0,0), menge:int=0):
	var futter = futter_scene.instance()
	if menge > 0:
		futter.setze_menge(menge)
	futter.position = pos
	while futter.position == Vector2(0,0) or futter.position.length() > 3850*World_Size/4096.0:
		futter.position = Vector2(randi()%(2*World_Size) - World_Size, randi()%(2*World_Size) - World_Size)
	add_child(futter)
	futter_liste.append(futter)

func _on_FutterTimer_timeout():
	pass

func _process(delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	$"/root/HUD/laenge".text = String(int($Wurm.laenge))
	


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			zoom /= 1.1
			$Wurm/Kopf/Camera2D.zoom = Vector2(zoom,zoom)
			print("Zoom = " + String(zoom))
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			zoom *= 1.1
			$Wurm/Kopf/Camera2D.zoom = Vector2(zoom,zoom)
			print("Zoom = " + String(zoom))
	
	
