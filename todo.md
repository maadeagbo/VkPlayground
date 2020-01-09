## Uniform Parser unimplemented features

- [x] Variables that are arrays (matrices are double arrays i.e. array[][])
- [x] Sampler uniforms (needs to support : width, height)
	* [ ] Cpp : set, bind index, width, height
	* [ ] Shader : set, bind, uniform sampler {var name};
- [x] Texture uniforms (needs to support : arrays, width, height)
	* [ ] Cpp : set, bind index, width, height, array count
	* [ ] Shader : set, bind, uniform texture2D {var name}[array count];
		+ bind index is always greater than the largest sampler bind index
