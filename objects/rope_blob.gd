extends Node2D
class_name RopeBlob

@onready var sprite = $sprite

@onready var anim = $anim

var left_x = -666;
var right_x = 999 + 333;

var center = round((right_x + left_x) * 0.5)
var velocity: Vector2;
var rvel = 0.0;

var dead = false;

var falling = true
func _ready():
	#anim.play("small")
	anim.stop()
	sprite.frame = 0;
	var snd = [$spawn1, $spawn2, $spawn3].pick_random()
	snd.play()
	snd.pitch_scale = randf_range(0.99, 1.02)
	pass
	
func _enter_tree():
	velocity.x = randf_range(1.0, 8.0)
	if position.x > center:
		velocity.x *= -1
	velocity.y = -randf_range(8., 12.)
	rvel = randf_range(-1, 1)
@onready var audio_stream_player = $AudioStreamPlayer

var rope: Rope
func land_on_rope(r: Rope):
	if rope == r: return
	rope = r;
	rope.rope_blobs.push_back(self)
	falling = false;
	audio_stream_player.play()
	audio_stream_player.pitch_scale = randf_range(0.99, 1.02)

func punch():
	dead = true;
	velocity.y = -randf_range(12, 19)
	velocity.x = sign(Game.bird.velocity.x) * randf_range(2, 3);
	rvel = randf_range(-1.0, 1.0)

var level = 1;
func embiggen():
	if level == 2:
		sprite.frame = 1;
		#anim.play("medium");
		#print("Playing miedium")
	if level >= 3:
		sprite.frame = 2;
		#anim.play("large");
		#print("Playing large")
@onready var splash = $AudioStreamPlayer2

var putting_into_pot = false;
var finito = false;
var old_pos: Vector2;
signal on_put_into_pot(level:int);
func _physics_process(delta):
	position += velocity;
	velocity *= 0.99;
	if finito:
		if !splash.playing:
			queue_free()
		return
	if falling or dead:
		velocity.y += 0.3;
		sprite.rotation += rvel;
		rvel *= 0.96;
		var b:Bird = Game.bird
		if putting_into_pot:
			if position.y > 300:
				on_put_into_pot.emit(level);
				finito = true;
				splash.play()
				splash.pitch_scale = randf_range(0.99, 1.01)
				
		if velocity.y > 0 and !dead:
			for rope in b.rope_segments:
				if !rope.is_under(old_pos) and rope.is_under(position):
					land_on_rope(rope)
					break
				pass
		old_pos = position;
	else:
		velocity *= 0.9
		if !is_instance_valid(rope):
			rope = null;
			falling = true;
			return;
		var rot = rope.dir_normalized.angle()
		sprite.rotation = rot
		if rope.dir_normalized.x < 0:
			sprite.rotation += PI
		position = rope.get_position_at_x(position)
		
		for b in rope.rope_blobs:
			if b == self:
				continue
			if !is_instance_valid(b):
				continue;
			var d:Vector2 = b.position - position;
			if d.length_squared() < 80 * 80:
				d *= 0.5;
				if b.level != level:
					position -= d * 0.1
					return
				position += d * 0.2;
				if d.length() < 10.0:
					level += b.level;
					#print("Merge", level)
					b.queue_free()
					embiggen()
					print(position)
					break;
		pass
	
