extends Node



func flash(obj:AnimatedSprite2D,color:Color,time:float):
	var mat=obj.material
	mat.set_shader_parameter("active",true)
	mat.set_shader_parameter("tint",color)
	await get_tree().create_timer(time).timeout
	mat.set_shader_parameter("active",false)
