extends Node2D
class_name Items  # nome da classe

@onready var Item : Item = $item
@onready var Label_hint: Label = $item/Area2D/LabelKeyboard/Label
var player_inside = false
var ready_finished = false
	
func _ready():
	Item.addItem()
	Label_hint.visible = false
	
	await get_tree().create_timer(0.2).timeout
	ready_finished = true

func in_area(_body: Node) -> void:
	if not ready_finished:
		return
	player_inside = true
	Label_hint.text = "F"
	Label_hint.visible = true

func out_area(_body: Node) -> void:
	if not ready_finished:
		return
	player_inside = false
	Label_hint.visible = false

func _physics_process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("get_item"):
		Item.removeItem()
		
		var total_no_grupo = get_tree().get_nodes_in_group("items").size()
		var qtd = total_no_grupo - 1
		
		if GlobalVariables.is_the_quest_open_npc:
			GlobalVariables.item_coletado.emit(qtd) 
			print("Quantidade restante: " + str(qtd)) 
			
		if qtd == 0 and "Utah" not in GlobalVariables.quest_completed:
			GlobalVariables.quest_completed.append("Utah")
