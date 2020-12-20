// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "fiber_material_colorgame_dissolve"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 5
		_Albedo("Albedo", Color) = (1,0,0,1)
		_FresnelScale("Fresnel Scale", Float) = 1
		_EmissionMultiplier("Emission Multiplier", Float) = 1
		_FresnelPower("Fresnel Power", Float) = 6
		_Fresnel_color("Fresnel_color", Color) = (0.3773585,0.3773585,0.3773585,0)
		_CellScale("Cell Scale", Range( 0 , 5)) = 4.088258
		_CellSharpness("Cell Sharpness", Range( 0.01 , 1)) = 0.01
		_FresnelAmount("Fresnel Amount", Range( 0 , 1)) = 0
		_CellAmount("Cell Amount", Range( 0 , 1)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Emission_Color_contribute("Emission_Color_contribute", Range( 0 , 1)) = 1
		_Float2("Float 2", Range( -1 , 2)) = -1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float4 _Fresnel_color;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _Albedo;
		uniform float _Emission_Color_contribute;
		uniform float _CellSharpness;
		uniform float _CellScale;
		uniform float _CellAmount;
		uniform float _EmissionMultiplier;
		uniform float _FresnelAmount;
		uniform float _Smoothness;
		uniform float _Float2;
		uniform float _Cutoff = 5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV32 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode32 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV32, _FresnelPower ) );
			float smoothstepResult44 = smoothstep( 0.01 , 0.11 , fresnelNode32);
			float4 temp_output_34_0 = ( _Fresnel_color * smoothstepResult44 );
			float4 Albedo110 = _Albedo;
			float Emission_Multiplier113 = _Emission_Color_contribute;
			float4 temp_output_33_0 = ( temp_output_34_0 + ( Albedo110 * ( 1.0 - Emission_Multiplier113 ) ) );
			float4 Diffuse54 = temp_output_33_0;
			o.Albedo = Diffuse54.rgb;
			float4 temp_output_106_0 = ( Albedo110 * _Emission_Color_contribute );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult74 = dot( ase_worldNormal , ase_worldlightDir );
			float smoothstepResult81 = smoothstep( 1.0 , ( 1.0 - _CellSharpness ) , ( dotResult74 * _CellScale ));
			float4 Emission57 = ( temp_output_34_0 * _EmissionMultiplier );
			float4 temp_output_88_0 = ( ( ( 1.0 - smoothstepResult81 ) * _CellAmount ) + ( Emission57 * _FresnelAmount ) );
			float4 temp_cast_1 = (1.0).xxxx;
			float4 lerpResult99 = lerp( ( temp_output_88_0 + Emission57 ) , temp_cast_1 , temp_output_88_0);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			o.Emission = ( ( temp_output_106_0 + lerpResult99 ) * ase_lightColor ).rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			float fresnelNdotV125 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode125 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV125, 1.0 ) );
			clip( ( ( 1.0 - fresnelNode125 ) - _Float2 ) - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
257;324;1291;805;3817.131;1474.219;3.829903;True;True
Node;AmplifyShaderEditor.RangedFloatNode;36;-1602.781,333.9586;Inherit;False;Property;_FresnelPower;Fresnel Power;4;0;Create;True;0;0;False;0;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1600.484,258.3728;Inherit;False;Property;_FresnelScale;Fresnel Scale;2;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;32;-1354.011,220.21;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;15.16;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;62;1297.642,-1057.901;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;82;1236.94,-826.953;Inherit;True;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;45;-1120.382,-14.85538;Inherit;False;Property;_Fresnel_color;Fresnel_color;5;0;Create;True;0;0;False;0;0.3773585,0.3773585,0.3773585,0;0.3773585,0.3773585,0.3773585,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;44;-1003.347,317.1884;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0.11;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;74;1540.768,-792.0029;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;1254.297,-650.2227;Inherit;False;Property;_CellScale;Cell Scale;6;0;Create;True;0;0;False;0;4.088258;1.2;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;1448.094,-538.0249;Inherit;False;Property;_CellSharpness;Cell Sharpness;7;0;Create;True;0;0;False;0;0.01;0.01;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-167.1911,357.8164;Inherit;True;Property;_EmissionMultiplier;Emission Multiplier;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;1603.351,-411.0466;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-774.9319,220.1531;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;298.7861,255.3374;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;1893.368,-844.3062;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;85;1889.95,-563.5461;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;81;2296.006,-787.6517;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.36;False;2;FLOAT;0.47;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;3292.974,-730.91;Inherit;False;Property;_Emission_Color_contribute;Emission_Color_contribute;11;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;597.3469,260.7503;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;92;2308.069,-573.6096;Inherit;False;Property;_CellAmount;Cell Amount;9;0;Create;True;0;0;False;0;1;0.21;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;120;2507.088,-750.0876;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;2279.227,-249.5705;Inherit;False;Property;_FresnelAmount;Fresnel Amount;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;2139.59,-447.3733;Inherit;True;57;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;3871.176,-1113.915;Inherit;False;Emission_Multiplier;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-1228.145,-402.3913;Inherit;False;113;Emission_Multiplier;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;124;-1565.695,-266.0878;Inherit;False;Property;_Albedo;Albedo;1;0;Create;True;0;0;False;0;1,0,0,1;0.008547783,0,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;2634.487,-711.4379;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;2650.511,-382.9327;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-1239.244,-265.7209;Inherit;True;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;115;-967.3535,-397.2526;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;3295.219,-320.4683;Inherit;False;57;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;2862.725,-610.4011;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-843.2776,-204.6244;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;101;2925.728,-227.5339;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;3421.438,-568.6997;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;2969.968,-979.4247;Inherit;True;110;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-255.7139,-172.1665;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;125;4742.198,-562.6603;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;99;3781.755,-664.6686;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;3656.065,-867.0294;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;128;5064.932,-553.7853;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;4421.575,-854.9538;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;430.9699,-282.3178;Inherit;True;Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;127;4934.948,-230.0046;Inherit;False;Property;_Float2;Float 2;12;0;Create;True;0;0;False;0;-1;0;-1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;117;4435.377,-966.989;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;46;291.1749,35.76447;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;119;1880.487,-324.9879;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;4438.052,-470.142;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;96;3798.284,-388.8921;Inherit;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;5798.61,-229.7337;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;4689.481,-865.3475;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;129;5348.979,-599.9722;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;2947.847,-357.6456;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;4280.757,-1259.604;Inherit;True;54;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5606.333,-949.7567;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;fiber_material_colorgame_dissolve;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;5;True;True;0;False;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;2;39;0
WireConnection;32;3;36;0
WireConnection;44;0;32;0
WireConnection;74;0;62;0
WireConnection;74;1;82;0
WireConnection;34;0;45;0
WireConnection;34;1;44;0
WireConnection;48;0;34;0
WireConnection;48;1;38;0
WireConnection;86;0;74;0
WireConnection;86;1;87;0
WireConnection;85;0;83;0
WireConnection;85;1;84;0
WireConnection;81;0;86;0
WireConnection;81;1;83;0
WireConnection;81;2;85;0
WireConnection;57;0;48;0
WireConnection;120;0;81;0
WireConnection;113;0;108;0
WireConnection;89;0;120;0
WireConnection;89;1;92;0
WireConnection;90;0;56;0
WireConnection;90;1;91;0
WireConnection;110;0;124;0
WireConnection;115;0;114;0
WireConnection;88;0;89;0
WireConnection;88;1;90;0
WireConnection;116;0;110;0
WireConnection;116;1;115;0
WireConnection;105;0;88;0
WireConnection;105;1;104;0
WireConnection;33;0;34;0
WireConnection;33;1;116;0
WireConnection;99;0;105;0
WireConnection;99;1;101;0
WireConnection;99;2;88;0
WireConnection;106;0;55;0
WireConnection;106;1;108;0
WireConnection;128;0;125;0
WireConnection;111;0;106;0
WireConnection;111;1;99;0
WireConnection;54;0;33;0
WireConnection;46;0;33;0
WireConnection;46;1;34;0
WireConnection;102;0;99;0
WireConnection;102;1;106;0
WireConnection;126;1;127;0
WireConnection;118;0;111;0
WireConnection;118;1;117;0
WireConnection;129;0;128;0
WireConnection;129;1;127;0
WireConnection;0;0;112;0
WireConnection;0;2;118;0
WireConnection;0;4;96;0
WireConnection;0;10;129;0
ASEEND*/
//CHKSM=CBD7A997001A807F791B26D991439D1E10A1B83E