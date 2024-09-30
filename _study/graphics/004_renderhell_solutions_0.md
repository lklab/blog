---
title: Render Hell – Book IV
image: /assets/study/graphics/004_renderhell_solutions_0/banner_book_04.jpg
author: khlee
layout: post
last_modified_at: 2023-12-07
---

[Render Hell – Book IV](https://simonschreibt.de/gat/renderhell-book4/)를 읽고 정리한 내용이다.

## Sorting

Render state를 변경하는 비용이 많이 드므로, 가능한 Render state를 변경하는 명령을 최소화하도록 그릴 메시들의 순서를 조절할 수 있다. 같은 Render state를 사용하는 메쉬들을 렌더링한 후 Render state를 변경하고 해당 Render state에 맞는 메쉬들을 렌더링하는 식이다. 그러나 여전히 메쉬를 하나하나 렌더링할 때 오버헤드가 생긴다. 이러한 오버헤드를 줄일 수 있는 방법으로 Batching이 있다.

## Batching

배칭은 draw call을 하기 전에 여러 개의 메쉬들을 하나의 큰 메쉬로 그룹화하는 것이다. 여러 개의 작은 메쉬를 하나하나 그리는 것 보다 하나의 큰 메쉬를 그리는 것이 더 빠르다. 동일한 render state를 사용하는 한(동일한 material을 사용하는 한) 다양한 메쉬를 한 번에 렌더링할 수 있다.

배칭은 시스템 메모리(RAM)에서 메쉬를 결합한 다음 이 결합된 큰 메쉬를 그래픽 메모리(VRAM)에 전송하도록 되어 있다. 따라서 움직이지 않는 정적인 메쉬들을 한 번만 결합해서 VRAM에 오래 남아있게 하는 것에 적합하다. 예를 들어 우주 게임의 레이저 총알과 같은 메쉬들을 배칭할 수도 있지만 이들은 움직이기 때문에 매 프레임마다 총알-클라우드-메쉬(bullet-cloud-mesh)를 만들어서 GPU 메모리에 전송해야 한다.

또한 배칭 된 큰 메쉬의 아주 작은 일부분이 카메라에 보이는 경우도 문제가 될 수 있다. 기본적으로 카메라 frustum에 보이지 않는 오브젝트들은 컬링해서 그리지 않도록 할 수 있는데 배칭된 큰 메쉬는 카메라에 안 보이는 부분을 나눌 수 없으므로 단지 아주 작은 일부분만 카메라에 보이더라도 큰 메쉬 전체를 고려해야 하게 된다. 이로 인해 경우에 따라 성능이 저하될 수 있다.

## Instancing

Instancing은 GPU에 많은 수의 메쉬를 보내는 대신 단 하나만 보내고 GPU가 그 메쉬를 일정 수만큼 복제해서 렌더링하도록 하는 방법이다. 동일한 메쉬를 동일한 위치에 여러 개 그리는 것은 지루할 것이다. 따라서 Transform matrix 같은 추가 데이터 스트림을 제공해서 각각의 메쉬를 서로 다른 위치, 회전으로 렌더링 할 수 있다. 데이터 스트림에는 각각의 인스턴스별로 일반적으로 다음과 같은 데이터를 포함한다.

* model-to-world transformation matrix
* instance color
* animation player: bone 정보

따라서 메쉬 종류별로 단 하나의 draw call만 발생하게 된다. 배칭과의 차이점은, instancing은 동일한 메쉬를 한 번의 draw call로 렌더링하는 것이지만, 배칭은 render state가 같은 여러 종류의 메쉬를 한 번의 draw call로 렌더링할 수 있다는 것이다.

## Multi-Material-Shader

하나의 쉐이더에 여러 material을 사용해서 블랜딩하는 방법으로 draw call을 줄일 수 있는 방법이라는 것 같은데 잘 이해하지 못함. Draw call을 줄일 수 있지만 GPU에서 블랜딩하는 연산이 비싸기 때문에 효과적인지는 의문이라는 듯

## Skinned Meshes

앞서 예시로 든 레이저 총알의 경우 배칭을 사용하면 매 프레임마다 하나의 메쉬로 합치고 GPU에 보내야 하기 때문에 비싼 연산이라고 했다. 이 문제에 대한 다른 흥미로운 접근 방법은 모든 총알에 bone을 자동으로 추가하고 GPU에 skinning 정보를 제공하는 것이다. 하나의 큰 총알들 메쉬만 저장해 두고 bone 정보만 업데이트 하는 것이다. 하지만 총알이 생성되고 사라질 때마다 메쉬를 업데이트해야 한다.

## Reduce Overdraw

Full screen quad로 그리는 비네팅 효과는 100% 투명한 부분도 다시 그리기 때문에 오버드로우가 많이 발생한다. 이를 해결하기 위해 한 예시로, vertex color를 사용해서 더 나아 보이고 오버드로우를 줄인 예시를 소개하였다.

## And a lot more magic

요즘에는 middleware의 성능이 좋아져서 많은 무거운 작업이 이미 완료되었다. 따라서 실제로 어떤 것을 최적화해야하는지 아는 것이 중요하다. 일부 작업은 훌륭한 middleware가 수행할 수 있기 때문이다.
