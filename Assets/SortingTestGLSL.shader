﻿
Shader "Unlit/SortingTest" { // defines the name of the shader 

	SubShader{ // Unity chooses the subshader that fits the GPU best
		Tags{ "QUEUE" = "Transparent" "IGNOREPROJECTOR" = "true" "RenderType" = "Transparent" }

		Pass{ // some shaders require multiple passes
			Tags{ "QUEUE" = "Transparent" "IGNOREPROJECTOR" = "true" "RenderType" = "Transparent" }

			GLSLPROGRAM

			#version 310 es



			#ifdef VERTEX
			//#version 310 es

			uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
			uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
			uniform 	float aspect;
			uniform lowp sampler2D _ColorTex;
			struct _Points_type {
				float[3] value;
			};

			layout(std430, binding = 0) readonly buffer _Points {
				_Points_type _Points_buf[];
			};

			layout(std430, binding = 1) readonly buffer _IndicesValues {
				uint _IndicesValues_buf[];
			};
			out mediump vec3 vs_COLOR0;
			out highp vec2 vs_TEXCOORD0;

			const float inv6 = 1.0 / 6.0;
			const float inv255 = 2.0 / 255.0;

			vec2 colorCoords = vec2(0.0);

			void main()
			{
				int quadId = int(float(gl_VertexID) * inv6);
				int quad_vertexID = -6 * quadId + gl_VertexID;

				bvec4 bits = equal(ivec4(quad_vertexID), ivec4(1, 4, 2, 3));
				bool bit = bits.x || bits.y;
				vec2 quadCoordsAndTexCoord = vec2(bit || bits.z, bit || bits.w);
				
				float size = 0.002;//0.02;
				vec2 quadSize = vec2(size, size * aspect);

				vec2 deltaSize = (quadCoordsAndTexCoord * 2.0 - 1.0) * quadSize;

				uint value = _IndicesValues_buf[quadId];

				uint index = value >> 8u;
				float colorValue = float(value & 255u) * inv255;

				vec4 position = vec4((_Points_buf[index].value[0]), (_Points_buf[index].value[1]), (_Points_buf[index].value[2]), -1.0);

				vs_TEXCOORD0 = quadCoordsAndTexCoord;
				
				gl_Position = gl_ModelViewProjectionMatrix * (-position);
				gl_Position.xy += deltaSize;

				colorCoords.x = pow((colorValue), .0625);
				vs_COLOR0 = textureLod(_ColorTex, colorCoords, 0.0).xyz;
			}

			#endif
			#ifdef FRAGMENT	

			uniform highp sampler2D _AlbedoTex;

			in mediump vec3 vs_COLOR0;
			in highp vec2 vs_TEXCOORD0;

			layout(location = 0) out highp vec4 SV_Target0;

			void main()
			{
				float albedo = textureLod(_AlbedoTex, vs_TEXCOORD0.xy, 0.0).a;
				if (albedo < 0.7) {
					discard; 
				}

				SV_Target0.xyz = vs_COLOR0;
				SV_Target0.w = albedo;
				
			}

			#endif


			ENDGLSL 

		}
	}
}