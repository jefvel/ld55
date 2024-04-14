extends RigidBody2D
class_name Item;

@onready var sprite = $sprite
@onready var animation_player = $AnimationPlayer

var picked_up = false;

var falling = false;
var velocity: Vector2;

func _ready():
	sprite.frame = randi() % (sprite.hframes * sprite.vframes);
	
var target: Enemy;
@onready var hitbox = $Hitbox

func pick_up():
	if picked_up: return
	
	sprite.position.y = 0;
	var tw = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tw.tween_property(sprite, "position:y", -16, 1.8)
	picked_up = true;
	animation_player.play("pickup")
	collision_mask = 0;
	collision_layer = 0;
	find_target();
	
	hitbox.area_entered.connect(_hit_target)
	
func _hit_target(e):
	if e is EnemyHitbox and e.target is Enemy:
		if e.target.dead: return
		velocity = linear_velocity.normalized() * randf_range(1.0, 1.0)
		target.hurt(self);
		queue_free()
		pass
	pass

func find_target():
	if is_instance_valid(target) and !target.dead:
		return
	var closest: Enemy;
	var closest_distance = 600.0 * 600.0;
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var pos = global_position 
	if is_instance_valid(Game.bird):
		pos = Game.bird.global_position
		pos += Game.bird.velocity.normalized() * 150
	
	for e in enemies:
		if e is Enemy:
			var d_sq = pos.distance_squared_to(e.global_position)
			if d_sq < closest_distance:
				closest_distance = d_sq
				closest = e;
				if d_sq < 100 * 100 and randf() > 0.8:
					break
	target = closest;

func drop():
	falling = true;
	pass
	
func prepare():
	if picked_up:
		animation_player.play("prepare")
	else:
		drop();

var time: float = 0.0 + randf();
var check = 60;
func _physics_process(delta):
	if !picked_up and !Game.frozen:
		time += delta * 2;
		sprite.position.y = round(sin(time) * 2.9)
	
	if picked_up and target:
		check -= 1
		if check < 0: find_target()
		if !is_instance_valid(target): return
		var d = (target.global_position - global_position).normalized() * 1500
		apply_force(d)
		pass
	
	if falling:
		velocity.y += 0.1;
		position += velocity;
		modulate.a *= 0.9;
		if modulate.a < 0.05:
			queue_free()
	#else:
		#sprite.position.y = 8
