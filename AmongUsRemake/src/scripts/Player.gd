class_name Player
extends KinematicBody2D


enum AnimationState {
	LEFT = 0,
	RIGHT = 1,
	NONE = 2
}

export var speed: Vector2
export var light_energy: float
var current_player: bool
var imposter = false
var velocity = Vector2(0, 0)
var animation_state = AnimationState.NONE
var animation_stopped = true


func _ready():
	$Camera2D.current = current_player
	$Light2D.energy = light_energy
	$PlayerFader.energy = 1


func _physics_process(_delta):
	if current_player:
		velocity = get_movement_vector()
		velocity = move_and_slide(velocity)

		if velocity.x < 0:
			animation_state = AnimationState.LEFT
		elif velocity.x > 0:
			animation_state = AnimationState.RIGHT

		if velocity == Vector2(0, 0):
			animation_stopped = true
		else:
			animation_stopped = false

		Network.rpc_unreliable("update_player", Network.self_data.id, position, animation_state, animation_stopped)

	animate()


func _input(_event):
	# Game Start Button
	if Input.is_action_just_pressed("ui_accept"):
		if get_tree().is_network_server() and not Network.game_started:
			var imposter_ids = []
			var random_key = Network.players.keys()[randi() % Network.players.size()]
			imposter_ids.append(Network.players[random_key].id)
			print(imposter_ids)
			Network.start_game(imposter_ids)


func init(position, name, is_current_player):
	self.position = position
	self.name = name
	self.current_player = is_current_player
	$NameLabel.text = name

	if current_player:
		# self.material.light_mode = 0
		$Light2D.enabled = true
		$PlayerFader.enabled = true
		self.z_index = 2
	else:
		# self.material.light_mode = 2
		$Light2D.enabled = false
		$PlayerFader.enabled = false
		self.z_index = 1


func enable_imposter_ui():
	# TODO: Update this function when added imposter UI
	pass


func animate():
	if animation_state == AnimationState.LEFT:
		$AnimatedSprite.flip_h = true
	elif animation_state == AnimationState.RIGHT:
		$AnimatedSprite.flip_h = false

	if animation_stopped == true:
		$AnimatedSprite.play("idle")
		$AnimatedSprite.playing = false
	else:
		$AnimatedSprite.play("walking")
		$AnimatedSprite.playing = true


func get_movement_vector() -> Vector2:
	var move_vector = Vector2(0, 0)

	move_vector.x = (
		Input.get_action_strength("right") - Input.get_action_strength("left")
	)
	move_vector.y = (
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	return move_vector * speed
