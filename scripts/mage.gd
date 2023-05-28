extends CharacterBody3D

class_name Mage

const SPEED = 5.0
const ROTATE_SPEED = 50.0
const MIN_MOVE_DISTANCE = 0.1

@onready var model = $model
@onready var selector = $selector

var cooldown: float = 2.0
var damage: int = 1
var move_to_pointer: Node3D:
	set(new_value):
		move_to_pointer = new_value
		move_to_pointer.visible = false
var mage_index: int:
	set(new_value):
		mage_index = new_value
		move_to_pointer = get_node(str("/root/game/move_to_pointer_", mage_index))

var shoot_timer: float = 0.0
var move_to_pos: Vector3 = Vector3.ZERO:
	set(new_value):
		move_to_pos = new_value
		if move_to_pointer != null:
			move_to_pointer.position = move_to_pos
		
@export
var show_selector: bool = false:
	set(new_value):
		show_selector = new_value
		selector.visible = show_selector

# State Machine
enum State {
	idle = 0,
	move = 1,
	dead = 2,
}
var state: State = State.idle:
	set(new_value):
		state = new_value
		
		if move_to_pointer != null:
			move_to_pointer.visible = (state == State.move)
		
		if state == State.dead:
			_state_dead()

func _state_idle(delta):
	var distance = position.distance_to(move_to_pos)
	if distance > MIN_MOVE_DISTANCE:
		state = State.move
		return
		
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = cooldown
#		TODO: Spawn projectile
	
func _state_move(delta):
	var distance = position.distance_to(move_to_pos)
	if distance <= MIN_MOVE_DISTANCE:
		state = State.idle
		return
		
#	Move towards move_to_pos
	var direction = position.direction_to(move_to_pos)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
#
	if velocity.length() > 0.2:
		var look_dir = move_to_pos.direction_to(position)
		var look_dir_v2 = Vector2(look_dir.z, look_dir.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_dir_v2.angle(), delta * ROTATE_SPEED)
	
	move_and_slide()
	
func _state_dead():
	pass
	
func _run_state(delta):
	if state == State.idle:
		_state_idle(delta)
	elif state == State.move:
		_state_move(delta)
	elif state == State.dead:
		_state_dead()

# Internal
func _ready():
	selector.visible = false
	
	state = State.idle
	move_to_pos = position

func _process(delta):
	_run_state(delta)
