extends Node3D

@export var col : Color
@export var brown : Color
@export var white : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	setParticleColour(col)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setOnOff(b):
	$GPUParticles3D.emitting = b
	

func setParticleColour(c):
	match c:
		"brown":
			c = brown
		"white":
			c = white
		_:
			pass
	$GPUParticles3D.process_material.set_color(c)
