extends CharacterBody2D

enum State {NOT_STARTED, ALIVE, DEAD, RESTARTING, WAIT_RESPONSE}

var curstate = State.NOT_STARTED
var toswitch = false
var nextstate
var Wall = preload("res://wall.tscn")


const UP = Vector2(0, -1)
const GRAV = 20
const FLAPSPD = 350
const MAXFALLSPD = 400

var score = 0
var curmotion = Vector2(400, 0)
var timeelapsed = 0

func switch_to(new_state: State):
	get_parent().get_node("DeathThing/MarginContainer").visible = false
	if new_state == State.RESTARTING or new_state == State.WAIT_RESPONSE:
		get_parent().get_node("DeathThing/MarginContainer").visible = true
	if new_state == State.NOT_STARTED:
		curstate = State.NOT_STARTED
		get_tree().reload_current_scene()
		get_parent().get_node("PointCounter/MarginContainer/HBoxContainer/Label").text = 'Score: ' + str(score)
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
		curstate = State.RESTARTING
		print("should display textbox")
		switch_to(State.WAIT_RESPONSE)
	if new_state == State.WAIT_RESPONSE:
		curstate = State.WAIT_RESPONSE
		print("in waitrepson")
	
func _physics_process(delta):
	timeelapsed += delta
	if curstate == State.ALIVE:
		if self.position.y > 400:
			curmotion.y = 0
		if self.position.y < 400 and curmotion.y < MAXFALLSPD:
			curmotion.y += GRAV 
		if curmotion.y > MAXFALLSPD:
			curmotion.y = MAXFALLSPD
		if Input.is_action_just_pressed("FLAP"):
			print("flap tried. position: ", self.position.y)
			if (self.position.y > -300):
				print("flapped. position: ", self.position.y)
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
		if timeelapsed >= 0.2 and toswitch:
			print(timeelapsed)
			timeelapsed = 0
			switch_to(nextstate)
func _on_detect_point_area_entered(area):
	if area.name == "PointDetector":
		score += 1
		if score > Globals.highscore:
			Globals.highscore = score
		print(score)
		get_parent().get_node("PointCounter/MarginContainer").visible = true
		get_parent().get_node("PointCounter/MarginContainer/HBoxContainer/Label").text = 'Score: ' + str(score)
	if area.name == "UpperWallDet" or area.name == "LowerWallDet":
		print("dead")
		get_parent().get_node("DeathThing/MarginContainer/HBoxContainer/Label").text = 'You died. Left-click to restart.\n' + "High Score: " + str(Globals.highscore)
		get_parent().get_node("DeathThing/MarginContainer/HBoxContainer/Label").horizontal_alignment = 1
		switch_to(State.DEAD)
	

func Wall_reset():
	#https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html
	var rng = RandomNumberGenerator.new()
	var Wall_instance = Wall.instantiate()
	Wall_instance.position = Vector2(self.position.x+3500, rng.randf_range(-200,200))
	get_parent().call_deferred("add_child", Wall_instance)

func _on_resetter_body_entered(body):
	if body.name == "Walls":
		print("trying to make new wall\n")
		Wall_reset()
		#https://gdscript.com/solutions/coroutines-and-yield/
		await get_tree().create_timer(5.0).timeout
		body.queue_free()

