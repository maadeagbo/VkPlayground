VGShaderObj GenShaderObjVertex(VkDevice* logical_device)
{
	VGShaderObj output = {};

	output.m_Stage = VK_SHADER_STAGE_VERTEX_BIT;
	VGCreateShaderModule(logical_device,
						 &output,
						 ~VERT_SPV~);

	VGDebugNameObj(logical_device,
				   (uint64_t)output.m_Handle,
				   VK_OBJECT_TYPE_SHADER_MODULE,
				   ~VERT_SPV_DEBUG~);

	return output;
}

VGShaderObj GenShaderObjFragment(VkDevice* logical_device)
{
	VGShaderObj output = {};

	output.m_Stage = VK_SHADER_STAGE_FRAGMENT_BIT;
	VGCreateShaderModule(logical_device,
						 &output,
						 ~FRAG_SPV~);

	VGDebugNameObj(logical_device,
				   (uint64_t)output.m_Handle,
				   VK_OBJECT_TYPE_SHADER_MODULE,
				   ~FRAG_SPV_DEBUG~);

	return output;
}

