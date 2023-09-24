extends Node2D



var menge:float = 1
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init():
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.modulate = Color(
		(randi()%256)/256.0*2, 
		(randi()%256)/256.0*2, 
		(randi()%256)/256.0*2);
	
	menge = (randi()%91)/10.0 + 1 # 1.0 ... 10.0
	scale = Vector2(0.3,0.3)*sqrt(menge)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

