extends Resource
class_name Ranger

func extent():
	return 0

func get_targets(_node, _group = "stone"):
	return []

func _draw(_node):
	pass

func apply_boost(_boost):
	return self
