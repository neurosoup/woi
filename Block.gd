extends CollisionShape

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var this : CollisionShape = get_node(".")
			var shape = this.get_shape() as ConvexPolygonShape
			print("position", shape.points[0], shape.points[1], shape.points[2])