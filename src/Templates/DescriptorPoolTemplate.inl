VGDescrPool GenDescrPool(VkDevice* logical_device)
{
	VGDescrPool output = {};

	// uniforms/descriptors specification
	output.m_PoolTypeCount = 4;

	output.m_PoolType[0] = {};
	output.m_PoolType[0].type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
	output.m_PoolType[0].descriptorCount = ~DESC_UNI_MAIN_SH_CNT~;

	output.m_PoolType[1] = {};
	output.m_PoolType[1].type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
	output.m_PoolType[1].descriptorCount =  ~DESC_UNI_DYN_SH_CNT~;

	output.m_PoolType[2] = {};
	output.m_PoolType[2].type = VK_DESCRIPTOR_TYPE_SAMPLER;
	output.m_PoolType[2].descriptorCount = ~SMPL_CNT~;

	output.m_PoolType[3] = {};
	output.m_PoolType[3].type = VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;
	output.m_PoolType[3].descriptorCount = ~TEX_CNT~;

	VGCreateDescriptorPool(logical_device, &output);

	return output;
}

VGDescrSet GenDescrSetType1()
{
	VGDescrSet output;

	output.m_SetBindingsCount = ~BIND_CNT~;
	output.m_SetBindings = Heap::AllocT<VGDescrBinding>(~BIND_CNT~);

	// Non-dynamic uniform
	output.m_SetBindings[~U_MAIN_BIND_LOC~] = {};
	output.m_SetBindings[~U_MAIN_BIND_LOC~].m_BindIndex = 
		~U_MAIN_BIND_LOC~;
	output.m_SetBindings[~U_MAIN_BIND_LOC~].m_DescripType =
		VGDescrBinding::Types::k_Uniforms;
	output.m_SetBindings[~U_MAIN_BIND_LOC~].m_ArraySize = 1;
	output.m_SetBindings[~U_MAIN_BIND_LOC~].m_ShaderAccess =
		VK_SHADER_STAGE_VERTEX_BIT;

	output.m_SetBindings[~U_DYN_BIND_LOC~] = {};
	output.m_SetBindings[~U_DYN_BIND_LOC~].m_BindIndex = ~U_DYN_BIND_LOC~;
	output.m_SetBindings[~U_DYN_BIND_LOC~].m_DescripType =
		VGDescrBinding::Types::k_UniformDynamic;
	output.m_SetBindings[~U_DYN_BIND_LOC~].m_ArraySize = 1;
	output.m_SetBindings[~U_DYN_BIND_LOC~].m_ShaderAccess =
		VK_SHADER_STAGE_VERTEX_BIT;

	output.m_SetBindings[~U_LIGHT_BIND_LOC~] = {};
	output.m_SetBindings[~U_LIGHT_BIND_LOC~].m_BindIndex = ~U_LIGHT_BIND_LOC~;
	output.m_SetBindings[~U_LIGHT_BIND_LOC~].m_DescripType =
		VGDescrBinding::Types::k_Uniforms;
	output.m_SetBindings[~U_LIGHT_BIND_LOC~].m_ArraySize = 1;
	output.m_SetBindings[~U_LIGHT_BIND_LOC~].m_ShaderAccess =
		VK_SHADER_STAGE_FRAGMENT_BIT;

	output.m_SetBindings[~SMPL_BIND_LOC~] = {};
	output.m_SetBindings[~SMPL_BIND_LOC~].m_BindIndex = ~SMPL_BIND_LOC~;
	output.m_SetBindings[~SMPL_BIND_LOC~].m_DescripType =
		VGDescrBinding::Types::k_Sampler;
	output.m_SetBindings[~SMPL_BIND_LOC~].m_ArraySize = 1;
	output.m_SetBindings[~SMPL_BIND_LOC~].m_ShaderAccess =
		VK_SHADER_STAGE_FRAGMENT_BIT;

	output.m_SetBindings[~TEX_BIND_LOC~] = {};
	output.m_SetBindings[~TEX_BIND_LOC~].m_BindIndex = ~TEX_BIND_LOC~;
	output.m_SetBindings[~TEX_BIND_LOC~].m_DescripType =
		VGDescrBinding::Types::k_SampledImage;
	output.m_SetBindings[~TEX_BIND_LOC~].m_ArraySize = ~TEX_CNT~;
	output.m_SetBindings[~TEX_BIND_LOC~].m_ShaderAccess =
		VK_SHADER_STAGE_FRAGMENT_BIT;

	return output;
}
