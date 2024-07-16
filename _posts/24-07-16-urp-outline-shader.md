---
title: "URP에서 Outline Shader 만들기"
image: /assets/post/24-07-16-urp-outline-shader/title.png
author: khlee
categories:
    - Unity
layout: post
---

## Outline Shader 구현 방법

Outline shader를 구현하는 방법으로 가장 잘 알려진 2 pass로 outline을 그리는 방법을 사용한 것이다. 요약하면 다음과 같다.

* 기존 shader에 outline을 그리는 pass를 추가
* 앞면을 컬링해서 뒷 면만 그리기
* 추가한 pass의 vertex shader에서 각 vertex를 vertex normal 방향으로 이동하기

## Outline Shader 구현하기

대상 오브젝트를 그리는 shader에 pass를 추가할 것이므로, 대상 오브젝트를 그릴 shader가 하나 필요하다. 보통은 cel shading과 함께 ouline을 그리겠지만 여기서는 URP 기본 shader인 Lit shader를 사용할 것이다. `Packages/com.unity.render-pipelines.universal/Shaders/Lit.shader` 경로에서 Lit shader를 복사한 다음 원하는 위치에 붙여넣는다. 그리고 다음과 같이 이름을 수정하고 pass를 추가한다.

{% highlight c %}
Shader "Custom/OutlineLit"
{
    Properties
    {
        // ...

        // Outline 관련 property 추가
        _OutlineColor("Outline Color", Color) = (1, 0, 0, 1)
        _OutlineThickness("Outline Thickness", Float) = 0.1
    }

    SubShader
    {
        // ...

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // ...
        }

        // Pass 추가
        Pass
        {
            Name "Outline"
            Tags
            {
                "LightMode" = "Outline"
            }

            // ...
        }
    }
}
{% endhighlight %}

이제 outline pass를 작성한다.

{% highlight c %}
Pass
{
    Name "Outline"
    Tags
    {
        "LightMode" = "Outline"
    }

    Cull Front

    HLSLPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    struct Attributes
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
    };

    struct Varyings
    {
        float4 positionHCS  : SV_POSITION;
    };

    half4 _OutlineColor;
    half _OutlineThickness;

    Varyings vert(Attributes IN)
    {
        Varyings OUT;

        float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz + IN.normalOS.xyz * _OutlineThickness);
        OUT.positionHCS = TransformWorldToHClip(positionWS);

        return OUT;
    }

    half4 frag(Varyings IN) : SV_Target
    {
        return _OutlineColor;
    }
    ENDHLSL
}
{% endhighlight %}

`Tags`의 `LightMode`는 `Outline`으로 정했다. 어떤 이름으로 해도 상관 없지만 다음에 render object를 추가할 때 해당 이름을 동일하게 사용해야 한다.

`Cull Front`로 뒷면만 그리도록 한다.

Vertex shader에서는 `IN.positionOS.xyz + IN.normalOS.xyz * _OutlineThickness`를 통해 object space에서 vertex의 위치를 normal 방향으로 이동한다. 그리고 기존과 같이 `TransformObjectToWorld()` 함수를 통해 clip space로 변환하면 된다.

Fragment shader에서는 간단하게 outline 색상을 반환하도록 하면 된다.

이제 universal renderer data 에셋을 열어서 방금 추가한 outline pass가 동작하도록 해야 한다.

![Outline pass 추가]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/add_render_object.png){: width="640" .custom-align-center-img}

현재 활성화되어 있거나 타겟 플랫폼에서 활성화 될 모든 universal renderer data 에셋을 열고 "Add Renderer Feature" 버튼을 눌러서 새로운 Render Object를 추가한다. 그 후 위 그림과 같이 설정하면 된다.

`LightMode Tags`에 outline pass에서 지정한 LightMode Tag를 추가한다. 그리고 `Layer Mask`를 원하는 레이어로 설정한다.

마지막으로 `Event`를 통해 해당 pass가 어느 시점에 실행될지 지정할 수 있다.

* Opaque 오브젝트보다 먼저 그리는 경우 outline pass에서 오브젝트의 뒷면을 전부 그린 후 그 위에 원본 오브젝트가 그려지므로 overdraw가 발생한다.
* Skybox보다 나중에 그리는 경우 skybox가 그려진 부분에 outline을 그리므로 overdraw가 발생한다.
* 투명한 오브젝트보다 나중에 그리는 경우 outline보다 앞에 투명한 오브젝트가 있더라도 그 위에 아웃라인이 그려지므로(투명한 오브젝트는 Z write를 하지 않는다!) 부자연스럽게 그려진다.

여러모로 Opaque 오브젝트 다음에 그리는 것이 가장 괜찮아 보인다.

![완성된 화면]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/title.png){: width="640" .custom-align-center-img}

## 오브젝트 scale과 카메라 거리에 Outline의 두께가 영향을 받지 않도록 하기

지금까지 만든 outline shader는 오브젝트의 scale이나 카메라와의 거리에 따라 "화면에 보여지는" outline의 두께가 달라진다.

![두께가 달라지는 outline]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/dif_outline.png)

프로젝트에 따라 크게 문제가 없을 수도 있지만, 여기서는 scale이나 카메라 거리에 상관 없이 항상 동일한 두께로 아웃라인이 그려지도록 수정해 볼 것이다.

오브젝트의 scale에 영향을 받지 않게 하려면 vertex를 normal 방향으로 옮기는 계산을 object space가 아닌 world space에서 하면 된다.

{% highlight c %}
Varyings vert(Attributes IN)
{
    Varyings OUT;

    float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
    positionWS += normalWS * _OutlineThickness;
    OUT.positionHCS = TransformWorldToHClip(positionWS);

    return OUT;
}
{% endhighlight %}

`TransformObjectToWorld()` 함수와 `TransformObjectToWorldNormal()` 함수를 통해 vertex와 normal을 각각 world space로 변환해 준 뒤 연산을 수행하였다. 이제 world space 좌표를 clip space로 변환해야 하므로 기존의 `TransformWorldToHClip()` 함수 대신 `TransformWorldToHClip()` 함수를 사용해야 한다.

카메라와의 거리에 영향을 받지 않게 하려면 카메라와의 거리에 따른 보정을 해야 한다. 카메라와의 거리가 멀수록 vertex를 더 많이 이동해서 결과적으로 화면에 보여지는 outline의 두께가 동일하도록 하면 된다. 이 때 카메라 위치와 오브젝트의 직선 거리를 사용해서 보정하면 오브젝트가 화면 가장자리로 갈수록 아웃라인이 화면에 더 두껍게 출력될 것이다. 다음 그림을 보자

![거리에 따라 화면에 보여지는 크기]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-16-191119.png){: width="480" .custom-align-center-img}

그림에서 빨간 선에 위치하는 모든 것은 화면에 동일한 크기로 출력된다. 카메라의 뷰 프러스텀이 사각뿔 형태이기 때문이다. 따라서 보정할 값으로 검정색의 직선거리 대신 파란색 화살표를 사용할 것이다. 그 길이는 검정색 화살표 벡터에 카메라의 forward 벡터를 내적해서 얻을 수 있다. 코드로 구현하면 다음과 같다.

{% highlight c %}
Varyings vert(Attributes IN)
{
    Varyings OUT;

    float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
    float3 positionView = positionWS - GetCameraPositionWS();
    float distToCam = dot(GetViewForwardDir(), positionView);
    positionWS += normalWS * distToCam * _OutlineThickness;
    OUT.positionHCS = TransformWorldToHClip(positionWS);

    return OUT;
}
{% endhighlight %}

`GetCameraPositionWS()` 함수를 통해 world space에서의 카메라 위치를 가져와서 카메라를 기준으로 상대적인 vertex 위치인 `positionView`를 계산한다. 그 후 `GetViewForwardDir()` 함수를 통해 얻어온 카메라의 forward 벡터와 내적해서 보정에 사용할 거리 값을 가져올 수 있다.

![두께가 일정한 outline]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-16-192445.png)

이제 outline이 오브젝트의 scale이나 카메라와의 거리와 관계 없이 일정한 두께로 출력된다.

## Hard(Sharp) Edge 오브젝트에 Outline 만들기

## Stencil 버퍼를 사용해서 벽을 통과해서 보이는 Outline 만들기

## 투명한 오브젝트의 Outline 만들기
