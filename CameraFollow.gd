 extends Camera

# class member variables go here, for example:
export var distance = 8.0
export var height = 4.0
var rot_x = 0
var rot_y = 0
var LOOKAROUND_SPEED = 0.005

var dragging: bool = false
var watching: bool = false

signal is_watching()

func _ready():
	set_as_toplevel(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			dragging = true
		else:
			watching = false
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		rot_x += event.relative.x * LOOKAROUND_SPEED
		#rot_y += event.relative.y * LOOKAROUND_SPEED
		watching = true
		emit_signal("is_watching")

func _physics_process(delta):
	var target = get_parent().global_transform.origin
	var pos = global_transform.origin
	var up = Vector3(0,1,0)
	var offset = pos - target

	offset = offset.normalized() * distance
	offset.y = height
	
	pos = target + offset
	
	if watching:
		transform.basis = Basis() # reset rotation
		global_transform.origin = Vector3(target.x, target.y, target.z)
		rotate_object_local(Vector3(0, 1, 0), rot_x) 
		#rotate_object_local(Vector3(1, 0, 0), rot_y) 
	else:
		look_at_from_position(pos, target, up)