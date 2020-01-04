#ifndef TYPE_GLSL
#define TYPE_GLSL( a, b, c, d )
#endif

// glsl type, vk format type, c type, c type size, valid attribute type, uniform slots

// Scalars

TYPE_GLSL( bool,   VK_FORMAT_R32_SINT,   bool,     1, 1, 1 )
TYPE_GLSL( int,    VK_FORMAT_R32_SINT,   int32_t,  1, 1, 1 )
TYPE_GLSL( uint,   VK_FORMAT_R32_UINT,   uint32_t, 1, 1, 1 )
TYPE_GLSL( float,  VK_FORMAT_R32_SFLOAT, float,    1, 1, 1 )
TYPE_GLSL( double, VK_FORMAT_R64_SFLOAT, double,   1, 1, 1 )

// Vectors

TYPE_GLSL( bvec2, VK_FORMAT_R32G32_SINT,         bool,     2, 1, 1 )
TYPE_GLSL( bvec3, VK_FORMAT_R32G32B32_SINT,      bool,     3, 1, 1 )
TYPE_GLSL( bvec4, VK_FORMAT_R32G32B32A32_SINT,   bool,     4, 1, 1 )
TYPE_GLSL( ivec2, VK_FORMAT_R32G32_SINT,         int32_t,  2, 1, 1 )
TYPE_GLSL( ivec3, VK_FORMAT_R32G32B32_SINT,      int32_t,  3, 1, 1 )
TYPE_GLSL( ivec4, VK_FORMAT_R32G32B32A32_SINT,   int32_t,  4, 1, 1 )
TYPE_GLSL( uvec2, VK_FORMAT_R32G32_UINT,         uint32_t, 2, 1, 1 )
TYPE_GLSL( uvec3, VK_FORMAT_R32G32B32_UINT,      uint32_t, 3, 1, 1 )
TYPE_GLSL( uvec4, VK_FORMAT_R32G32B32A32_UINT,   uint32_t, 4, 1, 1 )
TYPE_GLSL( vec2,  VK_FORMAT_R32G32_SFLOAT,       float,    2, 1, 1 )
TYPE_GLSL( vec3,  VK_FORMAT_R32G32B32_SFLOAT,    float,    3, 1, 1 )
TYPE_GLSL( vec4,  VK_FORMAT_R32G32B32A32_SFLOAT, float,    4, 1, 1 )
TYPE_GLSL( dvec2, VK_FORMAT_R64G64_SFLOAT,       double,   2, 1, 1 )
TYPE_GLSL( dvec3, VK_FORMAT_R64G64B64_SFLOAT,    double,   3, 1, 1 )
TYPE_GLSL( dvec4, VK_FORMAT_R64G64B64A64_SFLOAT, double,   4, 1, 1 )

// Matrices

TYPE_GLSL( mat2,   VK_FORMAT_UNDEFINED, float,  4, 0, 2 )
TYPE_GLSL( mat2x3, VK_FORMAT_UNDEFINED, float,  6, 0, 3 )
TYPE_GLSL( mat2x4, VK_FORMAT_UNDEFINED, float,  8, 0, 4 )
TYPE_GLSL( mat3,   VK_FORMAT_UNDEFINED, float,  9, 0, 3 )
TYPE_GLSL( mat3x2, VK_FORMAT_UNDEFINED, float,  6, 0, 2 )
TYPE_GLSL( mat3x4, VK_FORMAT_UNDEFINED, float, 12, 0, 4 )
TYPE_GLSL( mat4,   VK_FORMAT_UNDEFINED, float, 16, 0, 4 )
TYPE_GLSL( mat4x2, VK_FORMAT_UNDEFINED, float,  8, 0, 2 )
TYPE_GLSL( mat4x3, VK_FORMAT_UNDEFINED, float, 12, 0, 3 )

#undef TYPE_GLSL

