extends Node2D

const WALL = preload("res://objects/wall.png")

var tilesX = 6;
var tilesY = 6;

var w: int = 64;
var h: int = 64;

var tiles:Array[Sprite2D] = [];

func _ready():
	
	w = WALL.get_width();
	h = WALL.get_height()
	
	for x in range(0, tilesX):
		for y in range(0, tilesY):
			var t = Sprite2D.new();
			t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			t.texture = WALL;
			t.position.x = x * w;
			t.position.y = y * h;
			add_child(t);
			tiles.push_back(t);
			pass
	
	pass
