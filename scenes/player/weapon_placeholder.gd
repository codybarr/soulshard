extends Node2D

@export var blade_length: float = 22.0


func _draw() -> void:
	# The weapon points along local +X; PlayerController supplies its anchor and rotation.
	draw_line(Vector2(-5, 0), Vector2(2, 0), Color("6b4635"), 3.0)
	draw_line(Vector2(0, -5), Vector2(0, 5), Color("f6d66d"), 2.0)
	draw_line(Vector2(2, 0), Vector2(blade_length, 0), Color("d7f2d7"), 4.0)
	draw_line(Vector2(3, -1), Vector2(blade_length, -1), Color("ffffff"), 1.0)
	draw_circle(Vector2(blade_length, 0), 2.0, Color("9bd9c0"))
