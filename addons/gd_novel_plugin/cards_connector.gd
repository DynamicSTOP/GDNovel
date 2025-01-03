@tool
extends Control

@export_category('GN Connections')
@export var from_card: PanelContainer = null
@export var to_card: PanelContainer = null
@export var lineColor := Color.CYAN
@export var lineColorBack := Color.CORAL

@onready var path = $Path2D
@onready var curve = Curve2D.new()


func _ready() -> void:
	path.curve = curve
	update_points()

func update_points() -> void:
	path.curve.clear_points()
	
	if from_card == null or to_card == null:
		path.visible = false
		return
		
	var start := Vector2(from_card.position.x + from_card.size.x - 10, from_card.position.y + from_card.size.y / 2)
	var end := Vector2(to_card.position.x + 10, to_card.position.y + to_card.size.y / 2)
	var startB := start + Vector2(20,0)
	var endB := end - Vector2(20,0)

	path.visible = true
	
	if end.x - start.x > 20:
		path.curve.add_point(start, Vector2.ZERO, Vector2.ZERO)
		path.curve.add_point(startB, Vector2.ZERO, Vector2.ZERO)
		path.curve.add_point(endB, Vector2.ZERO, Vector2.ZERO)
		path.curve.add_point(end, Vector2.ZERO, Vector2.ZERO)
	else:
		var k := 1
		if endB.y < startB.y:
			k = -1
		path.curve.add_point(start, Vector2.ZERO, Vector2.ZERO)
		path.curve.add_point(startB, Vector2.ZERO, Vector2(from_card.size.x, k * from_card.size.y))
		path.curve.add_point(endB, Vector2(-to_card.size.x , -k * to_card.size.y), Vector2.ZERO)
		path.curve.add_point(end, Vector2.ZERO, Vector2.ZERO)	
#
#func _draw() -> void:
	#if from_card == null or to_card == null:
		#return
		#
	#var start := Vector2(from_card.position.x + from_card.size.x - 10, from_card.position.y + from_card.size.y / 2)
	#var end := Vector2(to_card.position.x + 10, to_card.position.y + to_card.size.y / 2)
	#var startB := start + Vector2(20,0)
	#var endB := end - Vector2(20,0)
	#
	#var gradient := Gradient.new()
	#gradient.add_point(0.0, lineColor)
	#gradient.add_point(255.0, lineColorBack)
		#
	#if end.x - start.x > 20:
		#line.add_point(start)
		#line.add_point(startB)
		#line.add_point(endB)
		#line.add_point(end)
		#line.gradient = gradient
		#line.antialiased = true
		#line.closed = true
		##draw_line(start, startB, lineColor, 3.0, true)	
		##draw_line(end, endB, lineColorBack, 3.0, true)	
		##draw_line(startB, endB , lineColor, 3.0, true)	
	#else:
		#draw_line(start, startB, lineColor, 3.0, true)	
		#draw_line(end, endB, lineColorBack, 3.0, true)	
		#
		#var curve = Curve2D.new()
		#var k := 1
		#if endB.y < startB.y:
			#k = -1
		#curve.add_point(startB, Vector2.ZERO, Vector2(from_card.size.x, k * from_card.size.y))
		#curve.add_point(endB,  Vector2(-to_card.size.x , -k * to_card.size.y), Vector2.ZERO)
		#
		#var packed := curve.tessellate()
		#
		#
		#draw_polyline_colors(packed, gradient.colors, 3.0, true)	
