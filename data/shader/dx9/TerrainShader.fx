texture colorTex0 < string NTM = "shader"; int NTMIndex = 0; >;
texture alphaTex0 < string NTM = "shader"; int NTMIndex = 1; >;

technique SinglePassBaseFix
{
	pass
	{
		Lighting				= True;
		AlphaBlendEnable		= False;
		AlphaTestEnable			= False;
		ZWriteEnable			= True;
		ZEnable					= True;
		ColorVertex				= True;
		
		VertexShader			= null;
		PixelShader				= null;

		TexCoordIndex[0]		= 0;
		TextureTransformFlags[0]= DISABLE;
		Texture[0]				= (colorTex0);
		ColorOp[0]				= MODULATE;
		ColorArg1[0]			= Texture;
		ColorArg2[0]			= Diffuse;
		MagFilter[0]			= LINEAR;
		MinFilter[0]			= LINEAR;
		MipFilter[0]			= LINEAR;
		AddressU[0]				= WRAP;
		AddressV[0]				= WRAP;
	}
}

technique SinglePassAlphaBaseFix
{
	pass
	{
		Lighting				= True;
		AlphaBlendEnable		= True;
		AlphaTestEnable			= False;
		ZWriteEnable			= False;
		ZEnable					= True;
		ColorVertex				= True;
		
		BlendOp					= ADD;
		SrcBlend				= SrcAlpha;
		DestBlend				= InvSrcAlpha;

		VertexShader			= null;
		PixelShader				= null;
		
		TexCoordIndex[0]		= 0;
		TextureTransformFlags[0]= DISABLE;
		Texture[0]				= (alphaTex0);
		ColorOp[0]				= MODULATE;
		ColorArg1[0]			= Texture;
		ColorArg2[0]			= Diffuse;
		AlphaOp[0]				= BLENDFACTORALPHA;
		AlphaArg1[0]			= Current;
		AlphaArg2[0]			= Diffuse;
		MagFilter[0]			= LINEAR;
		MinFilter[0]			= LINEAR;
		MipFilter[0]			= LINEAR;
		AddressU[0]				= WRAP;
		AddressV[0]				= WRAP;

		TexCoordIndex[1]		= 1;
		TextureTransformFlags[1]= DISABLE;
		Texture[1]				= (colorTex0);
		ColorOp[1]				= MODULATE;
		ColorArg1[1]			= Current;
		ColorArg2[1]			= Texture;
		AlphaOp[1]				= MODULATE;
		AlphaArg1[1]			= Current;
		AlphaArg2[1]			= Diffuse;
		MagFilter[1]			= LINEAR;
		MinFilter[1]			= LINEAR;
		MipFilter[1]			= LINEAR;
		AddressU[1]				= WRAP;
		AddressV[1]				= WRAP;
	}
}

technique SinglePassAlphaFix
{
	pass
	{
		Lighting				= True;
		AlphaBlendEnable		= True;
		AlphaRef				= 0x00000001;
		AlphaTestEnable			= True;
		AlphaFunc				= GREATEREQUAL;
		ZWriteEnable			= False;
		ZEnable					= True;
		ColorVertex				= True;
		
		BlendOp					= ADD;
		SrcBlend				= SrcAlpha;
		DestBlend				= InvSrcAlpha;

		VertexShader			= null;
		PixelShader				= null;
		
		TexCoordIndex[0]		= 0;
		TextureTransformFlags[0]= DISABLE;
		Texture[0]				= (colorTex0);
		ColorOp[0]				= MODULATE;
		ColorArg1[0]			= Texture;
		ColorArg2[0]			= Diffuse;
		MipFilter[0]			= LINEAR;
		MinFilter[0]			= LINEAR;
		MagFilter[0]			= LINEAR;
		AddressU[0]				= WRAP;
		AddressV[0]				= WRAP;

		TexCoordIndex[1]		= 1;
		TextureTransformFlags[1]= DISABLE;
		Texture[1]				= (alphaTex0);
		ColorOp[1]				= SELECTARG1;
		ColorArg1[1]			= Current;
		AlphaOp[1]				= MODULATE;
		AlphaArg1[1]			= Texture;
		AlphaArg2[1]			= Diffuse;
		MagFilter[1]			= LINEAR;
		MinFilter[1]			= LINEAR;
		MipFilter[1]			= LINEAR;
		AddressU[1]				= WRAP;
		AddressV[1]				= WRAP;
	}
}
