## Uniform Parser unimplemented features
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

## Shader set management
- [ ] Split shaders into 3 sets:
	- 1 for scene view data : camera, environment
	- 1 for texture data : samplers & textures bindless array
	- 1 for dynamic uniform data (per obj data)

### Code gen
- vertex shader spv
- fragment shader spv
- [ ] VGCreateDescriptorPool :
	- [ ] VK_DESCRIPTOR_TYPE_SAMPLER - descriptorCount
	- [ ] VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE - descriptorCount
- [ ] Always : rf_data->m_TriShaderDescrip.m_SetsCount = 5;
- [ ] VGCreateDescriptorLayout :
	- `f_data->m_TriShaderDescrip.m_Sets[ `SET NDX` ].m_SetBindings[ `BIND NDX` ] = {};`
      `rf_data->m_TriShaderDescrip.m_Sets[ `SET NDX` ].m_SetBindings[ `BIND NDX` ].m_BindIndex = `BIND NDX`;`
      `rf_data->m_TriShaderDescrip.m_Sets[ `SET NDX` ].m_SetBindings[ `BIND NDX` ].m_DescripType = VGDescrBinding::Types::k_Uniforms;`
      `rf_data->m_TriShaderDescrip.m_Sets[ `SET NDX` ].m_SetBindings[ `BIND NDX` ].m_ArraySize = 1;`
      `rf_data->m_TriShaderDescrip.m_Sets[ `SET NDX` ].m_SetBindings[ `BIND NDX` ].m_ShaderAccess = VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT;`
	- .m_DescripType = VGDescrBinding::Types::k_Uniforms;
	- .m_ShaderAccess = VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT;
- [ ] Always : `rf_data->m_GraphicsPipeTri.m_VertexBufferCount = 1;`
- [ ] rf_data->m_GraphicsPipeTri.m_VertexBuffer
	- `rf_data->m_GraphicsPipeTri.m_VertexAttribs[vertex_attr_idx] = {};`
      `rf_data->m_GraphicsPipeTri.m_VertexAttribs[vertex_attr_idx].m_BindIndex = rf_data->m_GraphicsPipeTri.m_VertexBuffer[0].m_BindIndex;`
      `rf_data->m_GraphicsPipeTri.m_VertexAttribs[vertex_attr_idx].m_ShaderLocation = 2;`
      `rf_data->m_GraphicsPipeTri.m_VertexAttribs[vertex_attr_idx].m_Offset = offsetof(MeshVertex, position);`
      `rf_data->m_GraphicsPipeTri.m_VertexAttribs[vertex_attr_idx].m_AttribFormat = VK_FORMAT_R32G32B32_SFLOAT;`
      `vertex_attr_idx++;`
	- .m_ShaderLocation = 2
	- .m_Offset         = offsetof(MeshVertex, position)
	- .m_AttribFormat   = VK_FORMAT_R32G32B32_SFLOAT
- [ ] rf_data->m_TriShaderDescrip.m_Sets :

---

### Code gen structs
- [x] VGShaderObj
- [x] VGDescrPool
- [x] VGDescrSet
- [ ] VGVertexBuffer
- [ ] VGVertexAttrObj
- [ ] VGBufferPool
- [ ] VGBufferObj

---

##### example commandline:
```
./Scripts/ShaderInputParser.lua -attrib "MeshVertex:vec4 blendweight;vec4 joints;vec3 position;vec3 normal;vec3 tangent;vec2 texcoord;" -unif "Cam:mat4 view;mat4 proj;uvec4 flag;" -unifA "Agent:mat4 model;vec4 color;vec4 inst_vals;" -unifO "vec4 interpreted_color;flat uvec4 frag_inst;vec3 frag_normal;vec3 frag_position;vec2 frag_uv;flat uvec4 frag_flag;mat4 frag_view;" -fragO "vec4 frag_color" -fragDef "SH_FLAG_LINE_REND 1 << 0;"
```
