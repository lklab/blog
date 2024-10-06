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

## Unity Editor support for Arm-based Windows devices

제목 그대로 ARM 기반 윈도우 운영체제용 유니티 에디터 지원한다는 내용

## DirectX 12 backend improvements

DX12를 사용하는 사용자들은 에디터와 플레이어의 실행에 있어서 CPU 성능 이득을 볼 수 있다. 특히 DX12 그래픽 API가 레이트레이싱 기계 학습 등 최신 GPU 기능 제공한다.

![DX12]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/d20f739d6e3d00613779f9e2f14becc8c62aa4f9-1061x850.avif){: width="640" .custom-align-center-img}

## Unlock the Microsoft platform ecosystem with the Microsoft GDK packages

같은 프로젝트에서 Microsoft gaming platforms를 타겟으로 빌드할 수 있는 Microsoft GDK Tools와 Microsoft GDK API packages를 제공한다.

## XR experiences

MR, Hand 및 Eye 입력, 향상된 재현율(fidelity)이 통합되었다.

## Bringing the physical world into your game

[AR Foundation](https://docs.unity3d.com/Packages/com.unity.xr.arfoundation@6.0/manual/whats-new.html)을 사용하면 크로스 플랫폼 방식으로 실제 세계를 플레이어의 경험에 통합할 수 있다. ARCore의 image stabilization, MR을 위한 meshing과 bounding boxes에 대한 지원도 향상되었다.

![AR Foundation]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/58fc5cab422d37f87f6f4bd88e12fba806086f61-1707x906.avif){: width="640" .custom-align-center-img}

## XR input and interactions

Near-Far Interactor라는 새로운 interactor가 [XR Interaction Toolkit 3.0](https://docs.unity3d.com/Packages/com.unity.xr.interaction.toolkit@3.0/manual/whats-new-3.0.html)에 추가되었다. 이것은 interactor가 프로젝트에서 작동하는 방식을 정의할 때 더 큰 유연성과 모듈성을 제공한다. 그리고 다양한 입력 타입관 처리를 위해 코드의 복잡성이 증가하는 것을 완화해주는 Input Readers를 추가했다. 마지막으로 크로스플랫폼 방식으로 키보드를 구축하고 커스텀할 수 있는 가상 키보드 샘플을 출시할 예정이다.

## Unique hand gestures

[XR Hands](https://docs.unity3d.com/Packages/com.unity.xr.hands@1.5/manual/version-history/whats-new.html) 패키지를 사용하면 일반적인 OpenXR hand gestures 뿐만 아니라 사용자 정의 hand gestures도 구현할 수 있다.

## Improved visual fidelity

Experimental 패키지인 [Composition Layers](https://docs.unity3d.com/Packages/com.unity.xr.compositionlayers@0.5/manual/index.html)를 사용하면 게임의 시각적 재현율(fidelity)을 개선할 수 있다.

## Experimental Multiplayer Center

Multiplayer Center는 멀티플레이 개발에 입문할 수 있도록 설계된 가이드다.

## Multiplayer Play Mode

에디터에서 멀티플레이 테스트를 할 수 있다.

## Multiplayer tools

멀티플레이 관련 시각적 디버깅 도구다.

![Multiplayer tools]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/90dfd216208d8dae7be459a4cfd43b52cb10c04d-2264x1086.avif)

## Experimental Distributed Authority for Netcode for GameObjects

[Distributed Authority](https://docs-multiplayer.unity3d.com/netcode/current/terms-concepts/distributed-authority/) 모드가 추가되었는데, 이것은 Netcode 객체에 대한 소유권 및 권한을 여러 클라이언트에 분산하여 네트워크 시뮬레이션 작업을 클라이언트 간에 분산하도록 한다. 네트워크 상태는 Unity가 제공하는 클라우드 백엔드를 통해 조정된다.

## Netcode for Entities

게임오브젝트에 디버깅용 bounding box를 렌더링할 수 있는 기능과 NetCode 설정 변수를 정의할 수 있는 NetCodeConfig ScriptableObject가 추가되었다.

## Dedicated Server package

프로젝트 1개로 서버와 클라이언트간 전환할 수 있다. 멀티플레이어 역할(Multiplayer roles)을 사용해서 게임오브젝트와 컴포넌트를 클라이언트와 서버에 분배할 수 있다.

[Multiplayer roles](https://docs.unity3d.com/Packages/com.unity.dedicated-server@1.0/manual/multiplayer-roles.html)은 다음과 같은 방식으로 구성된다.

* [Content Selection](https://docs.unity3d.com/Packages/com.unity.dedicated-server@1.0/manual/content-selection.html): UI 및 API를 제공하여 다른 멀티플레이어 역할에서 어떤 콘텐츠(게임 오브젝트, 컴포넌트)가 포함되거나 제거될지를 선택할 수 있다.
* [Automatic Selection](https://docs.unity3d.com/Packages/com.unity.dedicated-server@1.0/manual/automatic-selection): UI 및 API를 제공하여 다른 멀티플레이어 역할에서 자동으로 제거되어야 할 컴포넌트 유형을 선택할 수 있다.
* [Safety Checks](https://docs.unity3d.com/Packages/com.unity.dedicated-server@1.0/manual/safety-checks): 멀티플레이어 역할에 맞게 객체가 제거되어 발생할 수 있는 널 참조 예외를 감지할 수 있는 경고 기능을 활성화한다.

## Experimental Multiplayer Services SDK

Experimental Multiplayer Services SDK는 Unity Gaming Services (UGS)에 의해 지원되며 Relay 및 Lobby와 같은 서비스의 기능을 새로운 "세션" 시스템으로 통합하여 플레이어 그룹이 어떻게 연결되는지를 빠르게 정의할 수 있도록 도와준다.

## Deliver dynamic runtime experiences with AI

Sentis 포함되었다. 다음은 개선사항

* 양자화 사용해서 모델 크기를 최대 75%까지 줄일 수 있다.
* 모델 스케줄링 속도가 2배 향상되었다.
* 메모리 누수와 GC도 줄어들었다.
* 더 많은 ONNX 연산자를 지원한다.

## Memory Profiler

메모리 프로파일러 관련 다음 두 가지 업데이트를 제공한다.

* 그래픽 메모리가 이제 리소스(예: 렌더 텍스처 및 컴퓨트 셰이더)별로 분류되어 측정된다.
* 상주 메모리(resident memory)의 보고가 더 정확해졌다.

![Memory Profiler]({{site.baseurl}}/assets/study/unity_csharp/008_unity6_preview/8cb632dbbde06279d3c16998820c76f983840f5d-991x428.avif)
