---
title: "URP에서 Outline Shader 만들기"
image: /assets/post/24-07-16-urp-outline-shader/title.png
author: khlee
categories:
    - Unity
layout: post
---

## Outline Shader 구현 방법

Outline shader를 구현하는 방법으로 가장 잘 알려진 2 pass로 outline을 그리는 방법을 사용할 것이다. 요약하면 다음과 같다.

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

## 오브젝트 Scale과 카메라 거리에 Outline의 두께가 영향을 받지 않도록 하기

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

이 outline shader를 cube 오브젝트에 적용하면 아래처럼 이상하게 나온다.

![Cube에 적용한 outline]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-15-154346.png){: width="640" .custom-align-center-img}

그 이유는 cube의 모델이 각진 면을 표현하기 위해 각 꼭지점별로 3개의 vertex를 두고 각각 3방향의 normal이 있기 때문이다.

![Vertex normal]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/vertex_normal.png){: width="540" .custom-align-center-img}

위 그림에서 'a'가 우리가 사용하는 cube 모델의 구조와 같다. 각 꼭지점별로 3개의 normal이 있어서 빛을 받을 때 각진 모서리를 표현할 수 있다. 반대로 각 꼭지점별로 1개의 vertex에 1개의 normal만 있다면 위 그림의 'b' 처럼 모서리에서 부드러운 라이팅을 표현할 수 있다.

그런데 아웃라인을 표현하려면 cube가 위 그림의 'b'와 같은 구조로 되어 있어야 한다. 하지만 그러면 cube의 각진 모서리를 표현할 수 없게 된다. 이를 해결하기 위해 다음과 같은 방법을 사용할 수 있다.

* 모델의 vertex color를 outline을 그리기 위한 normal로 사용하기
* Outline만 그리는 전용 soft(smoothing) edge 오브젝트를 생성하기

첫 번째 방법은 모델을 수정해야 하므로 여기서는 두 번째 방법에 대해 소개할 것이다. 다음 코드는 soft edge 오브젝트를 대상 오브젝트 하위에 생성하고 outline material을 할당하는 기능을 구현한다. ([출처](https://blog.naver.com/mnpshino/221495979665))

{% highlight csharp %}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OutlineCreator : MonoBehaviour
{
    [SerializeField] private Material _outlineMat;
    [SerializeField] private MeshFilter _meshFilter;

    private void Awake()
    {
        GameObject outlineObject;

        outlineObject = new GameObject("Outline");
        outlineObject.transform.parent = transform;

        outlineObject.AddComponent<MeshFilter>();
        outlineObject.AddComponent<MeshRenderer>();
        Mesh tmpMesh = Instantiate(_meshFilter.sharedMesh);
        CreateMeshNormalAverage(tmpMesh);
        outlineObject.GetComponent<MeshFilter>().sharedMesh = tmpMesh;
        outlineObject.GetComponent<MeshRenderer>().material = _outlineMat;

        outlineObject.transform.localPosition = Vector3.zero;
        outlineObject.transform.localRotation = Quaternion.identity;
        outlineObject.transform.localScale = Vector3.one;
    }

    private static void CreateMeshNormalAverage(Mesh mesh)
    {
        Dictionary<Vector3, List<int>> map = new Dictionary<Vector3, List<int>>();

        for (int v = 0; v < mesh.vertexCount; ++v)
        {
            if (!map.ContainsKey(mesh.vertices[v]))
            {
                map.Add(mesh.vertices[v], new List<int>());
            }

            map[mesh.vertices[v]].Add(v);
        }

        Vector3[] normals = mesh.normals;
        Vector3 normal;

        foreach (var p in map)
        {
            normal = Vector3.zero;

            foreach (var n in p.Value)
            {
                normal += mesh.normals[n];
            }

            normal /= p.Value.Count;

            foreach (var n in p.Value)
            {
                normals[n] = normal;
            }
        }

        mesh.normals = normals;
    }
}
{% endhighlight %}

이 스크립트를 대상 오브젝트에 넣고 실행하면 다음과 같이 하위에 outline 오브젝트가 생성된다.

![Outline 오브젝트]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-15-155748.png){: width="200" .custom-align-center-img}
![Outline 오브젝트 모습]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-15-155607.png){: width="540" .custom-align-center-img}

이제 기존의 2 pass outline shader 대신 outline만 전용으로 그리는 shader를 작성한다.

{% highlight c %}
Shader "Custom/OutlineAngled"
{
    Properties
    {
        _OutlineColor("Outline Color", Color) = (1, 0, 0, 1)
        _OutlineThickness("Outline Thickness", Float) = 0.01
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "RenderPipeline" = "UniversalPipeline"
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

            CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            half _OutlineThickness;
            CBUFFER_END

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

            half4 frag(Varyings IN) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
{% endhighlight %}

Pass의 내용은 전부 동일한데, 기존 shader에서 다른 pass는 모두 지우고 outline pass가 기존 파이프라인과 함께 실행되도록 `LightMode` 태그도 지웠다. 하지만 프로젝트에 따라 outline을 별도 render object로 다루고 싶은 경우 `LightMode` 태그를 유지해도 된다.

그리고 마이너한 차이점으로 중간에 `CBUFFER_START(UnityPerMaterial)`와 `CBUFFER_END`가 들어갔는데, 이는 SRP batcher 호환을 위한 것이다. 기존에는 lit shader에 있는 property 목록을 수정할 수 없어서 `_OutlineColor` 같은 property를 `CBUFFER`에 추가하지 못하기 때문에 SRP batcher 호환성을 확보하지 못했는데, 이제 outline 전용 shader를 만들었으므로 모든 property를 `CBUFFER`에 추가해서 SRP batcher 호환성을 확보할 수 있게 되었다.

![각진 오브젝트의 outline]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-15-155800.png){: width="540" .custom-align-center-img}

## Stencil 버퍼를 사용해서 벽을 통과해서 보이는 Outline 만들기

Outline shader를 응용해서 다음 그림과 같이 벽을 통과해서 보이는 outline을 만들어 볼 것이다.

![벽을 통과해서 보이는 outline]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-17-090558.png){: width="540" .custom-align-center-img}

방법은 다음과 같다.

1. 대상 오브젝트를 그릴 때 stencil 버퍼에 특정 값을 쓴다. (여기서는 특정 값으로 2를 사용)
2. 다른 모든 오브젝트들을 그린다.
3. 마지막으로 outline을 그릴 때 stencil 버퍼의 값을 확인하여 특정 값이 써 있다면 해당 픽셀은 그리지 않는다.

대상 오브젝트의 forward pass에서 stencil 버퍼에 값을 쓰도록 수정한다. (관련 stencil 커맨드는 [여기](https://docs.unity3d.com/2022.3/Documentation/Manual/SL-Stencil.html) 참고)

{% highlight c %}
Pass
{
    Name "ForwardLit"
    Tags
    {
        "LightMode" = "UniversalForward"
    }

    Stencil
    {
        Ref 2
        Comp Always
        Pass Replace
        ZFail Replace
    }

    // ...
}
{% endhighlight %}

대상 오브젝트의 outline pass에서 stencil test를 추가한다.

{% highlight c %}
Pass
{
    Name "Outline"
    Tags
    {
        "LightMode" = "Outline"
    }

    Stencil
    {
        Ref 2
        Comp NotEqual
    }

    // ...
}
{% endhighlight %}

Outline pass가 가장 나중에 수행되도록 universal renderer data 에셋에서 outline render object의 `Event`를 `AfterRenderingTransparents`로 수정한다.

![Outline render object]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-17-092456.png){: width="640" .custom-align-center-img}

다만 이 방법을 사용하면 물체의 외부 경계에만 outline이 생기고 아래 그림의 빨간색 사각형 영역처럼 물체의 튀어나온 부분의 outline은 사라진다.

![Outline 차이점]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-17-095212.png)

## 투명한 오브젝트의 Outline 만들기

한편 stencil을 이용하면 투명한 오브젝트의 outline도 만들 수 있다. 기존의 stencil을 사용하지 않는 outline shader를 투명한 오브젝트에 적용해 보면 다음과 같이 흰색의 반투명한 오브젝트 뒤로 outline pass가 그린 빨간색 이 블랜딩되어서 올바르게 렌더링되지 않는다.

![Original transparent object]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-17-093505.png){: width="640" .custom-align-center-img}
*원래의 반투명 오브젝트*{: .custom-caption}

![Outlined transparent object]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-17-093337.png){: width="640" .custom-align-center-img}
*기존의 outline shader를 사용한 반투명 오브젝트*{: .custom-caption}

Stencil을 사용하면 이를 해결할 수 있다. 만약 outline이 벽을 통과해서 보이도록 하고 싶다면 앞서 만든 shader를 그대로 쓰면 된다. 벽을 통과해서 보이도록 하고 싶지 않다면 다음과 같은 순서로 그린다.

1. Stencil 버퍼에서 대상 오브젝트가 렌더링될 영역에 특정 값을 쓴다. (여기서는 특정 값으로 2를 사용)
2. Opaque 오브젝트를 모두 그린다.
3. Outline을 그린다!
4. Transparent 오브젝트를 그린다.

이제 stencil 버퍼에 쓰는 순서(1번)와 대상 오브젝트를 그리는 순서(4번)가 달라졌기 때문에 stencil 버퍼에 쓰는 pass를 새로 만들어야 한다. 이번에는 해당 pass를 shader에 추가하지 않고 universal renderer data 에셋에서 render object를 추가하는 방법으로 구현해 볼 것이다.

![투명한 오브젝트를 위한 render object 설정]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-17-100127.png){: width="850" .custom-align-center-img}

설정할 값들은 다음과 같다.

* 기존 `Outline` render object의 `Queue`를 `Opaque`에서 `Transparent`로 바꾼다.
* 기존 `Outline` render object의 `Layer Mask`를 원하는 대상 오브젝트의 layer로 설정한다.
* 새로운 render object를 만든다. (아래부터는 새로운 render object에 해당하는 내용)
* `Event`를 `BeforeRenderingOpaques`로 설정한다.
* `Queue`를 `Transparent`로 설정한다.
* `Layer Mask`를 원하는 대상 오브젝트의 layer로 설정한다.
* `Overrides`에서 material override를 켜고 커스텀 material을 할당한다.
  * 어차피 프레임에 그려지면 안 되기 때문에 최대한 무거운 연산을 하지 않도록 간단한 shader를 사용할 것이다. [기본적인 unlit shader](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/writing-shaders-urp-basic-unlit-structure.html) 참고
* `Overrides`에서 depth override를 켜고 항상 depth test를 실패하게 설정해서 프레임에 그려지지 않도록 한다.
* `Overrides`에서 stencil override를 켜고 항상 특정한 값을 쓰도록 한다. (특히 Z Fail!)

완성한 화면이다.

![반투명 오브젝트의 outline]({{site.baseurl}}/assets/post/24-07-16-urp-outline-shader/2024-07-17-102650.png){: width="640" .custom-align-center-img}
