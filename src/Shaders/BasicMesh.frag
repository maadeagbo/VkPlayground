void
main()
{
	if ((frag_flag.x & SH_FLAG_LINE_REND) != 0) {
		frag_color = interpreted_color;
		return;
	}

	vec4 base_col = texture(sampler2D(texbuffer2k[frag_inst.x], sampler2k), frag_uv);
	//vec4 base_col = textureLod(sampler2D(texbuffer2k[frag_inst.x], sampler2k), frag_uv, 0);

	vec3 view_position = -frag_view[3].xyz;
	vec3 view_dir      = normalize(view_position - frag_position);
	vec3 light_dir     = normalize(-Light.norm_direction); // directional light

	vec3 ambient = vec3(base_col.xyz) * 0.1;

	// diffuse
	float kd     = max(dot(frag_normal, light_dir), 0.0);
	vec3 diffuse = Light.intensity * kd * base_col.xyz;
	//if ((flag.x & SH_FLAG_LINE_REND) != 0)
	//	diffuse = vec3(1.f, 0.f, 1.f);
	
	// specular
	vec3 half_dir = normalize(light_dir + view_dir);
	float ks      = pow(max(dot(frag_normal, half_dir), 0.0), 20);
	vec3 spec     = Light.intensity * ks * base_col.xyz;

	frag_color = vec4(ambient + diffuse + spec, 1.0);
}
