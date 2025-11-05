extends Node2D

@export var dialogues: Array[String] = [
	"Olá, aventureiro!",
	"Preciso que você colete o lixo da vila.",
	"Volte aqui quando terminar!"
]

@onready var mural : PanelContainer = $Warning/CanvasLayer/Mural
@onready var text : RichTextLabel = $Warning/CanvasLayer/Mural/Text

var typing_speed := 0.03  # tempo entre letras (em segundos)
var typing_timer := 0.0
var full_text := ""
var current_text := ""
var is_typing := false
var dialogue_index: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mural.visible = true
	_show_current_dialogue()

# Mostra a fala atual
func _show_current_dialogue():
	if dialogues.size() > 0 and dialogue_index < dialogues.size():
		full_text = dialogues[dialogue_index]
		current_text = ""
		text.text = ""
		is_typing = true
		typing_timer = 0.0
	else:
		mural.visible = false


# Vai para a próxima fala
func _next_dialogue():
	dialogue_index += 1
	if dialogue_index < dialogues.size():
		_show_current_dialogue()
	else:
		mural.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_typing:
		typing_timer += delta
		if typing_timer >= typing_speed:
			typing_timer = 0.0
			if current_text.length() < full_text.length():
				current_text += full_text[current_text.length()]
				text.text = current_text
			else:
				is_typing = false
			
	if Input.is_action_just_pressed("mural_quests"):
		_next_dialogue()
