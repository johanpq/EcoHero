extends Node2D

@export var dialog: Array[String] = ["Teste", "Aqui"]
@onready var labelKeyboard: Node2D = $Area2D/LabelKeyboard
@export var painel: PanelContainer 
@export var title: RichTextLabel 
@export var text: RichTextLabel

var player_in_area: bool = false
var typing_speed: float = 0.03
var is_typing: bool = false
var current_text: String = ""
var full_text: String = ""
var text_index: int = 0
var timer := 0.0

func _ready() -> void:
	player_in_area = false
	painel.visible = false
	labelKeyboard.visible = false

func in_area(_body: Node2D) -> void:
	player_in_area = true
	labelKeyboard.visible = true
	labelKeyboard.setKeyboard("i")

func out_area(_body: Node2D) -> void:
	player_in_area = false
	painel.visible = false
	labelKeyboard.visible = false

func toogleModal():
	painel.visible = not painel.visible
	if painel.visible:
		start_dialog()
		GlobalVariables.quest_open = true
	else:
		is_typing = false
		current_text = ""
		full_text = ""
		text_index = 0
		text.text = ""
		title.text = ""
		GlobalVariables.quest_open = false

func start_dialog():
	if dialog.size() == 0:
		text.text = "Teste"
		return
	text_index = 0
	show_next_text()

func show_next_text():
	if text_index < dialog.size():
		full_text = dialog[text_index]
		current_text = ""
		text.text = ""
		is_typing = true
		timer = 0.0
		text_index += 1
	else:
		# fim dos textos — fechar painel ou apenas parar
		toogleModal()  # ou apenas is_typing = false para manter aberto

func _input(event):
	if not player_in_area:
		return

	# evitar key repeat
	if event.is_action_pressed("mural_quests") and not event.is_echo():
		# se painel está fechado: abre e inicia diálogo
		if not painel.visible:
			toogleModal()
			return

		# painel já está aberto:
		# - se estiver digitando, completa o texto imediatamente
		# - senão, vai pro próximo texto
		if is_typing:
			current_text = full_text
			text.text = current_text
			is_typing = false
			timer = 0.0
		else:
			show_next_text()

	if painel.visible and not is_typing and event.is_action_pressed("ui_accept") and not event.is_echo():
		show_next_text()

func _process(delta: float) -> void:
	if is_typing:
		timer += delta
		if timer >= typing_speed:
			timer = 0.0
			if current_text.length() < full_text.length():
				current_text += full_text[current_text.length()]
				title.text = ""
				text.text = current_text
			else:
				is_typing = false
