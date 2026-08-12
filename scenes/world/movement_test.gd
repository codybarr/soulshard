extends Node2D

const ROOM: Rect2 = Rect2(0, 0, 1536, 896)
const GRID: float = 32.0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(ROOM.grow(128), Color("071113"))
	draw_rect(ROOM, Color("102825"))

	for x: float in range(ROOM.position.x, ROOM.end.x + 1.0, GRID):
		draw_line(Vector2(x, ROOM.position.y), Vector2(x, ROOM.end.y), Color(0.17, 0.37, 0.33, 0.22), 1.0)
	for y: float in range(ROOM.position.y, ROOM.end.y + 1.0, GRID):
		draw_line(Vector2(ROOM.position.x, y), Vector2(ROOM.end.x, y), Color(0.17, 0.37, 0.33, 0.22), 1.0)

	draw_rect(ROOM, Color("4d9b83"), false, 4.0)
	_draw_ruin(Vector2(272, 228), Vector2(170, 74))
	_draw_ruin(Vector2(1110, 596), Vector2(218, 92))
	_draw_ruin(Vector2(704, 374), Vector2(100, 46))
	_draw_torch(Vector2(186, 710))
	_draw_torch(Vector2(1360, 186))


func _draw_ruin(center: Vector2, dimensions: Vector2) -> void:
	var rect := Rect2(center - dimensions * 0.5, dimensions)
	draw_rect(rect, Color("173b35"))
	draw_rect(rect, Color("6a9f87"), false, 3.0)
	draw_line(rect.position + Vector2(10, 10), rect.end - Vector2(10, 10), Color(0.73, 0.86, 0.71, 0.15), 2.0)


func _draw_torch(position: Vector2) -> void:
	draw_circle(position, 26.0, Color(0.96, 0.57, 0.22, 0.08))
	draw_circle(position, 6.0, Color("f6d66d"))
	draw_circle(position + Vector2(0, -6), 3.0, Color("fff1b0"))
