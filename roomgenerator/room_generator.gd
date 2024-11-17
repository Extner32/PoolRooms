extends CSGCombiner3D

@export var sector_size = 1000
var current_sector = Vector3i.ZERO
var prev_current_sector = Vector3i.ZERO


@export var room_seed = 10


@export var corridor_min_len = 10
@export var corridor_max_len = 30

@export var room_min_distance = 20
@export var player: CharacterBody3D

var room_scene = preload("res://poolrooms/pool_room.tscn")
var light_scene = preload("res://poolrooms/pool_light.tscn")
var corridor_scene = preload("res://poolrooms/subtractors/arch.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#seed(room_seed)
	$Walls.size = Vector3(sector_size, sector_size, sector_size) * 2
	generate_room()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	prev_current_sector = current_sector
	#move walls to follow the player
	#$Walls.global_position = player.global_position
	current_sector = Vector3i(round(player.global_position.x/sector_size),
							round(player.global_position.y/sector_size),
							round(player.global_position.z/sector_size))
							
	if prev_current_sector != current_sector:
		$Walls.global_position = current_sector * sector_size





func generate_room():
	var room = place_room(Vector3.ZERO)
	for connection in room.connections:
		var a = connection.pos-connection.normal
		var b = connection.pos+connection.normal*randi_range(corridor_min_len, corridor_max_len)
		place_corridor(a, b, 1.2)
		place_room(b)
	

func place_corridor(start:Vector3, end:Vector3, hall_size:float=1.0):
	var corridor = corridor_scene.instantiate()
	add_child(corridor)
	corridor.set_positions(start, end, hall_size)
	return corridor

func place_room(pos:Vector3):
	var room_instance = room_scene.instantiate()
	add_child(room_instance)
	room_instance.randomize_size()
	
	
	room_instance.position.x = pos.x
	room_instance.position.z = pos.z
	
	return room_instance
	
