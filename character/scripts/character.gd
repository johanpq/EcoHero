extends CharacterBody2D
class_name PlayerCharacter  # nome da classe

@export_category("Variables")
@export var move_speed: float = 40.0
@export var friction: float = 0.2
@export var acceleration: float = 0.2

@export_category("Objects")
@export var _attack_timer: Timer = null
@export var animation_tree: AnimationTree

# --- Variáveis internas ---
var is_deadd: bool = false
var state_machine
var is_attack: bool = false

func _ready() -> void:
	# Se não tiver atribuído no inspetor, pega pelo nome
	if animation_tree == null:
		animation_tree = $AnimationTree
	
	animation_tree.active = true
	
	if animation_tree:
		state_machine = animation_tree.get("parameters/playback")
	else:
		push_error("AnimationTree não encontrado!")

func _physics_process(_delta: float) -> void:
	if is_deadd: 
		return
		
	_move(_delta)
	_attack()
	_animate()
	move_and_slide()

# --- Método de movimento ---
func _move(_delta: float) -> void:
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if direction != Vector2.ZERO:
		if GlobalVariables.quest_open:
			return
			
		var normalized_dir = direction.normalized()
		
		velocity.x = lerp(velocity.x, normalized_dir.x * move_speed, acceleration)
		velocity.y = lerp(velocity.y, normalized_dir.y * move_speed, acceleration)
		
		if animation_tree:
			animation_tree["parameters/idle/blend_position"] = normalized_dir
			animation_tree["parameters/walk/blend_position"] = normalized_dir
			animation_tree["parameters/attack/blend_position"] = normalized_dir
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
		velocity.y = lerp(velocity.y, 0.0, friction)

func _attack() -> void:
	if Input.is_action_just_pressed("attack") and not is_attack:
		#set_physics_process(false)
		_attack_timer.start()
		is_attack = true
		
# --- Método de animação ---
func _animate() -> void:
	if state_machine == null:
		return
	
	if is_attack:
		state_machine.travel("attack")
		return
		
	if velocity.length() > 10:
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")


func _on_attack_timer_timeout() -> void:
	#set_physics_process(true)
	is_attack = false

func _on_attack_area_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("enemy"):
		_body.update_health()

func die() -> void:
	is_deadd = true
	state_machine.travel("death")
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
