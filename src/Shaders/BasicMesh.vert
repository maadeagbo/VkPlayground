vec4
ColorFrom8bitUint(uint rgba32)
{
	return vec4(float((rgba32 >> 24) & 255),
				float((rgba32 >> 16) & 255),
				float((rgba32 >> 8) & 255),
				float(rgba32 & 255));
}

void
main()
{
	if ((Cam.flag.x & SH_FLAG_LINE_REND) != 0) {
		gl_Position = vec4(blendweight.xyz, 1.0);
		interpreted_color = ColorFrom8bitUint(floatBitsToUint(
			blendweight.z));

		return;
	}

	gl_Position = Cam.proj * Cam.view * Agent.model * vec4(
		position, 1.0);

	interpreted_color = Agent.color;
	frag_inst		  = uvec4(Agent.inst_vals);
	frag_normal       = normal; // should multiply by a normal matrix
	frag_position     = (Agent.model * vec4(position, 1.0)).xyz;
	frag_uv           = texcoord;
	frag_flag		  = Cam.flag;
	frag_view		  = Cam.view;
}
