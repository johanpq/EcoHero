extends Node2D
class_name Item  # nome da classe

func addItem():
	add_to_group("items")

func removeItem():
	# Notifica o Level
	get_tree().call_group("level", "on_item_removed")
	# Remove o item
	queue_free()
	# NÃO adicionar Utah aqui mais
