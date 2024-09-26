---
title: Render Hell – Book I
image: /assets/study/graphics/000_renderhell_overview_0/banner_book_01.jpg
author: khlee
layout: post
last_modified_at: 2023-11-17
---

[Render Hell – Book I](https://simonschreibt.de/gat/renderhell-book1/)을 읽고 정리한 내용이다.

## 더 빠른 메모리로 데이터 복사

처음에 프로그램의 모든 데이터는 HDD 등의 비휘발성 메모리에 저장되어 있다. 프로그램을 실행하면 더 빠른 접근(Access)를 위해 RAM에 로드된다. 그 데이터 중에서 메쉬나 텍스쳐는 GPU에서 더 빠른 접근을 할 수 있도록 VRAM에 저장된다.

![Mem copy]({{site.baseurl}}/assets/study/graphics/000_renderhell_overview_0/mem_copy.png){: width="480" .custom-align-center-img}

텍스쳐가 VRAM에 복사되고 난 후 더이상 RAM에 남아있지 않아도 되는 경우 RAM에서 텍스쳐를 버릴 수 있다. 그러나 텍스쳐가 곧 다시 필요하게 되는 경우 HDD에서 다시 로드하는 데에는 시간이 오래 걸리므로 RAM에 상주하도록 해야 한다. 또한 Unity에서 텍스쳐의 read write enable를 켜면 CPU에서 접근할 수 있다는 의미이므로 RAM에 상주하게 된다. 메쉬의 경우 충돌 검사 등을 위해 CPU에서 사용될 가능성이 높으므로 RAM에서 제거하지 않는다.

그러나 여전히 VRAM은 GPU에서 접근하기에 느려서 L2 캐시, L1 캐시 등 더 빠른 메모리로 데이터를 복사한다. 그러나 이들 메모리는 빠른 대신 비싸기 때문에 큰 용량을 가질 수 없다. 마지막으로 GPU 코어와 가장 가까운 메모리인 레지스터로 복사된다. 레지스터는 GPU 코어가 직접 연산할 데이터를 가져오고 연산 결과를 저장하는 데에 사용된다.

이렇게 데이터를 다른 메모리로 복사해서 연산해야 하는 이유는 접근속도와 비용/용량의 타협을 위해서다. 저렴하고 용량이 많은 메모리는 접근속도가 느리고, 접근속도가 빠른 메모리는 비싸고 용량이 적다. 큰 용량과 빠른 접근속도의 장점을 취하기 위해 이러한 메모리 계층 구조가 사용된다.

## Render State

CPU는 메쉬를 어떻게 그릴지에 대한 전역 데이터를 설정할 수 있는데, 이 데이터 묶음이 Render state다. Render state에는 다음과 같은 데이터를 포함한다.

> vertex and pixel shader, texture, material, lighting, transparency, etc.

메쉬는 이 Render state에 따라 그려진다. 만약 서로 다른 메쉬를 그릴 때 Render state를 바꾸지 않는다면 모두 동일한 쉐이더, 텍스쳐, 머티리얼로 그려질 것이다.

## Draw Call

텍스쳐와 메쉬가 VRAM에 올라가고, Render state를 설정해서 준비가 완료되면, CPU는 GPU에게 어떤 **한 메쉬**를 그리라고 명령할 수 있다. 이것이 Draw call이다. 이 명령에는 어떤 메쉬를 그릴지 지정(point)하는 정보만 포함된다. 그 외에 머티리얼 같은 정보는 Render state에 이미 있기 때문이다. 메쉬도 VRAM에 저장되어 있으며, Draw call은 이 메쉬에 대한 참조 정보만 들어가 있다.

![Draw Call]({{site.baseurl}}/assets/study/graphics/000_renderhell_overview_0/draw_call.png){: width="480" .custom-align-center-img}

## Pipeline

GPU가 Draw call을 받으면 Render state와 메쉬 정보를 읽어서 화면에 픽셀을 그린다. 이 과정이 Pipeline이다. Pipeline은 "논리적으로" 다음과 같은 과정으로 이루어져 있다.

1. Receive Vertices
2. Transformation
3. Vertex Interpolants
4. Create Triangles
5. Create Fragments
6. Shade Fragments
7. Output to Frame Buffer
8. Show Frame Buffer

이 과정에서 수천개의 vertex를 처리하고 수백만개의 픽셀을 그리게 된다. 이러한 과정이 매우 빠르게(30fps라면 1초에 화면 전체를 30번 그려야 한다.) 일어나야 하므로 각각의 vertex에 대해, 각각의 픽셀에 대해 "동시에" 계산하는 것이 요구된다. CPU는 코어 수가 6-8개 정도라 이렇게 동시에 많은 데이터를 처리하기에는 부적합하다. 반면 GPU에는 최소 수천개의 코어가 존재하므로 이러한 작업에 더 어울린다. GPU의 코어는 CPU 코어처럼 복잡하지는 않지만 vertex와 픽셀을 처리하는 데에는 적합하도록 만들어져 있다.

## Command Buffer

CPU는 GPU에게 명령을 전달할 때 GPU가 작업을 끝내기를 기다리지 않아도 되도록 Command buffer를 사용한다. CPU가 Command buffer에 명령을 순서대로 넣으면 GPU가 작업을 마칠 때마다 Command buffer에서 명령을 하나씩 꺼내서 다음 작업을 처리한다. Command buffer에는 여러 가지 명령이 들어갈 수 있다. Draw call이 될 수도 있고, Render state를 바꾸는 명령이 될 수도 있다.

![Command Buffer]({{site.baseurl}}/assets/study/graphics/000_renderhell_overview_0/command_buffer.png){: width="480" .custom-align-center-img}
