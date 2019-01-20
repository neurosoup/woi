extends KinematicBody

var velocity = Vector3()
var camera
var gravity = -9.8
var character

const SPEED = 6
const ACCELERATION = 3
const DE_ACCELERATION = 5

var lastMousePos


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here 
	character = get_node(".")
	pass
	
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print("position", lastMousePos)

func lookAt():
	
	var camera = get_node("target/Camera")
	var mousePos = get_viewport().get_mouse_position()
	
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
			var gridMap: GridMap = hit.collider
			var worldLocation = Vector3(hit.position[0], hit.position[1], hit.position[2])
			var mapLocation = gridMap.world_to_map(worldLocation)
			print("map location",  mapLocation)
 
func _physics_process(delta): 

	

	camera = get_node("target/Camera").get_global_transform()
	
	
	lookAt()
	
	var dir = Vector3()
	
	var isMoving = false
	
	if (Input.is_action_pressed("move_fw")):
		dir = -camera.basis[2] 
		isMoving = true
	if (Input.is_action_pressed("move_bw")):
		dir = camera.basis[2]
		isMoving = true
	if (Input.is_action_pressed("move_l")):
		dir = -camera.basis[0] 
		isMoving = true
	if (Input.is_action_pressed("move_r")):
		dir = camera.basis[0]
		isMoving = true
		
	dir.y = 0
	dir = dir.normalized()
	
	velocity.y += delta * gravity
	
	var hv = velocity 
	hv.y = 0
	
	var new_pos = dir * SPEED
	
	var acceleration = DE_ACCELERATION
	if (dir.dot(hv) > 0):
		acceleration = ACCELERATION
		
	hv = hv.linear_interpolate(new_pos, acceleration * delta)
	
	velocity.x = hv.x
	velocity.z = hv.z
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	
	if isMoving:
		var angle = atan2(hv.x, hv.z)
		var rotation = character.get_rotation()
		rotation.y = angle
		character.set_rotation(rotation)