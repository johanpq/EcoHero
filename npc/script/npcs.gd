extends Node2D
class_name Npc

# Lista de falas exportadas — dá pra editar no Inspector
@export var dialogues: Array[String] = [
	"Olá, aventureiro!",
	"Preciso que você colete o lixo da vila.",
	"Volte aqui quando terminar!"
]

var typing_speed := 0.03  # tempo entre letras (em segundos)
var typing_timer := 0.0
var full_text := ""
var current_text := ""
var is_typing := false


@export var sprite_frames: SpriteFrames
@export var animation_name: String = "default"

@export var labelKeyboard: Node2D
@export var mural_npc: PanelContainer
@export var mural_quest: PanelContainer
@export var title_quest: RichTextLabel
@export var text_quest: RichTextLabel
@export var name_npc: String
@export var required_npc: String
@export var next_npc: String
@export var title_mural: RichTextLabel
@export var text_mural: RichTextLabel
@export var next_scenario: String
@export var has_dialog: bool


var player_in_area = false
var dialogue_index: int = 0
var dialogue_open: bool = false
var completed_quest: bool = false
var _blocked_message_shown: bool = false
var telp_okay: bool = false

@onready var sprite: AnimatedSprite2D = $Npc/Texture

func _ready() -> void:
	telp_okay = false
	if sprite and sprite_frames:
		sprite.sprite_frames = sprite_frames
		if sprite_frames.has_animation(animation_name):
			sprite.play(animation_name)

	if labelKeyboard:
		labelKeyboard.visible = false

	if mural_npc:
		mural_npc.visible = false
	
	GlobalVariables.item_coletado.connect(_on_item_coletado)
		
	if mural_quest:
		mural_quest.visible = false

# Abre/fecha o painel de diálogo
func toggle_dialogue():
	# 1) Fechar mensagem de bloqueio
	if dialogue_open and _blocked_message_shown:
		_blocked_message_shown = false
		_close_dialogue()
		return

	# 2) Fechar modal de quest concluída
	if dialogue_open and completed_quest:
		_close_dialogue()
		return

	# 3) Abrir diálogo
	if not dialogue_open:
		# Mensagem de bloqueio
		if required_npc != "" and not (required_npc in GlobalVariables.quest_completed):
			title_mural.text = name_npc
			text_mural.text = "Conclua a tarefa com " + required_npc + " para liberar esta!"
			_blocked_message_shown = true

		# Mensagem de quest concluída
		elif name_npc in GlobalVariables.quest_completed:
			completed_quest = true
			title_mural.text = name_npc
			text_mural.text = "Tarefa concluida! Agora procure " + next_npc
			telp_okay = true

		# Diálogo normal
		else:
			dialogue_index = 0
			_show_current_dialogue()

		dialogue_open = true
		GlobalVariables.quest_open = true
		mural_npc.visible = true
		GlobalVariables.is_the_quest_open_npc = true
		
		if GlobalVariables.is_the_quest_open_npc:
			mural_quest.visible = true
			title_quest.text = "Quest"
			var qtd_inicial = get_tree().get_nodes_in_group("items").size()
			text_quest.text = "Lixos: " + str(qtd_inicial)
	else:
		if not completed_quest and not _blocked_message_shown:
			_next_dialogue()


# Mostra a fala atual
func _show_current_dialogue():
	if dialogues.size() > 0 and dialogue_index < dialogues.size():
		title_mural.text = name_npc
		full_text = dialogues[dialogue_index]
		current_text = ""
		text_mural.text = ""
		is_typing = true
		typing_timer = 0.0
	else:
		_close_dialogue()


# Vai para a próxima fala
func _next_dialogue():
	dialogue_index += 1
	if dialogue_index < dialogues.size():
		_show_current_dialogue()
	else:
		_close_dialogue()

# Fecha diálogo
func _close_dialogue():
	GlobalVariables.quest_open = false
	mural_npc.visible = false
	dialogue_open = false
	dialogue_index = 0
	_blocked_message_shown = false

func open_label_keyboard(_keyboard: String):
	var label_label = labelKeyboard.get_node("Label") as Label
	labelKeyboard.visible = true
	label_label.text = _keyboard

func close_label_keyboard():
	labelKeyboard.visible = false

func in_area(_body: Node2D) -> void:
	if has_dialog:
		player_in_area = true
		open_label_keyboard("i")

func out_area(_body: Node2D) -> void:
	if has_dialog:		
		player_in_area = false
		close_label_keyboard()
		_close_dialogue()

func next_level():
	get_tree().change_scene_to_file("res://Scenario/" + next_scenario + ".tscn")

func _process(_delta: float) -> void:
	if is_typing:
		typing_timer += _delta
	if typing_timer >= typing_speed:
		typing_timer = 0.0
		if current_text.length() < full_text.length():
			current_text += full_text[current_text.length()]
			text_mural.text = current_text
		else:
			is_typing = false

	if player_in_area and Input.is_action_just_pressed("mural_quests"):
		toggle_dialogue()
		
	if player_in_area and Input.is_action_just_pressed("next_level") and "Utah" in GlobalVariables.quest_completed:
		next_level()
	
	if mural_quest and mural_quest.visible and "Utah" in GlobalVariables.quest_completed:
		if Input.is_action_just_pressed("mural_quests"):
			mural_quest.visible = false

# Função chamada pelo Sinal Global quando um item é pego
func _on_item_coletado(itens_restantes: int) -> void:
	if mural_quest and GlobalVariables.is_the_quest_open_npc:
		
		mural_quest.visible = true 
		
		# Atualiza o texto de status
		text_quest.text = "Lixos: " + str(itens_restantes)
		
		if itens_restantes == 0:
			title_quest.text = "Quest CONCLUÍDA!"
			text_quest.text = "Procure o proximo NPC (I para fechar)"
