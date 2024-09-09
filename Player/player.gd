class_name Player
extends CharacterBody2D

enum JumpType{
	Jump,
	Target
}

@export var SPEED = 48.0
@export var CROUCH_SPEED = 42.0
@export var MAX_FALL_SPEED = 80.0
@export var STARTING_DOWN := Vector2.DOWN

@export var ground_gravity = 800
@export var fall_gravity = 160
@export var rise_gravity = 80
@export var rise_leaning_angle = 15

@export var animation_player : AnimationPlayer
@export var animation_tree : AnimationTree

@export var startLevelWithoutAnimation := false
@export var startRoomVisible := false
@export var startWithBackPackVisible := false

@onready var sprite := $Sprite2D
@onready var rayCast2D := $RayCast2D
@onready var groundCheck := $GroundRayCast2D
@onready var stateMachine := $StateMachine
@onready var PickupDetect := $PickupDetect as Area2D
@onready var SpringDetect := $SpringDetect as Area2D
@onready var PipeDetect := $PipeDetect as Area2D
@onready var StandUpDetect = $StandUpDetect
@onready var FloatyBits := $"Floaty Bit Modulation/Floaty Bit" as Sprite2D
@onready var FloatyBitModulation = $"Floaty Bit Modulation"

@onready var InteractionDisplay := $InteractionDisplay

@onready var PickupSound = $PickupSound
@onready var CrouchSound = $CrouchSound
@onready var StandupSound = $StandupSound
@onready var ClimbSound = $ClimbSound
@onready var FallSound = $FallSound
@onready var WalkSound1 = $WalkSound1
@onready var WalkSound2 = $WalkSound2
@onready var CrouchSound1 = $CrouchSound1
@onready var CrouchSound2 = $CrouchSound2



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
			_updateHighlighting()
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

var currentSpringData : SpringData

var interactionReady := false

var hasPickup := false
var pickupObject : Interactable

var _active := false
var active:
	get:
		return _active
	set(value):
		visible = value
		_active = value
		stateMachine.active = value

func pausePlay():
	active = false
	visible = true

func unpausePlay():
	active = true

func _ready():
	active = false
	visible = startRoomVisible
	GameManager.registerPlayer(self)
	FloatyBits.visible = startWithBackPackVisible

func startLevel():
	active = true
	if not startLevelWithoutAnimation:
		animation_tree.set("parameters/Level Enter One Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _process(_delta: float):
	if not active: return
	if waitForPhysicsProcess:
		if down_changed : updateVisualRotation()
	#print("Current Animation: " + animation_player.current_animation)

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
	
	FloatyBitModulation.scale = Vector2(1 if facingRight else -1 , 1)
	
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

func canStandUp() -> bool:
	print("has Overlapping bodies? ", StandUpDetect.has_overlapping_bodies(), " | has Overlapping areas? ", StandUpDetect.has_overlapping_areas())
	return not StandUpDetect.has_overlapping_bodies()

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
		animation_tree.set("parameters/face_spring/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_spring_start/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_spring_cooldown/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_pipe_entry/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_pipe_exit/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_level_enter/blend_amount", oldAnimationTreeFacingRight)
		animation_tree.set("parameters/face_level_exit/blend_amount", oldAnimationTreeFacingRight)

func forceAirState():
	stateMachine.state.call_deferred("transitionToAir")

#region Interaction
var _interactables := [] as Array[Interactable]

func onPipeEnter(body):
	if body is Interactable:
		_addInteractable(body)
func onPipeExit(body):
	if body is Interactable:
		_removeInteractable(body)

func _updateHighlighting():
	if _interactables.size() != 0:
		for inter in _interactables:
			inter.hideHighLight()
		for inter in _interactables:
			if inter.isInteractable(down):
				inter.showHighLight()
				break

func _addInteractable(i: Interactable):
	_interactables.insert(0, i)
	_updateHighlighting()

func _removeInteractable(i: Interactable):
	i.hideHighLight()
	_interactables.erase(i)
	_updateHighlighting()

func hasInteraction() -> bool :
	if _interactables.size() != 0:
		for inter in _interactables:
			if inter.isInteractable(down):
				return true
	return false

func Interact():
	if _interactables:
		var currentInteraction : Interaction
		for inter in _interactables:
			if inter.isInteractable(down):
				currentInteraction = inter.getInteraction()
				break
		if currentInteraction:
			match currentInteraction.type:
				Interaction.InteractionType.LEVEL_END:
					stateMachine.transition_to("LevelEnd", currentInteraction.data)
					
				Interaction.InteractionType.PIPE:
					stateMachine.transition_to("PipeTransport", {"start": currentInteraction.data.start, "target": currentInteraction.data.target, "down":currentInteraction.data.down})
					
				Interaction.InteractionType.PICKUP:
					var interactable := currentInteraction.origin as Interactable
					pickupObject = interactable
					stateMachine.transition_to("Pickup", {"start": interactable.global_position})

func pickup():
	if pickupObject:
		pickupObject.hideInteractable()
		pickupObject.disableInteractable()
		#_removeInteractable(interactable)
		hasPickup = true
		FloatyBits.visible = true
		FloatyBits.texture = pickupObject.pickupTexture

func dropPickup():
	if hasPickup:
		global_position = global_position.snapped(Vector2(8,8))
		pickupObject.moveTo(global_position)
		var tileMap: TileMap
		pickupObject.showInteractable()
		pickupObject.enableInteractable()
		#_addInteractable(pickupObject)
		pickupObject = null
		hasPickup = false
		FloatyBits.visible = false

func showInteractionDisplay():
	InteractionDisplay.show_all = true

func hideInteractionDisplay():
	InteractionDisplay.show_all = false

func addInteraction():
	pass
#endregion

func playFallSound():
	if not FallSound.playing:
		FallSound.play()

func playWalkSound():
	if not (WalkSound1.playing or WalkSound2.playing):
		if randf() >= 0.5:
			WalkSound1.play()
		else:
			WalkSound2.play()

func playCrouchSound():
	if not (CrouchSound1.playing or CrouchSound2.playing):
		if randf() >= 0.5:
			CrouchSound1.play()
		else:
			CrouchSound2.play()
