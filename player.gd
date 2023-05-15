extends CharacterBody2D


const UP = Vector2(0, -1)
const GRAV = 10
const FLAPSPD = 250
const MAXFALLSPD = 325

var score = 0
var curmotion = Vector2(250, 0)

func _physics_process(delta):
	
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


func _on_detect_point_area_entered(area):
	if area.name == "PointDetector":
		score += 1
		print(score)
	if area.name == "UpperWallDet" or area.name == "LowerWallDet":
		print("dead")
