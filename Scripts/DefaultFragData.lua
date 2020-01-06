local DefaultFragData = {
	light = 
		"light:mat4 light_space;vec3 norm_direction;vec3 position;vec3 intensity;int type;float spot_inner_ang;float spot_outer_ang;float spot_exp;float lumin_cutoff;float linear_falloff;float quad_falloff;float lumin_rec_709;"
	,
	sampler = "sampler2k",
	images = "textures2k[16]",
}
return DefaultFragData
