extends Marker3D

var currentTarget
@onready var player = get_tree().get_nodes_in_group("Player") [0]
var cameraRot_y = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	currentTarget = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = currentTarget.global_position
	global_rotation = Vector3(0, cameraRot_y, 0)
