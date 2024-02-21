extends CanvasLayer

@onready var wshader: ShaderMaterial = $ColorRect.material as ShaderMaterial

var off: float = 0.0

func _on_timer_timeout() -> void:
	off = off + randf_range(0.2, 1.0)
	wshader.set_shader_parameter("offset", off)
	wshader.set_shader_parameter("alpha", 0.2)
