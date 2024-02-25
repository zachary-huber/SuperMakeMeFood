extends Node3D


func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("quit"):
		quitScene()
	if event.is_action_pressed("restart"):
		restartScene()

func restartScene(): # do some transition phase here (fade or blur or similar)
	get_tree().reload_current_scene()

func quitScene(): # gracefully transition to quitting state and perform necessary tasks
	get_tree().quit()
