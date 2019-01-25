 extends Camera

# class member variables go here, for example:
export var distance = 8.0
export var height = 4.0

var dragging: bool = false
var mousePos: Vector2
signal is_watching()

func _ready():
	set_as_toplevel(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		mousePos = get_viewport().get_mouse_position()
		emit_signal("is_watching")
		print("mouse", mousePos)

func _physics_process(delta):
	var target = get_parent().global_transform.origin
	var pos = global_transform.origin
	var up = Vector3(0,1,0)
	var offset = pos - target

	offset = offset.normalized() * distance
	offset.y = height
	
	pos = target + offset
	
	look_at_from_position(pos, target, up)