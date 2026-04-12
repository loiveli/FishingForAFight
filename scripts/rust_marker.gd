extends Control
class_name RustMarker

@export var segmentContainer: HBoxContainer
@export var emptyTexture: Texture2D = preload("res://kenney_ui-pack-space-expansion/PNG/Grey/Default/bar_square_small_m.png")
@export var filledTexture: Texture2D = preload("res://kenney_ui-pack-space-expansion/PNG/Yellow/Default/bar_square_gloss_small_m.png")

const SEGMENT_NAME_PREFIX := "RustSegment"

# Added by Copilot
func _ready() -> void:
	if segmentContainer == null:
		segmentContainer = get_node_or_null("Segments")
	_sync_segment_textures()
	set_filled_segments(0)

# Added by Copilot
func set_filled_segments(filled: int) -> void:
	if segmentContainer == null:
		return
	var clamped_filled: int = clampi(filled, 0, Robot.MAX_FIGHTS_BEFORE_BREAK)
	for i in range(Robot.MAX_FIGHTS_BEFORE_BREAK):
		var segment_node: Node = segmentContainer.get_node_or_null("%s%d" % [SEGMENT_NAME_PREFIX, i])
		if segment_node == null or not (segment_node is TextureRect):
			continue
		var segment: TextureRect = segment_node
		segment.texture = filledTexture if i < clamped_filled else emptyTexture

# Added by Copilot
func _sync_segment_textures() -> void:
	if segmentContainer == null:
		return
	for i in range(Robot.MAX_FIGHTS_BEFORE_BREAK):
		var segment_node: Node = segmentContainer.get_node_or_null("%s%d" % [SEGMENT_NAME_PREFIX, i])
		if segment_node == null or not (segment_node is TextureRect):
			continue
		var segment: TextureRect = segment_node
		segment.texture = emptyTexture
