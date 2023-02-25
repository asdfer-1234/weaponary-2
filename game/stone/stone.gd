extends Area2D
class_name Stone
@onready var damage_effect_canvas = $"../../../DamageEffectCanvas"
@export var speed : float = 100
@export var health : int = 10
@export var damage_multipliers : DamageMultipliers
@export var health_damage : int = 1
@export var gold_reward : int = 1



var progress = 0 : set = set_progress
var died : bool = false
var excluded_projectiles : Array = []
@onready var path_follow = $"../../HostilePaths/HostilePath/PathFollow2D"
const particle = preload("res://graphics/temporary_particle.tscn")
const damage_effect = preload("res://game/damage_effect/damage_effect.tscn")

const min_damage = 1

func set_progress(value):
	progress = value
	if has_node("../../HostilePaths/HostilePath/PathFollow2D"):
		path_follow.progress = progress
		position = path_follow.global_position
		path_follow.progress_ratio = 1
		if progress > path_follow.progress:
			goal()

func _ready():
	set_progress(progress)
	add_to_group("stone")

func _physics_process(delta):
	movement_process(delta)

func movement_process(delta):
	set_progress(progress + speed * delta)

func damage(amount : Damage):
	var new_damage = amount
	if damage_multipliers != null:
		new_damage = damage_multipliers.multiply(amount)
	var effect_damage : Damage = Damage.new()
	effect_damage.damage = max(new_damage.damage, min_damage)
	effect_damage.type = amount.type
	health -= effect_damage.damage
	instantiate_damage_effect(effect_damage)
	if health <= 0:
		die()

func knockback(distance):
	progress -= distance

func instantiate_damage_effect(damage : Damage):
	var instantiated = damage_effect.instantiate()
	instantiated.set_damage(damage)
	instantiated.global_position = global_position
	damage_effect_canvas.add_child(instantiated)
	

func die():
	if not died:
		died = true
		queue_free()
		call_deferred("on_die")
		spawn_particle()
		$"../%Gold".gold += gold_reward

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
	damage_effect_canvas.add_child(instantiated)

func get_nearby_stones_by_distance(distance):
	var result = []
	for i in get_parent().get_children():
		if position.distance_to(i.position) <= distance:
			result.append(i)
	return result

func get_nearby_stones_by_progress(backward_range, forward_range):
	var result = []
	for i in get_parent().get_children():
		if (i.path_follow == path_follow and
				i.progress <= progress + forward_range and
				i.progress >= progress - backward_range):
			result.append(i)
	return result

func goal():
	queue_free()
	$"../%Health".health -= health_damage

func add_effect(effect):
	var effect_path = NodePath(effect.get_state().get_node_name(0))
	if has_node(effect_path):
		get_node(effect_path).reload()
	else:
		add_child(effect.instantiate())


