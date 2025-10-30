extends Node2D

@onready var sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var sprite2D = $Sprite2D if has_node("Sprite2D") else null

var ready_finished = false
var animatedSprite: bool = false
var hasSprite: bool = false

func _ready() -> void:
	has_animated_sprite()
	has_sprite()

	await get_tree().create_timer(0.2).timeout
	ready_finished = true


func has_animated_sprite() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			animatedSprite = true
			return  # achou, pode sair da função
	animatedSprite = false  # só chega aqui se não achou


func has_sprite() -> void:
	for child in get_children():
		if child is Sprite2D:
			hasSprite = true
			return
	hasSprite = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not ready_finished:
		return
	
	if animatedSprite and sprite:
		sprite.modulate.a = 0.5
	if hasSprite and sprite2D:
		sprite2D.modulate.a = 0.5


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not ready_finished:
		return
	
	if animatedSprite and sprite:
		sprite.modulate.a = 1.0
	if hasSprite and sprite2D:
		sprite2D.modulate.a = 1.0
