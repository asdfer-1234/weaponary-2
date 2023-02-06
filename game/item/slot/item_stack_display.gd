extends Control

@export var item_stack : ItemStack:
	set(value):
		if value == null:
			var new_item_stack = ItemStack.new()
			new_item_stack.item = null
			_item_stack = new_item_stack
		else:
			_item_stack = value
		for i in _item_stack.changed.get_connections():
			_item_stack.changed.disconnect(i["callable"])
		_item_stack.changed.connect(update_display)
		update_display()
	get:
		return _item_stack

var _item_stack

func _ready():
	item_stack = item_stack

func update_display():
	if item_stack.item == null:
		$ItemTexture.texture = null
		$Count.text = ""	
	else:
		$ItemTexture.texture = item_stack.item.sprite
		if item_stack.item is StackableItem:
			$Count.text = _count_text(item_stack.count)
		else:
			$Count.text = ""

func _count_text(count : int) -> String:
	return "\n" + RichTextBuilder.right(count);
