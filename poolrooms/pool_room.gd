extends CSGBox3D

var connection_spacing := 5.0
var connection_y_offset := 0.0

var light_spacing := 5.0

@export var room_max_size = Vector3(20, 4, 20)
@export var room_min_size = Vector3(3, 3, 3)

@export var floor_min_height = 0.4
@export var floor_max_height = 1

@export var room_min_depth = 0.4
@export var room_max_depth = 1

@export var deep_room_min_depth = 5
@export var deep_room_max_depth = 10

var connections := []

var light_scene = preload("res://poolrooms/pool_light.tscn")

class Connection:
	var pos: Vector3
	var normal: Vector3
	
	func _init(_pos:Vector3, _normal:Vector3) -> void:
		pos = _pos
		normal = _normal

func randomize_size():
	var type := randi_range(0, 2)
	var room_size := Vector3()
	
	var offset := 0.0
	
	
	match type: 
		0: #floor room
			offset = randf_range(floor_min_height, floor_max_height)
			#connection_y_offset = -room_size.y/2 #places the connections at floor level
		1: #water room
			offset = -randf_range(room_min_depth, room_max_depth)
			#connection_y_offset = -room_size.y/2 #places the connections at floor level
			
		2: #deep water room
			offset = -randf_range(deep_room_min_depth, deep_room_max_depth)
			connection_y_offset = 0.0
	
	room_size = Vector3(randf_range(room_min_size.x, room_max_size.x),
						randf_range(room_min_size.y-offset, room_max_size.y-offset),
						randf_range(room_min_size.z, room_max_size.z))
							
	global_position.y += room_size.y/2
	global_position.y += offset
		
	update_size(room_size)



func update_size(room_size:Vector3):
	size = room_size
	$ReflectionProbe.size = room_size * 3
	
	#correctly place lights
	place_light(global_position+Vector3(0, size.y/2.0-0.0001, 0), Vector3(0, 1, 0))
	
	
	#this part of the code basically just sets points along the walls of the room
	#based on the connection_spacing
	
	var size_x_half = room_size.x/2
	var size_z_half = room_size.z/2
	
	var x_connection_half = int(room_size.x/connection_spacing/2)
	
	
	for i in range(-x_connection_half, x_connection_half+1):
		var point_x = basis.x * float(i) * connection_spacing
		point_x.y += connection_y_offset
		
		connections.append(Connection.new(to_global(point_x+basis.z*size_z_half), basis.z))
		connections.append(Connection.new(to_global(point_x-basis.z*size_z_half), -basis.z))
	
	
	var z_connection_half = int(room_size.z/connection_spacing/2)
	for i in range(-z_connection_half, z_connection_half+1):
		var point_z = basis.z * float(i) * connection_spacing
		point_z.y += connection_y_offset
		
		connections.append(Connection.new(to_global(point_z+basis.x*size_x_half), basis.x))
		connections.append(Connection.new(to_global(point_z-basis.x*size_x_half), -basis.x))


func place_light(pos:Vector3, normal:Vector3):
	var light = light_scene.instantiate()
	add_child(light)
	var aligned_basis := Basis()
	aligned_basis.z = -normal
	
	if normal == Vector3(0, 1, 0) or normal == Vector3(0, -1, 0):
		aligned_basis.x = Vector3(1, 0, 0)
		aligned_basis.y = Vector3(0, 0, 1)
	else:
		aligned_basis.x = normal.cross(Vector3(0, 1, 0)).normalized()
		aligned_basis.y = aligned_basis.z.cross(aligned_basis.x).normalized()
		
	light.global_basis = aligned_basis
	print(aligned_basis)
	
	light.global_position = pos
	
	return light
