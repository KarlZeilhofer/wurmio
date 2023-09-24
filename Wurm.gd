extends Node2D

export(PackedScene) var body_scene:PackedScene

export var schnelligkeit1:float = 300 # pixel pro Sekunde
export var schnelligkeit2:float = 600 # pixe pro Sekunde
var schnelligkeit:float = 0
onready var kopf = $Kopf
var winkelgeschwindigkeit:float = 0.8*PI # Radiant pro Sekunde


var screen_size:Vector2
var bodies:Array

func _init():
	print("Hello World")

func _ready():
	screen_size = get_viewport_rect().size
	for i in 20:
		wachsen()

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		# Move as long as the key/button is pressed.
		kopf.rotation -= winkelgeschwindigkeit*delta
	if Input.is_action_pressed("ui_right"):
		# Move as long as the key/button is pressed.
		kopf.rotation += winkelgeschwindigkeit*delta
	if Input.is_action_pressed("ui_select") or Input.is_action_pressed("ui_up"):
		schnelligkeit = schnelligkeit2
	else:
		schnelligkeit = schnelligkeit1
		
	var geschwindigkeit:Vector2 = Vector2.UP.rotated(kopf.rotation) * schnelligkeit
	kopf.position += geschwindigkeit * delta
#	kopf.position.x = clamp(kopf.position.x, 0, screen_size.x)
#	kopf.position.y = clamp(kopf.position.y, 0, screen_size.y)
	
	bewegen(delta)
	
	#print(String(1/delta) + " fps, " + String(bodies.size()) + " bodies")


func bewegen(delta):
	# Kopf hat schon seine neue Position bekommen. 

	if bodies.empty():
		return
		
	var segmentlaenge = 16
	# Vektor von body_0 nach Kopf:
	var r:Vector2
	
	# bewege das erste Segment nach dem Kopf:
	r = kopf.position - bodies[0].position
	if r.length() > segmentlaenge:
		r = r.normalized()*segmentlaenge
		bodies[0].position = kopf.position - r; 
		
	# bewege alle Zwischensegmente vom Schwanz bis zum Kopf
	# mit gewichteter Richtung
	var k2 = 0.4 # Gewicht für Richtung r2 (Schub)
	
	for i in range(1, bodies.size()-1):
		var r2 = bodies[i].position - bodies[i+1].position
		r2 = r2.normalized()
		var tempPos:Vector2 = bodies[i].position + r2*schnelligkeit*delta*k2
		r = bodies[i-1].position - tempPos
		
		if r.length() > segmentlaenge:
			r = r.normalized()*segmentlaenge
			bodies[i].position = bodies[i-1].position - r;
			
	# bewege das Schwanzsegment:
	r =  bodies[bodies.size()-2].position - bodies[bodies.size()-1].position
	if r.length() > segmentlaenge:
		r = r.normalized()*segmentlaenge
		bodies[bodies.size()-1].position = bodies[bodies.size()-2].position - r; 
		



func wachsen():
	var body = body_scene.instance()
	body.visible = true
	body.z_index = 1000-bodies.size()
	
	if bodies.size() == 0:
		body.position = kopf.position
	else:
		body.position = bodies.back().position
	
	bodies.append(body)
	add_child(body)
