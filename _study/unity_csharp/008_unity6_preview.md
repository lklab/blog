---
title: 'Unity 6 Preview 주요 하이라이트'
image: /assets/study/unity_csharp/008_unity6_preview/title.avif
author: khlee
layout: post
last_modified_at: 2024-10-05
---

[Unity 6 Preview is now available](https://unity.com/blog/engine-platform/unity-6-preview-release) 블로그를 보고 작성한 내용입니다.

## Boost rendering performance

URP, HDRP 성능이 크게 향상되어 30~50% 정도의 CPU 부하를 줄일 수 있다.

[GPU Resident Drawer](https://forum.unity.com/threads/gpu-driven-rendering-in-unity.1502702/)를 사용하면 복잡한 수동 최적화 없이 크고 풍부한 월드를 효율적으로 렌더링할 수 있다.

![GPU Resident Drawer]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/3ed6c0e817af40a0854f586a91826f653402641c-1571x877.avif)

**GPU Occlusion Culling**을 사용하면 각 프레임마다 overdraw를 줄일 수 있다.

<iframe class="video" src="https://www.youtube.com/embed/H3SrN6dYwo8" allowfullscreen frameborder="0"></iframe>

**Spatial-Temporal Post-Processing (STP)**을 사용하면 GPU 성능을 최적화할 수 있다. STP는 낮은 해상도로 렌더링된 프레임을 재현율(fidelity) 손실 없이 다양한 플랫폼에서 일관된 고품질 컨텐츠를 제공하도록 설계되었다.

![STP]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/f391540ff2f3e80cc9e364ea47dae31e2fa00655-1884x906.avif)

URP의 **Render Graph**는 유지관리를 단순화하고 성능을 향상시키는 새로운 프레임워크이자 API이다. 특히 아래와 같은 **Render Graph Viewer**를 사용하면 엔진의 렌더 패스와 리소스 사용량을 에디터에서 직접 확인할 수 있다.

![Render Graph Viewer]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/47a8bdc109f09ff9270dc7c2e3c0f2d33051bd26-2159x989.avif)

URP의 **Foveated Rendering API**를 사용하면 특정 시선 밖에 있는 영역에 대한 fidelity를 낮춰서 GPU 성능을 향상시킬 수 있다. Fixed Foveated Rendering을 사용하면 화면 중앙을 시선 영역으로 설정하고, Gazed Foveated Rendering을 사용하면 사용자의 시선을 추적하여 시선 영역을 계산한다.

![Foveated Rendering API]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/8bce5fdde5038e01988f1bb420680b5617e2c15a-1164x818.avif){: width="640" .custom-align-center-img}

**Volume framework enhancements**은 URP와 HDRP 모두에서 사용할 수 있으며, CPU 성능을 최적화하여 낮은 성능의 하드웨어에서도 실행 가능하게 해 준다. 이것은 글로벌, 품질별 레벨 볼륨을 HDRP 처럼 URP에서도 향상된 UI를 통해 사용할 수 있게 해 준다. 또한 **Custom post-processing**을 사용하여 custom fog와 같은 자신만의 효과를 구현하는 것이 더 쉬워졌다.

![Volume framework enhancements]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/6a5b3386cc47a992f0578dc5f85d66bae912cef8-1790x973.avif){: width="640" .custom-align-center-img}

## Lighting enhancements

**Adaptive Probe Volumes (APV)**은 global illumination을 구현하는 새로운 방법을 제공한다. 또한 **APV Scenario Blending**을 사용하면 베이크된 probe volume data를 블렌딩해서 낮/밤 또는 조명 on/off을 구현할 수 있다.

<iframe class="video" src="https://www.youtube.com/embed/lOZxzP6i5nc" allowfullscreen frameborder="0"></iframe>

**APV Sky Occlusion**을 사용하면 APV scenario blending에 비해 하늘의 static indirect lighting에서 더 많은 색상 변화를 얻을 수 있다.

<iframe class="video" src="https://www.youtube.com/embed/oJR9pSXg2vY" allowfullscreen frameborder="0"></iframe>

**APV disk streaming**은 이제 AssetBundles과 Addressables를 지원한다.

**Probe Adjustment Volumes tool**를 사용해서 APV를 튜닝하고 빛 누수를 고칠 수 있다. 볼륨 내의 프로브를 조정할 수 있는 방법에는 Override Sample Count와 Invalidate Probes이 있다. 원하는 프로브를 숨길 수도 있고, 영향을 받는 프로브에 대해서만 프로브 데이터를 미리 보고 직접 베이크할 수 있다.

**C# Light Probe Baking API**를 사용해서 베이킹할 때 실행시간과 메모리 사이의 균형을 맞출 수 있다. [예시](https://github.com/Unity-Technologies/Graphics/blob/9415add/Packages/com.unity.render-pipelines.core/Editor/Lighting/ProbeVolume/ProbeGIBaking.LightTransport.cs#L583)

<iframe class="video" src="https://www.youtube.com/embed/N4sppAGAyUA" allowfullscreen frameborder="0"></iframe>

## Richer high-fidelity environments

HDRP에서는 time-of-day scenarios를 위해 일출/일몰 렌더링이 향상되었다. Ozone layer와 Atmospheric scattering를 추가해서 장거리 안개를 개선한다.

<iframe class="video" src="https://www.youtube.com/embed/7EKv2rlBT8o" allowfullscreen frameborder="0"></iframe>

<iframe class="video" src="https://www.youtube.com/embed/Dpz-Qie_THM" allowfullscreen frameborder="0"></iframe>

**Underwater Volumetric fog**을 지원하면서 물 표현이 더 개선되었다. 성능 최적화를 위해 CPU에서 시뮬레이션하는 대신 몇 프레임의 지연을 감수하고 GPU의 시뮬레이션을 읽어올 수 있다. 또한 물에 지형, 식물 등이 반사되는 것을 렌더링하기 위해 레이트레이싱과 스크린공간 효과를 혼합하는 방식을 지원한다.

<iframe class="video" src="https://www.youtube.com/embed/Tnb3DgyWRPI" allowfullscreen frameborder="0"></iframe>

## Shader Graph artist workflows

**Heatmap color mode**를 사용해서 shader graph 내에 GPU 연산을 많이 소모하는 노드를 빠르게 식별할 수 있다.

![Heatmap color mode]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/468abc296878db87f89c3c3d86f2bc4905f04cca-1020x574.avif)

## Quality-of-life improvements to the Unity build window, plus all-new build profiles

**Build profiles**이라는 기능이 추가되었다. 각 profile마다 빌드할 씬 목록을 설정할 수 있게 된다. 또한 각 profile에 사용자 정의 스크립트를 설정해서 빌드와 에디터 모드의 동작을 미세조정할 수 있다. 그리고 각 profile에 대해 player setting를 설정해서 다양한 배포마다 다른 설정값을 사용할 수 있는 기능도 제공한다.

**Platform Browser**를 사용하면 유니티가 지원하는 플랫폼을 확인하고 build profile을 생성할 수 있다.

![Platform Browser]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/09ff2f21b334ec4f9af700fb5fd04cddf0e64a5c-792x707.avif){: width="640" .custom-align-center-img}

## Expand mobile gaming reach with web runtimes

Unity 6 Preview에서는 모바일에서의 browser도 지원한다. 또한 네이티브 앱에 게임을 웹뷰로 임베딩하거나 progressive web app template을 사용해서 네이티브 앱처럼 만들 수 있다. 또한 Android App Bundle에 디버그 심볼을 포함할 수 있는 기능이 추가된다.

![Mobile gaming with web runtimes]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/30ceac9f756a65410d747274b230f48683c94abc-960x701.avif){: width="640" .custom-align-center-img}

## Early access to the WebGPU backend

WebGPU는 컴퓨트 쉐이더와 같은 최신 GPU 기술을 웹에 노출하려는 목적으로 설계되었다. 아직 WebGPU는 실험적 기능이므로 프로덕션에 사용하는 것은 좋지 않다.

![WebGPU]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/a484e6382320712c8ac99818017121ad3f6f1ce1-3584x2012.avif){: width="640" .custom-align-center-img}
