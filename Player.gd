extends KinematicBody

var velocity = Vector3()
var camera
var gravity = -9.8
var character

enum STATES { IDLE, FOLLOW, WATCHING }
var _state = null
var target_point_world: Vector3
var path = []

const SPEED = 6

func _ready():
	character = get_node(".")
	_change_state(STATES.IDLE)
	
func _change_state(new_state):
	if new_state == STATES.FOLLOW:
		var trip = getTrip()
		var map = get_parent().get_node("GridMap")
		path = map.get_world_path(trip[0], trip[1])
		if path.empty():
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	_state = new_state
	
func _input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			if _state == STATES.WATCHING:
				_change_state(STATES.IDLE)
			else:
				_change_state(STATES.FOLLOW)

func getTrip():
	var trip = [] 
	
	var camera = get_node("target/Camera") as Camera
	var mousePos = get_viewport().get_mouse_position()
	
	var start_world_pos = character.get_global_transform().origin;
	
	# Project mouse into a 3D ray
	var ray_origin = camera.project_ray_origin(mousePos)
	var ray_direction = camera.project_ray_normal(mousePos)

	# Cast a ray
	var from = ray_origin
	var to = ray_origin + ray_direction * 1000.0
	var space_state = get_world().get_direct_space_state()
	var hit = space_state.intersect_ray(from, to)
	if hit.size() != 0:
		if hit.collider is GridMap:
			var map: GridMap = hit.collider
			var start = map.world_to_map(start_world_pos)
			trip.append(start)
			var destination_world_pos = Vector3(hit.position.x, hit.position.y, hit.position.z)
			var destination = map.world_to_map(destination_world_pos)
			trip.append(destination)
			return trip
	return null
 
func move_to(delta, world_position: Vector3):
	var MASS = 10.0
	var ARRIVE_DISTANCE = 1.5

	var desired_velocity = (world_position - global_transform.origin).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	velocity.y = delta * gravity
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	var angle = atan2(velocity.x, velocity.z)
	var rotation = get_rotation()
	rotation.y = angle
	set_rotation(rotation)
	
	var position = global_transform.origin
	var arrive_distance = position.distance_to(world_position)
	
	return arrive_distance < ARRIVE_DISTANCE

func _physics_process(delta): 
	var is_moving = _state == STATES.FOLLOW
	
	if is_moving:
		var arrived_to_next_point = move_to(delta, target_point_world)
		if arrived_to_next_point:
			path.remove(0)
			if path.empty():
				_change_state(STATES.IDLE)
				return
			target_point_world = path[0]


func _on_Camera_is_watching():
	_change_state(STATES.WATCHING)
