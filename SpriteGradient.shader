Shader "Sprites/Gradient"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Sprite Texture", 2D) = "white" {}
        _GradientColor1 ("Gradient Color 1", Color) = (1, 1, 1, 1)
        _GradientColor2 ("Gradient Color 2", Color) = (0, 0, 0, 1)
        _GradientAngle ("Gradient Angle", Range(0, 360)) = 90
        _GradientPivotX ("Gradient Pivot X", Range(0, 1)) = 0.5
        _GradientPivotY ("Gradient Pivot Y", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"

            sampler2D _MainTex;            
            float4 _GradientColor1;
            float4 _GradientColor2;
            float _GradientAngle;
            float _GradientPivotX;
            float _GradientPivotY;

            struct vertexInput
            {
                float4 vertexLocalPosition : POSITION;
                float2 textureCoordinates : TEXCOORD0;
                float4 spriteRendererColor : COLOR;
            };

            struct vertexOutput
            {
                float4 vertexClipSpacePosition : SV_POSITION;
                float2 textureCoordinates : TEXCOORD0;
                float4 spriteRendererColor : COLOR;
            };

            float2 RotateCoordinatesAroundPivot(float2 textureCoordinates, float2 pivot, float angle)
            {
                float angleInRadians = radians(angle);
                float cosine = cos(angleInRadians);
                float sine = sin(angleInRadians);
                float rotatedX = pivot.x + (textureCoordinates.x - pivot.x) * cosine - (textureCoordinates.y - pivot.y) * sine;
                float rotatedY = pivot.y + (textureCoordinates.x - pivot.x) * sine - (textureCoordinates.y - pivot.y) * cosine;
                return float2(rotatedX, rotatedY);
            }

            vertexOutput vertex(vertexInput input)
            {
                vertexOutput output;
                output.vertexClipSpacePosition = UnityObjectToClipPos(input.vertexLocalPosition);                
                output.textureCoordinates = input.textureCoordinates;
                output.spriteRendererColor = input.spriteRendererColor;
                return output;
            }

            float4 fragment(vertexOutput data) : SV_Target
            {                
                float4 originalColorWithTint = tex2D(_MainTex, data.textureCoordinates) * data.spriteRendererColor;
                originalColorWithTint.rgb *= originalColorWithTint.a;

                float2 rotatedTextureCoordinates = RotateCoordinatesAroundPivot(data.textureCoordinates, float2(_GradientPivotX, _GradientPivotY), _GradientAngle);              
                float4 gradientColor = lerp(_GradientColor1, _GradientColor2, clamp(rotatedTextureCoordinates.x, 0, 1));                                           

                float4 finalMergedColor = lerp(originalColorWithTint, gradientColor, gradientColor.a);
                finalMergedColor.a = originalColorWithTint.a;
                finalMergedColor.rgb *= originalColorWithTint.a;                

                return finalMergedColor;
            }
            ENDCG
        }
    }
}