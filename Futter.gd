extends Node2D

var typ = "Futter"

var menge:float = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init():
	setze_menge()
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.modulate = Color(
		(randi()%128 + 64)/256.0*2, 
		(randi()%128 + 64)/256.0*2, 
		(randi()%128 + 64)/256.0*2);
	
	
	
func setze_menge(m:int = 0):
	if m == 0:
		m = (randi()%4) + 1 # 1 ... 4
	menge = m
	scale = Vector2(0.5,0.5)*sqrt(menge)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

