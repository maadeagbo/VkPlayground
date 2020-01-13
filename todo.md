##Uniform Parser unimplemented features
- [x] Variables that are arrays (matrices are double arrays i.e. array[][])
- [x] Sampler uniforms (needs to support : width, height)
	* [x] Cpp : set, bind index, width, height
	* [x] Shader : set, bind, uniform sampler {var name};
- [x] Texture uniforms (needs to support : arrays, width, height)
	* [x] Cpp : set, bind index, width, height, array count
	* [x] Shader : set, bind, uniform texture2D {var name}[array count];
		+ bind index is always greater than the largest sampler bind index
- [x] Combine output into a .vert & .frag shader to visualize final version
- [x] Combine output into cpp header to visualize final version
- [ ] Write vulkan code generator for creating & binding shader structures

---

##### example commandline:
```
./Scripts/ShaderInputParser.lua -attrib "MeshVertex:vec4 blendweight;vec4 joints;vec3 position;vec3 normal;vec3 tangent;vec2 texcoord;" -unif "Cam:mat4 view;mat4 proj;uvec4 flag;" -unifA "Agent:mat4 model;vec4 color;vec4 inst_vals;" -unifO "vec4 interpreted_color;flat uvec4 frag_inst;vec3 frag_normal;vec3 frag_position;vec2 frag_uv;flat uvec4 frag_flag;mat4 frag_view;" -fragO "vec4 frag_color" -fragDef "SH_FLAG_LINE_REND 1 << 0;"
```
