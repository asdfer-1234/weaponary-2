extends Area2D
class_name Stone
@onready var map = $"../../.."

@export var speed : float = 10;
@export var health : int = 10;
@export var damage_multipliers = DamageMultipliers.new([])
var progress = 0 : set = set_progress
var died : bool = false
var excluded_projectiles : Array = []
@onready var path_follow = $"../../HostilePaths/HostilePath/PathFollow2D"
const particle = preload("res://graphics/temporary_particle.tscn")


func set_progress(value):
	progress = value
	if has_node("../../HostilePaths/HostilePath/PathFollow2D"):
		path_follow.progress = progress
		position = path_follow.global_position
		path_follow.progress_ratio = 1
		if progress > path_follow.progress:
			queue_free()

func _ready():
	set_progress(progress)
	add_to_group("stone")

func _physics_process(delta):
	movement_process(delta)

func movement_process(delta):
	set_progress(progress + speed * delta)

func damage(amount : Damage):
	health -= damage_multipliers.multiply(amount).damage
	if health <= 0:
		die()

func die():
	if not died:
		died = true
		queue_free()
		call_deferred("on_die")
		spawn_particle()

func on_die():
	pass

func spawn_stone(stone : PackedScene, amount : int = 1, spacing : float = 5):
	var offset = -(amount * spacing / 2.0)
	for i in range(amount):
		var instantiated : Node = stone.instantiate()
		instantiated.progress = progress + offset + spacing * i
		instantiated.excluded_projectiles = excluded_projectiles.duplicate()
		get_parent().add_child(instantiated)

func spawn_particle():
	var instantiated = particle.instantiate()
	instantiated.global_position = global_position
	$"../..".add_child(instantiated)

func get_nearby_stones_by_distance(range):
	var result = []
	for i in get_parent().get_children():
		if position.distance_to(i.position) <= range:
			result.append(i)
	return result

func get_nearby_stones_by_progress(backward_range, forward_range):
	var result = []
	for i in get_parent().get_children():
		if i.path_follow == path_follow and i.progress <= progress + forward_range and i.progress >= progress - backward_range:
			result.append(i)
	return result
