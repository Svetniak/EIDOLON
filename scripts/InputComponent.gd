extends Node
class_name InputComponent

var input_vector: Vector2 = Vector2.ZERO
var wants_to_jump: bool = false
var wants_to_shoot: bool = false
var jump_released: bool = false
var wants_to_dash: bool = false

func _process(_delta):
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	wants_to_jump = Input.is_action_just_pressed("jump")
	jump_released = Input.is_action_just_released("jump")
	wants_to_shoot = Input.is_action_pressed("shoot")
	wants_to_dash = Input.is_action_just_pressed("dash")
