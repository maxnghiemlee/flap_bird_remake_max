extends Node

enum State {TITLE, NOT_STARTED, ALIVE, DEAD, RESTARTING}

var curstate = State.NOT_STARTED
var switchedstate = State.NOT_STARTED
var needtoswitch = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if curstate == State.RESTARTING:
		$MarginContainer.visible = true
		if Input.is_action_just_pressed("clickedleft"):
			$MarginContainer.visible = false
			switchedstate = State.NOT_STARTED
		elif Input.is_action_just_pressed("clickedright"):
			switchedstate = State.TITLE
