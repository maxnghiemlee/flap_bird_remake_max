extends CharacterBody2D

enum State {TITLE, NOT_STARTED, ALIVE, DEAD, RESTARTING}

var curstate = State.NOT_STARTED

const UP = Vector2(0, -1)
const GRAV = 10
const FLAPSPD = 250
const MAXFALLSPD = 325

var score = 0
var curmotion = Vector2(250, 0)
var timeelapsed = 0

func switch_to(new_state: State):
	if new_state == State.ALIVE:
		curstate = State.ALIVE
		print("here we go. starting!")
	if new_state == State.DEAD:
		$AnimatedSprite2D.stop()
		curstate = State.DEAD
		print("dead")
	if new_state == State.RESTARTING:
		print("restarting")
		$CanvasLayer/MarginContainer.visible = true
	
func _physics_process(delta):
	if curstate == State.ALIVE:
		if curmotion.y < MAXFALLSPD:
			curmotion.y += GRAV 
		if curmotion.y > MAXFALLSPD:
			curmotion.y = MAXFALLSPD
			
		if Input.is_action_just_pressed("FLAP"):
			curmotion.y = -FLAPSPD
		#print(curmotion.y)
			
		if curmotion.y >= 0:
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.play("Falling")
			#print("playing falling")
		else:
			$AnimatedSprite2D.play("Flap")
			#print("playing flap")
		
		var collided = move_and_collide(curmotion * delta)
	elif curstate == State.NOT_STARTED:
		if Input.is_action_just_pressed("FLAP"):
			curmotion.y = - FLAPSPD
			switch_to(State.ALIVE)
	elif curstate == State.DEAD:
		timeelapsed += delta
		if timeelapsed >= 3:
			switch_to(State.RESTARTING)
	elif curstate == State.RESTARTING:
		if Input.is_action_just_pressed("clickedleft"):
			switch_to(State.NOT_STARTED)
		elif Input.is_action_just_pressed("clickedright"):
			switch_to(State.TITLE)
			$CanvasLayer/MarginContainer.visible = false
func _on_detect_point_area_entered(area):
	if area.name == "PointDetector":
		score += 1
		print(score)
	if area.name == "UpperWallDet" or area.name == "LowerWallDet":
		print("dead")
		switch_to(State.DEAD)

