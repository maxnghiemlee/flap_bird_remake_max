extends CharacterBody2D

# states I will use for my state machine
enum State {NOT_STARTED, ALIVE, DEAD, RESTARTING, WAIT_RESPONSE}

# presets 
var curstate = State.NOT_STARTED
var toswitch = false
var nextstate
var Wall = preload("res://wall.tscn")

# for the physics engine
const UP = Vector2(0, -1)
const GRAV = 20
const FLAPSPD = 350
const MAXFALLSPD = 400

# things to change throughout that will be useful later
var score = 0
var curmotion = Vector2(400, 0)
var timeelapsed = 0

func switch_to(new_state: State):
	#kind of a janky solution, but this will hide the death textbox
	get_parent().get_node("DeathThing/MarginContainer").visible = false
	# if i died, then show the death textbox
	if new_state == State.RESTARTING or new_state == State.WAIT_RESPONSE:
		get_parent().get_node("DeathThing/MarginContainer").visible = true
	if new_state == State.NOT_STARTED:
		# if I just died, then reload the scene (once again, not the most 
		# logical solution, but it works)
		curstate = State.NOT_STARTED
		get_tree().reload_current_scene()
		self.position.x = 0
		self.position.y = 0
	if new_state == State.ALIVE:
		curstate = State.ALIVE
	if new_state == State.DEAD:
		# stop the animation for 1 second, then accept response from
		# the user to see if they want to replay
		$AnimatedSprite2D.stop()
		curstate = State.DEAD
	if new_state == State.RESTARTING:
		curstate = State.RESTARTING
		switch_to(State.WAIT_RESPONSE)
	if new_state == State.WAIT_RESPONSE:
		curstate = State.WAIT_RESPONSE
	
func _physics_process(delta):
	# kind of a janky solution again because it shows for a bit, but this,
	# shortly after restarting the current scene, makes the intro instructions
	# invisible. dealing with reload current scene was annoying, so i stuck with this.
	if (!Globals.isfirsttime):
		get_parent().get_node("IntroThing/MarginContainer").visible = false
	# count timeelapsed (will be set to 0 when I need a timer), so it
	# will essentially only be useful when set to 0, like when restarting
	timeelapsed += delta
	# janky solution again, but this will stop the player from
	# going too high or too low and seeing the gray haha. They would
	# die anyway, but this is just to keep them in bounds for sure
	if curstate == State.ALIVE:
		if self.position.y > 400:
			curmotion.y = 0
		if self.position.y < 400 and curmotion.y < MAXFALLSPD:
			curmotion.y += GRAV 
		# so you don't exceed terminal velocity
		if curmotion.y > MAXFALLSPD:
			curmotion.y = MAXFALLSPD
		if Input.is_action_just_pressed("FLAP"):
			# if you try to flap, then make the y velocity be flapspeed unless
			# player is too high, wherein it wouldn't change
			if (self.position.y > -300):
				curmotion.y = -FLAPSPD
		# if falling, play that animation
		if curmotion.y >= 0:
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.play("Falling")
			#print("playing falling")
		else:
			# otherwise, play the flap animation (must have flapped
			# for player to not be falling)
			$AnimatedSprite2D.play("Flap")
			#print("playing flap")
		var collided = move_and_collide(curmotion * delta)
		# when in start screen, game starts by player pressing flap
	if curstate == State.NOT_STARTED:
		if Input.is_action_just_pressed("FLAP"):
			get_parent().get_node("IntroThing/MarginContainer").visible = false
			curmotion.y = - FLAPSPD
			switch_to(State.ALIVE)
	if curstate == State.DEAD:
		# count the time player has been dead. After 0.2 seconds,
		# then switch to restarting and give player another chance to 
		# restart game
		timeelapsed += delta
		if timeelapsed >= 0.2:
			timeelapsed = 0
			switch_to(State.RESTARTING)
	if curstate == State.WAIT_RESPONSE:
		if Input.is_action_just_pressed("clickedleft"):
			# if left click is pressed, then switch to restarted screen after .2 secs
			print("left clicked")
			toswitch = true
			nextstate = State.NOT_STARTED
			timeelapsed = 0
		if timeelapsed >= 0.2 and toswitch:
			timeelapsed = 0
			switch_to(nextstate)
func _on_detect_point_area_entered(area):
	if area.name == "PointDetector":
		# if player goes through pipes, then add a point and show it. 
		score += 1
		if score > Globals.highscore:
			Globals.highscore = score
		print(score)
		get_parent().get_node("PointCounter/MarginContainer").visible = true
		get_parent().get_node("PointCounter/MarginContainer/HBoxContainer/Label").text = 'Score: ' + str(score)
	if area.name == "UpperWallDet" or area.name == "LowerWallDet":
		# if player hits wall, then kill the player and give them instructions to 
		# restart and display highscore
		print("dead")
		Globals.totalplays += 1
		Globals.isfirsttime = false
		get_parent().get_node("DeathThing/MarginContainer/HBoxContainer/Label").text = 'You died. Left-click to restart.\n' + "High Score: " + str(Globals.highscore) + '\n Total plays: ' + str(Globals.totalplays)
		get_parent().get_node("DeathThing/MarginContainer/HBoxContainer/Label").horizontal_alignment = 1
		switch_to(State.DEAD)
	

func Wall_reset():
	#https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html
	var rng = RandomNumberGenerator.new()
	var Wall_instance = Wall.instantiate()
	# https://www.youtube.com/watch?v=Kt1njjNGbSg. Although this is a
	# tutorial for flappy bird in Godot, I didn't refrence this video much
	# besides at the very beginning to get a rough idea of what to do and also
	# for this resetting wall idea, which I immediately conceptually understood,
	# but didn't know how to implement
	Wall_instance.position = Vector2(self.position.x+3500, rng.randf_range(-200,200))
	get_parent().call_deferred("add_child", Wall_instance)

func _on_resetter_body_entered(body):
	if body.name == "Walls":
		# if resetter detects a wall (which means player has passed it),
		# then queue free it after 5 seconds to avoid 
		# it getting chopped off the screen abruptly 
		print("trying to make new wall\n")
		Wall_reset()
		#https://gdscript.com/solutions/coroutines-and-yield/
		await get_tree().create_timer(5.0).timeout
		body.queue_free()
