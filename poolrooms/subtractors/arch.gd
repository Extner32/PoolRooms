extends CSGMesh3D


func set_positions(start:Vector3, end:Vector3, hall_size:float):
	var middle:Vector3 = (start+end)/2.0
	var distance = start.distance_to(end)
	var direction = (end-start)/distance
	
	global_position = middle
	look_at(start, Vector3(0, 1, 0), false)
	scale.z = distance
	scale.x = hall_size
	scale.y = hall_size
	
	
	
	
