extends Node2D

var typ = "Wurm"
onready var WS = $"/root/GameController".World_Size

signal geschrumpft(schwanzposition)

export(PackedScene) var body_scene:PackedScene

export var schnelligkeit1:float = 300 # pixel pro Sekunde
export var schnelligkeit2:float = 600 # pixe pro Sekunde
export var winkelgeschwindigkeit:float = 0.8*PI # Radiant pro Sekunde


var schnelligkeit:float = 0
var kot_menge:float = 0

onready var kopf = $Kopf

var bodies:Array
const LaengeMin = 10
var laenge = LaengeMin
var dicke:float = 1

var ki = true # Ist der Wurm eine künstliche Inteligenz?
var spieler # Referenz auf den einzigen Wurm, der nicht vom Computer gesteuert wird

var gestorben = false

# nächstes Futter bleibt solange aktiv, bis sich die Position verändert hat
# (gefressenes Futter taucht in der Welt sofort wieder wo auf)
# dient als Ziel für die KI
var alte_futter_pos:Vector2 = Vector2(0,0)
var futter_pos = null
var reisezeit:float = 0

func _init():
	print("Wurmio V23.0.0")

func _ready():
	kopf.position = Vector2(randi()%WS-WS/2, randi()%WS-WS/2)
	
	while bodies.size() < laengeZuBodies(laenge):
		wachsen()

func _process(delta):
	if gestorben:
		return
	
	var links = false
	var rechts = false
	var sprint = false
	
	if ki: 
		var futter_liste = $"/root/GameController".futter_liste
		
		
		if alte_futter_pos != futter_pos or reisezeit < 0:
			
			var i = randi()%futter_liste.size()
			while is_instance_valid(futter_liste[i]) == false:
				i = randi()%futter_liste.size()
			futter_pos = futter_liste[i].position
			reisezeit = (randi()%200)/10.0
			alte_futter_pos = futter_pos
		
		reisezeit -= delta
		
		var rechts_vektor = Vector2(1,0)
		var richtungs_vektor_kopf = rechts_vektor.rotated(kopf.rotation)
		var richtungs_vektor_zum_spieler = spieler.kopf.position - kopf.position
		var richtungs_vektor_zum_futter = futter_pos - kopf.position
		
		var r1 = richtungs_vektor_kopf.normalized()
		# var r2 = richtungs_vektor_zum_spieler.normalized()
		var r2 = richtungs_vektor_zum_futter.normalized()
		
		var inprod = r1.x*r2.x + r1.y*r2.y
		
		if inprod < -0.1:
			links = true
		if inprod > 0.1:
			rechts = true
		
	else:
		if Input.is_action_pressed("ui_left"):
			links = true
		if Input.is_action_pressed("ui_right"):
			rechts = true
		if Input.is_action_pressed("ui_select") or Input.is_action_pressed("ui_up"):
			sprint = true

	if links:
		# Move as long as the key/button is pressed.
		kopf.rotation -= winkelgeschwindigkeit*delta/dicke
	if rechts:
		# Move as long as the key/button is pressed.
		kopf.rotation += winkelgeschwindigkeit*delta/dicke
	if sprint:
		schnelligkeit = schnelligkeit2
		modulate = Color(2,2,2)
		
		var delta_kot = 10*delta
		if laenge < LaengeMin+delta_kot:
			delta_kot = clamp(delta_kot, 0, laenge - LaengeMin)
		
		kot_menge += delta_kot
		laenge = laenge - delta_kot # Schrumpfen beim schnell fahren
		laenge = clamp(laenge, LaengeMin, 1e9)
		
		if kot_menge > 2: 
			emit_signal("geschrumpft", bodies.back().position, 2)
			kot_menge -= 2
		
		if laengeZuBodies(laenge) < bodies.size() :
			schrumpfen()
		if laenge <= LaengeMin:
			schnelligkeit = schnelligkeit1
			modulate = Color(1.2,1.2,1.2)
	else:
		schnelligkeit = schnelligkeit1
		modulate = Color(1.2,1.2,1.2)
		
		
	var geschwindigkeit:Vector2 = Vector2.UP.rotated(kopf.rotation) * schnelligkeit
	kopf.position += geschwindigkeit * delta
	if kopf.position.length() > WS/4096.0*3900:
		kopf.position = kopf.position.normalized()*(WS/4096.0*3900)

	#$Kopf/Camera2D.offset = kopf.position
	
	bewegen(delta)
	
	#print(String(1/delta) + " fps, " + String(bodies.size()) + " bodies")


func bewegen(delta):
	# Kopf hat schon seine neue Position bekommen. 

	if bodies.empty():
		return
		
	var segmentlaenge = dicke*64*0.3 # 70% Überdeckung
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
	
	dicke_berechnen()
	for b in bodies:
		b.scale = Vector2(dicke,dicke)
	$Kopf.scale = Vector2(dicke,dicke)

# s*****r.io:
# Länge -> Dicke (relativ zu Hintergrund Ecke-Ecke)
#	10 -> 0.195
#	50 -> 0.201
#	372 -> 0.242
# 	1180 -> 0.320
#	3586 -> 0.462
#	5330 -> 0.555
func dicke_berechnen():
	if laenge < 300:
		dicke = (laenge-10)*(0.234-0.195)/290+0.195
	else:
		dicke = sqrt(sqrt(laenge/10))/10
	dicke = dicke / 0.195

func schrumpfen():
	bodies.back().queue_free()
	bodies.remove(bodies.size()-1)

# s*****r.io:
	# Länge -> Segmente (inkl. Kopf)
	# 10 -> 9
	# 50 -> 21
	# 372 -> 65
	# 392 -> 68
	# 1180 -> 112
func laengeZuBodies(l):
	return int(sqrt(l*10))-1
	
func sterben():
	print("  ich sterbe")
	if gestorben:
		return
	else:
		var l = laenge
		while l > 2:
			var furz = randi()%4+1
			var pos = bodies[randi()%bodies.size()].position
			pos += Vector2(randi()%int(64*dicke), randi()%int(64*dicke))
			emit_signal("geschrumpft", pos, furz)
			l -= furz
		#gestorben = true
		
		kopf.position = Vector2(randi()%WS, randi()%WS)
		laenge = LaengeMin
		while laengeZuBodies(laenge) < bodies.size():
			schrumpfen()
		bewegen(0)
	pass


func _on_Kopf_area_entered(area):
	# dies ist eine valide annahme
	# Futter liegt auf Layer 3
	if area.typ == "Futter":
		var futter = area 
		#print(futter.menge)
		laenge = laenge + futter.menge
		
		while laengeZuBodies(laenge) > bodies.size()+1:
			wachsen()
		
		if $"/root/GameController".futter_liste.size() < 3000:
			futter.position = Vector2(randi()%(2*WS) - WS, randi()%(2*WS) - WS)
			while futter.position == Vector2(0,0) or futter.position.length() > 3850*WS/4096.0:
				futter.position = Vector2(randi()%(2*WS) - WS, randi()%(2*WS) - WS)
			futter.setze_menge(randi()%4+1)
		else:
			futter.queue_free()
	
	if area.typ == "WurmBody":
		var body = area
		#print(body.get_parent())
		if body.get_parent() != self:
			sterben()

	pass # Replace with function body.

