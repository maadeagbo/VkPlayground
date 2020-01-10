##Uniform Parser unimplemented features
- [x] Variables that are arrays (matrices are double arrays i.e. array[][])
- [x] Sampler uniforms (needs to support : width, height)
	* [ ] Cpp : set, bind index, width, height
	* [ ] Shader : set, bind, uniform sampler {var name};
- [x] Texture uniforms (needs to support : arrays, width, height)
	* [ ] Cpp : set, bind index, width, height, array count
	* [ ] Shader : set, bind, uniform texture2D {var name}[array count];
		+ bind index is always greater than the largest sampler bind index
- [ ] Combine output into a .vert & .frag shader to visualize final version
- [ ] Combine output into cpp header to visualize final version
- [ ] Write vulkan code generator for creating & binding shader structures

---

example commandline
./Scripts/ShaderInputParser.lua -attrib "MyTestA:vec3 uno;vec4 dos;vec2 tres;mat3x4 quatro;vec5 cinco;" -unif "MyTestB:mat4 ichi;mat3x4 ni;vec2 san;" -unifA "MyTestC:float un;bool deux;mat4x3 quatre;" -unifO "vec4 one;mat4 two;bool three;"

