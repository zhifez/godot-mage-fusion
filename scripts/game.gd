extends Node3D

class ClickEvent:
	var position: Vector2

@onready var camera = $pivot/SpringArm3D/Camera3D
@onready var ui_mage_selection = $ui_game/mage_selection
@onready var prefab_map = {
	"fire": {
		"mage": preload("res://prefabs/mage_fire.tscn"),
		"pointer": preload("res://prefabs/move_to_pointer_fire.tscn"),
	}
}

var summon_mage_type: String = ""
var mages: Array = []
var selected_mage: Mage = null
var click_event: ClickEvent = null

# State Machine
enum State {
	game = 0,
	summon = 1,
}
var state: State = State.game

func _state_game(delta: float):
	if click_event != null:
		var result = _handle_click_event(click_event)
		var target = result.collider
		if target.get_parent().is_in_group("environment"):
			if selected_mage != null:
				selected_mage.move_to_pos = result.position
				selected_mage.show_selector = false
				selected_mage = null
			return
		
		if target is Mage:
			if selected_mage != null:
				selected_mage.show_selector = false
				selected_mage = null
				
			selected_mage = target as Mage
			selected_mage.show_selector = true
		click_event = null
		
func _state_summon(delta: float):
	if click_event != null:
		var result = _handle_click_event(click_event)
		_summon(result.position)
		click_event = null

func _run_state(delta: float):
	if state == State.game:
		_state_game(delta)
	elif state == State.summon:
		_state_summon(delta)

# Public
func prepare_to_summon(mage_type: String):
	summon_mage_type = mage_type
	if summon_mage_type != "":
		state = State.summon
	else:
		state = State.game
	
# Private
func _summon(pos: Vector3):
	var new_mage = prefab_map[summon_mage_type]["mage"].instantiate()
	new_mage.position = pos
	add_child(new_mage)
	var new_pointer = prefab_map[summon_mage_type]["pointer"].instantiate()
	new_pointer.position = Vector3(0.0, -1000, 0.0)
	add_child(new_pointer)
	new_mage.move_to_pointer = new_pointer

	state = State.game
	ui_mage_selection.clear_selections()
	
func _handle_click_event(event: ClickEvent):
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if !result.has("collider"):
		return null
		
	return result

# Internal
func _process(delta):
	_run_state(delta)
	
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var next_click_event = ClickEvent.new()
		next_click_event.position = event.position
		click_event = next_click_event
