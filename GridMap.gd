extends GridMap

var astar: AStar
var map: GridMap
var map_size = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	astar = AStar.new()
	map = get_node(".")
	var points = _add_walkable_cells()
	_connect_walkable_cells(points)

func _add_walkable_cells() -> PoolVector3Array:
	var points = []
	var cells = map.get_used_cells()
	for cell in cells:
		if cell.y > 0:
			continue
		if map.get_cell_item(cell.x, cell.y + 1, cell.z) != GridMap.INVALID_CELL_ITEM:
			continue
		var point = Vector3(cell.x + map_size / 2, cell.y + 1, cell.z + map_size / 2) 
		points.append(point)
		var index = _get_point_index(point)
		astar.add_point(index, point)
		var hasPoint = astar.has_point(index)
	return points


func _connect_walkable_cells(points: PoolVector3Array):
	for point in points:
		var index = _get_point_index(point)
		var adjacent_points = PoolVector3Array([
			Vector3(point.x + 1, point.y, point.z),
			Vector3(point.x - 1, point.y, point.z),
			Vector3(point.x, point.y, point.z + 1),
			Vector3(point.x, point.y, point.z - 1)])
		for adjacent_point in adjacent_points:
			var adjacent_point_index = _get_point_index(adjacent_point)
			if adjacent_point == point or _is_outside_map(adjacent_point):
				continue
			if not astar.has_point(adjacent_point_index):
				continue
			astar.connect_points(index, adjacent_point_index, false)
	
func _get_point_index(point: Vector3):
	var index = point.x + point.y + map_size * point.z
	return index
	
func _is_outside_map(point):
	return point.x < 0 or point.z < 0 or point.x >= map_size or point.z >= map_size
	
func get_world_path(start: Vector3, end: Vector3) -> PoolVector3Array:
	
	var start_index = _get_point_index(start)
	var end_index = _get_point_index(end)
	
	var path = astar.get_point_path(start_index, end_index)
	
	var world_path = []
	for point in path:
		var world_point = map_to_world(point.x, point.y, point.z)
		world_path.append(world_point)
	return world_path