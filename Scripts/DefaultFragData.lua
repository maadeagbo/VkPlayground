local DefaultFragData = {
	light = [[ 
		light:
		mat4 light_space;
		vec3 norm_direction;
		vec3 position;
		vec3 intensity;
		int type;
		float spot_inner_ang;
		float spot_outer_ang;
		float spot_exp;
		float lumin_cutoff;
		float linear_falloff;
		float quad_falloff;
		float lumin_rec_709;
	]]
	,
	image = [[
		sampler2k,2048, 2048;
		textures2k,2048,2048,16;
	]],
}
return DefaultFragData