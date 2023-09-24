extends Node2D

var wuermer:Array

func _ready():
	$WachstumsTimer.connect("timeout", self, "_on_WachstumsTimer_timeout")


func _on_WachstumsTimer_timeout():
	# hier muss der wurm noch wachsen. 
	print("Wurmio wachse!")
	$Wurm.wachsen()

func _process(delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
