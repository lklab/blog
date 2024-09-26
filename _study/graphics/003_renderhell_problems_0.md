---
title: Render Hell – Book III
image: /assets/study/graphics/003_renderhell_problems_0/banner_book_03.jpg
author: khlee
layout: post
last_modified_at: 2023-12-03
---

[Render Hell – Book III](https://simonschreibt.de/gat/renderhell-book3/)를 읽고 정리한 내용이다.

## Experiment

간단히 파일을 복사하는 실험을 해 보자. 1KB짜리 파일 10,000개(총 9.7MB)를 복사하는 것보다 9.7MB짜리 파일 한 개를 복사하는 것이 훨씬 빠르다. 모든 복사 작업에는 파일 전송을 준비하고 메모리를 할당하고 HDD의 헤드가 앞뒤로 이동하는 등 해야 할 일이 있다. 이것이 오버헤드다. 작은 파일을 많이 복사할수록 이런 오버헤드도 엄청나게 많아진다. 많은 메쉬를 그리는 것은 더 복잡하지만 이 예와 비슷하다.

## Many Draw Calls

일반적으로 CPU가 명령을 보내는 것 보다 GPU가 그 명령을 처리(메쉬를 렌더링)하는 것이 더 빠르다. 그 메쉬가 작아질수록 더욱 그렇다. 우리의 애플리케이션은 GPU에 명령을 직접, 그냥 보내지 않는다. 그 사이에 그래픽 API, 드라이버, 운영체제 계층이 있으며 이것은 각 명령마다 CPU에 오버헤드를 추가한다.

> 그리기 호출을 줄이는 주된 이유는 그래픽 하드웨어가 제출할 수 있는 것보다 훨씬 빠르게 삼각형을 변환하고 렌더링할 수 있기 때문입니다. 각 호출마다 몇 개의 삼각형을 제출하면 CPU에 완전히 구속되고 GPU는 대부분 유휴 상태가 됩니다. CPU는 GPU에 충분한 속도를 공급할 수 없습니다.

콘솔 API나 DirectX12, Vulkan, Metal 등의 새로운 API들에서는 이러한 오버헤드들이 많이 낮아졌기 때문에 과거만큼은 나쁘지는 않지만 여전히 작은 작업을 여러번 보내는 것보다 큰 작업을 적게 보내는 것이 더 좋다.

## Many Commands

이런 오버헤드의 한 가지 예는 CPU와 GPU의 통신이다. CPU가 command buffer를 채우면 그 변경사항을 GPU에 알려야 하며 이로 인해 오버헤드가 발생한다. 따라서 드라이버는 push-buffer라는 곳에서 명령을 일괄 처리한다. CPU가 명령을 보내면 그것을 GPU에 하나씩 전달하는 것이 아니라 이 버퍼가 채워질 때 전부를 GPU에게 전달한다.

아래는 잘 이해가 안 가는 내용

> The GPU would (hopefully) have stuff to do (e.g. working on the last chunk of commands) while the CPU builds up the new command buffer. To avoid that the GPU has to wait until the next chunk of work is ready, the driver has some heuristics around the size of the chunks, and sometimes it queues up more than an entire frame until really sending off the work.
> You can find the settings for this buffering in the control panel of the graphics driver (“maximum pre-rendered frames”). The down-side of high amount of frames, is that it we essentially render further in the “past”, our CPU frame already has the latest player input data, but our GPU renders something that is some frames in past. This added latency can be bad for certain content (virtual reality…).

GPU의 유휴 상태를 줄이기 위해 한 번에 보낼 command buffer의 청크 크기를 한 프레임 이상으로 늘려서 프레임을 미리 렌더링한다는 개념인 것 같은데 맞는지?

최신 그래픽 API 또는 콘솔 API는 command buffer를 병렬로 채울 수 있고 드라이버는 이를 차례로(직렬로) GPU에게 전달한다. DirectX 12와 DirectX 11의 command buffer의 주요 차이점은 나중에 드라이버가 명령을 GPU에 빠르게 전달할 수 있는 방식으로 병렬 command buffer를 채운다는 것이다. DirectX 11에서는 드라이버가 명령을 직렬로 전달할 때 더 많은 추적을 수행해야 했기 때문에 command buffer를 병렬로 채우는 것의 이점이 감소했다.

## Many Meshes and Materials

머티리얼이 바뀔 때에는 render state를 변경해야 한다. render state를 변경하는 경우 파이프라인을 전체적 또는 부분적으로 flush해야 한다. 그렇기 때문에 shader나 material property를 변경하는 데에는 비용이 많이 들 수 있다.

서로 다른 메쉬에 서로 다른 material이 있는 경우 CPU, GPU 모두에서 추가적인 setup 시간이 필요하다. 새로운 메쉬에 대한 render state를 변경하고 draw call을 한 다음 다음 메쉬에 대한 render state를 변경하고 draw call을 하는 등의 작업을 수행한다.

Render state를 변경하면 파이프라인의 일부가 flush되는 경우가 있다. 따라서 현재 render state에 따라 처리되고 있는 모든 메쉬는 새 메쉬가 렌더링되기 전에 완료되어야 한다. 따라서 많은 수의 정점을 가진 메쉬를 처리하는 것이 아닌 적은 양의 메쉬를 처리할 때마다 render state를 변경하는 경우 더 느려지게 된다.

Draw call을 설정하는 최소 시간으로 인해 2개의 삼각형을 가진 메쉬랑 200개의 삼각형을 가진 메쉬를 그리는 데에는 거의 차이가 나지 않는다. GPU는 매우 빠르므로 CPU가 메쉬를 준비하는 데 걸리는 시간보다 더 빠르게 렌더링할 수 있다.

## Meshes and Multi-Materials

하나의 메쉬에 여러 개의 materal이 할당된 경우 메쉬는 여러 조각으로 나뉜다. 그리고 draw call은 그 메쉬 조각 하나하나에 대해 수행된다.

## Single Graphics Command Processor

CPU에서 병렬 "청크"를 전달하더라도 모든 그래픽 관련 명령은 GPU의 여러 병렬 장치에 배포되기 전에 직렬로 한 번 처리된다.

## Thin Triangles

그래픽 하드웨어는 하나의 삼각형에 속하는 2×2 쿼드를 처리한다. 해당 fragment 중 일부가 삼각형을 덮지 않으면 해당 fragment는 무시된다.

![rasterizing]({{site.baseurl}}/assets/study/graphics/003_renderhell_problems_0/rasterizing.png){: width="480" .custom-align-center-img}

따라서 길고 가는 삼각형 같은 것이 왜 성능이 안 좋은지 짐작할 수 있다. 실제로 화면에 보여지지 않는 fragment를 그리게 되기 때문이다. 비용이 많이 드는 fullscreen post processing의 경우 두 개의 삼각형 대신 모서리가 화면 밖에 있는 거대한 삼각형으로 렌더링하므로 화면을 통화하는 대각선이 없게 된다. -> 버려지는 fragment가 없다.

## Useless Overdraw

폴리곤이 soft-alpha로 렌더링 되고 텍스쳐의 큰 영역이 100% 투명한 경우 오버드로우가 발생해서 많은 성능이 낭비될 수 있다. 예를 들어 가지나 나뭇및 텍스쳐를 그리거나 전체 화면 Quad를 사용하여 비네팅을 렌더링하는 경우 발생할 수 있다.

## Mobile vs. PC

많은 모바일 기기는 블렌딩과 안티앨리어싱 성능이 좋지만 지오메트리가 많으면 어려움이 있다. 데스크탑/콘솔 GPU의 경우는 이와 약간 반대다. 그 이유는 모바일 GPU의 경우 "on-die/on-chip memory"(작은 cache인)를 중간 frame-buffer로 사용하기 때문이다.(Xbox360도 이러한 방식을 사용한다.) 따라서 블렌딩과 안티앨리어싱을 적은 성능으로 수행할 수 있다.

그러나 Full-HD로 렌더링하는 데 필요한 메모리를 칩에 담기에는 너무 비싸므로 프레임을 한 번에 렌더링하지 않고 작은 타일(또는 청크)로 렌더링한다. 한 번에 한 타일씩 렌더링되고 각 타일이 완료된 후 타일 캐시에서 최종 frame-buffer로 복사된다. 이는 또한 데스크탑 GPU처럼 frame-buffer 메모리에 직접 복사하는 것보다 power-efficient 하다.

단점은 지오메트리가 여러 타일에 걸쳐 있을 수 있으므로 하나의 지오메트리를 여러 번 처리해야 한다는 것이다. 이는 많은 정점의 비용이 높아진다는 것을 의미한다.

그러나 이런 접근 방식은 UI와 텍스트 렌더링에 적합하다. UI와 텍스트(textured quad)는 블렌딩이 많기 때문이다.
