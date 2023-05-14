extends CharacterBody2D


const UP = Vector2(0, -1)
const GRAV = 10
const FLAPSPD = 175
const MAXFALLSPD = 225

var score = 0
var curmotion = Vector2(200, 0)

func _physics_process(delta):
	
	if curmotion.y < MAXFALLSPD:
		curmotion.y += GRAV 
	if curmotion.y > MAXFALLSPD:
		curmotion.y = MAXFALLSPD
		
	if Input.is_action_just_pressed("FLAP"):
		curmotion.y = -FLAPSPD
	
	var collided = move_and_collide(curmotion * delta)


func _on_detect_point_area_entered(area):
	if area.name == "PointDetector":
		score += 1
		print(score)
