extends CharacterBody2D

enum State {TITLE, NOT_STARTED, ALIVE, DEAD, RESTARTING, WAIT_RESPONSE}

var curstate = State.TITLE
var toswitch = false
var nextstate

const UP = Vector2(0, -1)
const GRAV = 10
const FLAPSPD = 250
const MAXFALLSPD = 325

var score = 0
var curmotion = Vector2(250, 0)
var timeelapsed = 0

func switch_to(new_state: State):
	
	if new_state != State.RESTARTING:
		$CanvasLayer/MarginContainer.visible = false
	if new_state == State.NOT_STARTED:
		toswitch = false
		curstate = State.NOT_STARTED
		self.position.x = 0
		self.position.y = 0
	
	if new_state == State.ALIVE:
		curstate = State.ALIVE
		print("here we go. starting!")
	if new_state == State.DEAD:
		$AnimatedSprite2D.stop()
		curstate = State.DEAD
		print("dead")
	if new_state == State.RESTARTING:
		#print("restarting")
		$CanvasLayer/MarginContainer.visible = true
		switch_to(State.WAIT_RESPONSE)
	if new_state == State.WAIT_RESPONSE:
		curstate = State.WAIT_RESPONSE
		print("in waitrepson")
	
func _physics_process(delta):
	timeelapsed += delta
	if curstate == State.TITLE:
		switch_to(State.NOT_STARTED)
	
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
	if curstate == State.NOT_STARTED:
		if Input.is_action_just_pressed("FLAP"):
			curmotion.y = - FLAPSPD
			switch_to(State.ALIVE)
	if curstate == State.DEAD:
		timeelapsed += delta
		if timeelapsed >= 1:
			timeelapsed = 0
			print('switching to restarting')
			switch_to(State.RESTARTING)
	if curstate == State.WAIT_RESPONSE:
		if Input.is_action_just_pressed("clickedleft"):
			print("left clicked")
			toswitch = true
			nextstate = State.NOT_STARTED
			timeelapsed = 0
		if Input.is_action_just_pressed("clickedright"):
			print("right clicked")
			toswitch = true
			nextstate = State.TITLE
		if timeelapsed >= 0.2 and toswitch:
			print(timeelapsed)
			timeelapsed = 0
			switch_to(nextstate)
func _on_detect_point_area_entered(area):
	if area.name == "PointDetector":
		score += 1
		print(score)
	if area.name == "UpperWallDet" or area.name == "LowerWallDet":
		print("dead")
		switch_to(State.DEAD)

