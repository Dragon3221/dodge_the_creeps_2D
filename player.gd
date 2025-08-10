extends Area2D
signal hit

var is_dead := false
@export var speed := 400
@export var accel := 2000
@export var friction := 1500

var screen_size: Vector2
var velocity: Vector2 = Vector2.ZERO

func _ready():
	screen_size = get_viewport_rect().size
	_set_animation("idle")
	hide()
	

func _process(delta: float) -> void:
	if is_dead:
		return
		
	var input_dir := Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		velocity = velocity.move_toward(input_dir * speed, accel * delta)
		_update_animation(input_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if velocity.length() < 10:
			velocity = Vector2.ZERO
			_set_animation("idle")

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

func _update_animation(dir: Vector2) -> void:
	if dir.x != 0:
		_set_animation("walk")
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = dir.x < 0
	elif dir.y != 0:
		_set_animation("up")
		$AnimatedSprite2D.flip_v = dir.y > 0

func _set_animation(anim_name: String) -> void:
	if $AnimatedSprite2D.animation != anim_name:
		$AnimatedSprite2D.animation = anim_name
	$AnimatedSprite2D.play()

func _on_body_entered(_body: Node2D) -> void:
	if is_dead:
		return
	is_dead = true
	print("Player hit")
	velocity = Vector2.ZERO
	_set_animation("death")
	print("Waiting for death animation to finish...")
	await $AnimatedSprite2D.animation_finished
	print("Death animation finished")
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos: Vector2) -> void:
	position = pos
	velocity = Vector2.ZERO
	is_dead = false
	_set_animation("idle")
	show()
	$CollisionShape2D.disabled = false
