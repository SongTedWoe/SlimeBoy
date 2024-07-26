class_name Player
extends CharacterBody2D


@export var SPEED = 100.0
@export var CROUCH_SPEED = 50.0
@export var MAX_FALL_SPEED = 100.0
@export var CLIMB_STRENGTH = 100.0
@export var STARTING_DOWN := Vector2.DOWN


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var animation_player : AnimationPlayer
@export var animation_tree : AnimationTree
@onready var sprite := $Sprite2D
@onready var rayCast2D := $RayCast2D
@onready var groundCheck := $GroundRayCast2D
@onready var stateMachine := $StateMachine
@onready var PickupDetect := $PickupDetect as Area2D
@onready var SpringDetect := $SpringDetect as Area2D

#facingRight is pointing horizontally to the right and vertically up
var facingRight := true
@onready var gravityDirection := STARTING_DOWN
var down : Vector2:
	get:
		return gravityDirection
	set(value):
		if value == Vector2.DOWN or value == Vector2.LEFT or value == Vector2.RIGHT or Vector2.UP:
			#check for right facing
			if ((gravityDirection == Vector2.DOWN or gravityDirection == Vector2.RIGHT) and (value == Vector2.LEFT or value == Vector2.UP)) or ((value == Vector2.DOWN or value == Vector2.RIGHT) and (gravityDirection == Vector2.LEFT or gravityDirection == Vector2.UP)): facingRight = not facingRight
			gravityDirection = value
			adjustInputs()
			updateFacing()
			updateLeftRight()
			#down_changed = true
			updateVisualRotation()
			waitForPhysicsProcess = false
			
			print("Down changed : ", down)

var left := Vector2.LEFT
var right := Vector2.RIGHT

var leftDirection := &"left"
var rightDirection := &"right"
var climbDirection := &"up"
var crouchDirection := &"down"

var InputLock := false;

var climbing_strain := 0.0;

var down_changed = false
var waitForPhysicsProcess = false

func _process(_delta: float):
	if waitForPhysicsProcess:
		if down_changed : updateVisualRotation()
	if Input.is_key_pressed(KEY_R):
		stateMachine.transition_to("Death")
	#print("Current Animation: " + animation_player.current_animation)
	
	if Input.is_key_pressed(KEY_J):
		animation_tree.set("parameters/Pickup One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _physics_process(_delta: float):
	waitForPhysicsProcess = true

var switch_Animation = false
func updateFacing():
	if down == Vector2.DOWN or down == Vector2.RIGHT:
		animationTreeFacingRight = facingRight
		switch_Animation = false
		rayCast2D.target_position.x = abs(rayCast2D.target_position.x) * (1 if facingRight else -1)
	else:
		animationTreeFacingRight = not facingRight
		switch_Animation = true
		rayCast2D.target_position.x = abs(rayCast2D.target_position.x) * (-1 if facingRight else 1)
	
	updateAnimation()

func CanClimb() -> bool:
	return rayCast2D.is_colliding()

func GetWallObject() -> Node2D:
	if rayCast2D.is_colliding():
		return rayCast2D.get_collider()
	else:
		return null

func lockInput():
	InputLock = true

func unlockInput():
	InputLock = false

func shoutout():
	print("Hey! I am here")

func rotatePhysicsToCeiling():
	down = Vector2.UP

func rotatePhysicsToWallLeft():
	down = Vector2.LEFT

func rotatePhysicsToWallRight():
	down = Vector2.RIGHT

func rotatePhysicsToGround():
	down = Vector2.DOWN

func updateVisualRotation():
	match down:
		Vector2.DOWN:
			rotation = deg_to_rad(0)
		Vector2.LEFT:
			rotation = deg_to_rad(90) 
		Vector2.RIGHT:
			rotation = deg_to_rad(-90)
		Vector2.UP:
			rotation = deg_to_rad(180)

func adjustInputs():
	match gravityDirection:
		Vector2.DOWN:
			leftDirection = &"left"
			rightDirection = &"right"
			climbDirection = &"up"
			crouchDirection = &"down"
		Vector2.RIGHT:
			leftDirection = &"down"
			rightDirection = &"up"
			climbDirection = &"left"
			crouchDirection = &"right"
		Vector2.LEFT:
			leftDirection = &"down"
			rightDirection = &"up"
			climbDirection = &"right"
			crouchDirection = &"left"
		Vector2.UP:
			leftDirection = &"left"
			rightDirection = &"right"
			climbDirection = &"down"
			crouchDirection = &"up"

func updateLeftRight():
	match gravityDirection:
		Vector2.DOWN, Vector2.UP:
			left = Vector2.LEFT
			right = Vector2.RIGHT
		Vector2.RIGHT, Vector2.LEFT:
			left = Vector2.DOWN
			right = Vector2.UP

func is_on_Ground() -> bool:
	match down:
		Vector2.DOWN:
			if is_on_floor() or groundCheck.is_colliding():
				return true
		Vector2.LEFT, Vector2.RIGHT:
			if is_on_wall() or groundCheck.is_colliding():
				return true
		Vector2.UP:
			if is_on_ceiling() or groundCheck.is_colliding():
				return true
	return false

func goToWall():
	velocity = (right if facingRight else left) * SPEED
	move_and_slide()

var animationTreeFacingRight = false
var oldAnimationTreeFacingRight = false
func updateAnimation():
	if oldAnimationTreeFacingRight != animationTreeFacingRight:
		oldAnimationTreeFacingRight = animationTreeFacingRight
		animation_tree.set("parameters/face_climb/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_crouch idle/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_crouch start/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_crouch walk/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_crouch walk start/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_uncrouch/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_death/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_fall/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_fall start/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_idle/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_land/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_walk/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_walk start/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_pickup/blend_amount", oldAnimationTreeFacingRight)

func forceAirState():
	stateMachine.state.call_deferred("transitionToAir")

func playAnimation(_name: String):
	pass

func nextAnimation(_name:String):
	pass

func clearAnimation():
	pass

func getAnimationName(animName: String) -> String:
	return animName

var _PickUpsInLevel
var last_Pick_Up_Entered
func on_body_enter(body):
	
	pass 

'''
var qeuedAnimation : String
func playAnimation(_name: String):
	if _name == "": return
	
	var animName = getAnimationName(_name)
	
	print("Play Animation: " + animName)
	animation_player.play(animName)

func nextAnimation(_name: String):
	if _name == "" : return
	
	var animName = getAnimationName(_name)
	
	if animation_player.current_animation == "":
		print("no Active Animation")
		playAnimation(animName)
	
	var anim = animation_player.get_animation(animation_player.current_animation)
	if anim and anim.loop_mode != Animation.LOOP_NONE:
		print("Animation Next Check: Found Loop Mode: " + animation_player.current_animation)
		playAnimation(animName) 
		return
	
	var queue = animation_player.get_queue()
	for el in queue:
		print ("Animation Next Check: Looking at Loop Mode in Queue at Element: " + el)
		anim = animation_player.get_animation(el)
		if anim and anim.loop_mode != Animation.LOOP_NONE:
			print("Animation Next Check: Found Loop Mode: " + el)
			playAnimation(animName) 
			return
	
	print("Queue Animation: " + animName)
	animation_player.queue(animName)

func updateAnimation():
	var updatedAnimationName = getAnimationName(animation_player.current_animation)
	if animation_player.current_animation != updatedAnimationName:
		playAnimation(updatedAnimationName)
		var time = animation_player.current_animation_position
		animation_player.play(updatedAnimationName)
		animation_player.seek(time)
	#update Queue if necessary
	var queue = animation_player.get_queue()
	animation_player.clear_queue()
	for el in queue:
		updatedAnimationName = getAnimationName(el)
		animation_player.queue(updatedAnimationName)

func clearAnimation():
	animation_player.clear_queue()
	animation_player.stop()
	animation_player.play("RESET")
	animation_player.advance(0)

func getAnimationName(animName: String) -> String:
	if animName.ends_with("_left"):
		animName = animName.substr(0, animName.length() - 5)
	
	var animation_name = animName
	if (not facingRight and not switch_Animation) or (facingRight and switch_Animation): 
		animation_name += "_left"
	return animation_name
'''
