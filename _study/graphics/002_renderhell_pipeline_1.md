---
title: Render Hell – Book II (Shaders)
image: /assets/study/graphics/001_renderhell_pipeline_0/banner_book_02.jpg
author: khlee
layout: post
last_modified_at: 2023-11-25
---

[Render Hell – Book II](https://simonschreibt.de/gat/renderhell-book2/)를 읽고 정리한 내용이다.

## Vertex Shader

Vertex shader는 하나의 정점을 관리하며, 프로그래머가 프로그래밍한 대로 정점을 변경하는 쉐이더 프로그램이다. 한 프로그램 인스턴스로 모든 데이터를 다루는 일반적인 소프트웨어와는 다르게, 쉐이더 프로그램은 모든 정점에 대해 프로그램 인스턴스가 하나씩 실행된다. 각 프로그램은 Streaming Multiprocessor가 관리하는 하나의 스레드에서 실행된다.

Vertex shader는 정점과 정점의 파라미터들(position, color, uv 등)을 프로그래머가 원하는대로 변경한다.

## Patch Assembly

지금가지는 정점들을 각각의 단일 정점들로 취급했다. 여기서부터는 **Tessellation** 이 사용될 때의 과정이다 Tessellation이 사용되지 않는다면 Primitive Assembly 과정으로 건너뛴다.

첫 번째로 개별 정점에 대한 패치를 생성한다. 이런 식으로 기하학적인 정보(Geometric detail)을 추가하는 것이 가능하다. 패치를 만드는 정점 수는 최대 32개까지 프로그래머가 정의한다.

## Hull Shader

Hull shader는 방금 생성한 패치에 속한 정점들을 가져와서 tessellation factor를 계산한다. 예를 들어서 카메라와의 거리에 따라 tessellation factor를 계산할 수 있다. 하드웨어는 3가지 기본 모양(Quad, Triangle, Series of lines)만 테셀레이션할 수 있기 때문에 쉐이더 코드는 tessellator가 어떤 모양을 사용할지에 대한 정보도 포함되어 있다. 결과적으로 tessellation factor는 하나만 있는 것이 아니고 외부 측면과 "내부" 측면에 대해 계산된다. 나중에 의미 있는 형상을 생성할 수 있도록 Hull shader는 위치를 관리하는 Domain shader에 대한 입력값도 계산한다.

## Tessellation

이제 tessellation factor를 통해 패치를 어떤 모양으로 얼마나 많이 나눌지 알고 있다. Polymorph Engine이 이 정보를 사용해서 실제 작업을 수행한다. 이로부터 많은 새로운 정점이 생성된다. 이 각각의 정점은 Gigathread 엔진으로 전송되어서 GPU 전체에 분산되고 Domain shader에 의해 처리된다.

Geometry detail을 3D 모델에 직접 입력하지 않는 이유는 두 가지가 있다. 첫 번째 이유는 메모리에 접근하는 것이 느리기 때문이다. 따라서 모든 속성(position, normal, uv)을 가져오는 대신 더 적은 양의 데이터(patch corner vertices + displacement logic or textures, which support mipmaps, compression 등)에서 세부 정점을 생성하는 것이 좋다. 두 번째 이유는 Tessellation을 사용하면 카메라와의 거리에 따라 모델의 디테일한 정도를 조정할 수 있어서 유연하기 때문에다. 그렇지 않으면 너무 작거나 보이지 않는 삼각형에 속하는 많은 정점들을 계상해야 할 수 있다.

## Domain Shader

Domain shader에서 Tessellation이 생성한 정점의 최종 위치가 계산된다. 프로그래머가 displacement map을 사용하고 싶다면 이 때 적용된다. Domain shader의 입력을 Hull shader의 출력(ex. 패치 정점)과 tessellation의 무게중심 좌표다. 이 좌표화 패치 정점을 사용해서 정점의 새 위치를 계산하고 변위를 적용할 수 있다. Vertex shader와 유사하게 Domain shader는 다음 쉐이더 단계(Geometry shader 또는 Fragment shader)로 전달될 데이터를 계산한다.

## Primitive Assembly

정점들을 primitive(triangle, line or point)로 모은다. 이 정점들은 vertex shader에서 출력되었거나 테셀레이션이 사용된 경우 domain shader에서 출력된 것이다.

현재 어떤 모드(triangle, line or point)인지는 애플리케이션에서 이 드로우콜에 정의되어 있다. 일반적으로 이 primitive를 최종 처리와 rasterzation를 위해 전달하지만 선택적으로 Geometry shader로 전달할 수 있다.

## Geometry Shader

Geometry shader는 primitive를 다루는 마지막 단계다. Hull shader와 비슷하게 이 쉐이더는 primitive의 정점들을 입력으로 받는다. 이 쉐이더는 해당 정점들을 수정하고 새로운 정점을 생성할 수도 있다. 또한 primitive mode를 변경할 수도 있다. 예를 들어 점을 두 개의 삼각형으로 바꾸거나 cube의 (보이는) 세 면으로 바꿀 수 있다. 그러나 새로운 정점이나 삼각형을 많이 만드는 것은 좋지 않다. 이런 작업은 테셀레이션에게 맡기는 것이 가장 좋다.

이 단계는 Rasterization 전에 primitive를 다루는 마지막 단계라는 점에서 특별하다. 예를 들어 이 단계는 현재 복셀회(voxelization)에서 핵심적인 역할을 한다.

## Viewport Transform & Clipping

Viewport transform은 삼각형이 모니터의 실제 해상도에 맞도록 변환하는 과정이다.

Primitive가 화면의 경계에 겹치는 경우 삼각형이 잘려야 한다. Rasterizer는 작업 영역 내의 삼각형만 처리할 수 있기 때문에 clipping이 수행된다.

## Triangles Journey

이것은 별도의 단계는 아니지만 흥미로운 점이 있어서 별도의 섹션으로 분리했다.

이 시점에서는 삼각형을 형성하는 정확한 position, shading 등을 알고 있다. 이 삼각형은 "채색"되어야 하며 이를 위해 화면의 어떤 픽셀이 삼각형에 포함되는지 알아야 한다. 이는 Rasterizer에 의해 수행된다. 삼각형이 충분히 크다면 그 삼각형을 래스터화하기 위해 여러 개의 Rasterizer가 동작할 수 있다는 것이 중요하다. 따라서 모든 Rasterizer는 화면의 특정 영역을 담당한다. 그리고 삼각형이 어떤 Rasterizer가 담당하는 영역에 포함되거나 걸치는 경우 이 Rasterizer에게로 삼각형이 전송된다.

## Rasterizing

Rasterizer는 자신이 담당하는 삼각형을 수신하면 먼저 삼각형의 앞면이 앞쪽을 향하고 있는지 확인한다. 그렇지 않으면 삼각형을 버린다.(backface culling) 삼각형이 "유효"한 경우 Rasterizer는 정점을 연결하는 선을 통해 fragment를 생성한다.

Fragment는 생성된 후 Z-cull unit으로 전송된다. Z-cull unit은 프레임 버퍼의 기존 픽셀과 깊이 값을 비교한다. 만약 프레임 버퍼의 뒤에 있는 픽셀의 경우 파이프라인에서 제거되므로 다음 단계(pixel shader)로 전달되지 않는다.

## Pixel Shader

Fragment는 이제 "채워질" 수 있다. 각각의 Fragment에 대해 새로운 스레드가 생성되고 코어에 다시 배포된다.(vertex shader에서 모든 vertex에 대해 수행된 것 처럼)

32개의 픽셀 스레드로 일괄 처리된다. 8개의 2x2 pixel quads로 생각하는 것이 더 좋다. 이것이 pixel shader에서 처리하는 가장 작은 단위다.

코어가 작업을 완료하면 결과를 레지스터에 기록하고 Raster output 단계를 위해 캐시에 전송한다.

## Raster Output

Raster output은 L2 캐시에서 VRAM에 있는 프레임 버퍼로 이동하는 단계다. 이 작업은 “Raster Output” Unit(ROP)에 의해 수행된다. 

ROP는 단순히 픽셀 데이터를 전송하는 것 외에도 pixel blending, coverage information for anti aliasing and “atomic operations” 등의 작업도 처리한다.
