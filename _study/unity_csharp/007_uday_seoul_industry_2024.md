---
title: 'U/Day Seoul: Industry (2024)'
image: /assets/study/unity_csharp/007_uday_seoul_industry_2024/unity-1-2048x883.png
author: khlee
layout: post
last_modified_at: 2024-10-02
---

[온라인 세션 영상 링크](https://www.youtube.com/live/57cst2tA5WQ)

## 시네머신3를 통한 손쉬운 콘텐츠 카메라 제작

13:00 - 13:40, 김재익, Senior Advocate, Unity

기존 시네머신2의 기능은 강력하지만 복잡한 인스펙터 속성 때문에 진입 장벽이 있었다. 시네머신3는 유니티6에 맞춰 업데이트된 것으로 다음과 같은 특징이 있다.

* 이해하기 쉬운 용어
* 사용자 친화적인 모듈 형식
* 자유로운 돌리 트랙 구성

#### 작품 포커스 카메라

여러 개의 가상 카메라를 블렌딩하는 방식

* 객체 활성/비활성
* 직접 우선순위 제어
* 시네머신 카메라 매니저 활용

`SequencerCamera`를 사용하면 각 virtual camera를 순서대로 전환할 수 있다.

#### 제품 어라운드 카메라

고정된 제품을 주변으로 둘러보는 카메라

시네머신 카메라에 component와 extension을 추가해서 기능을 확장할 수 있다. 

Position에 Orbital Follow를, Rotation에 Hard Look At을 사용한다. Orbital Follow는 사용자 입력을 중계하는 Input Axis Controller 컴포넌트를 요구한다. Hard Look At은 Tracking Target을 설정해 주어야 한다.

Recentering: 입력 없을 때 카메라가 기본 위치로 돌아가는 기능

On screen controller를 사용하면 Input system과 연계되는 UI 입력장치를 만들 수 있다. (ex. Screen joystick)

카메라의 이동 범위를 제한하고 싶다면 Cinemachine Decollider를 사용하면 된다.

#### 메타버스 캐릭터 카메라

Position: Third Person Follow (Tracking Target 필요)

Noise 컴포넌트를 추가하면 카메라를 손으로 들고 있는 듯한 느낌을 줄 수 있다.

Third Person Aim 익스텐션 컴포넌트를 사용하면 3인칭 에임 기능이 추가된다.

#### 가상 현장 트랙 카메라

Spline 패키지 사용

Dolly Cart with Spline을 사용하면 카메라가 spline을 따라서 움직인다. 이를 위해 Position을 spline dolly로 설정한다. 회전은 사용자 입력에 따라 회전하는 Pan Tilt를 사용한다.

## Unity Sentis: XR/모바일 기기의 온디바이스 AI 추론 및 최적화 방법

14:30 - 15:10, 김한얼, Senior Software Engineer, Unity

Unity6 정식 패키지로 Sentis 2.0 출시

On-device AI의 특징

* 실시간 추론이 가능
* 데이터 보안 유지에 유리
* 오프라인에서 사용 가능
* 데이터센터, 서버 운영비 필요 없음
* 디바이스별 개인 사용자의 환경 고려 가능

거대모델 추론이 어려운데, 모델 최적화(Pruning, Distillation, Quantization)를 통해 모델 경량화 추세

1% lows 프레임을 측정해서 프레임이 느려질 때의 성능을 볼 수 있다.

모바일에서 프레임 유휴 시간을 35% 정도로 유지해야 발열, 배터리 문제를 해결할 수 있음

10가지 최적화 방법

[테스트에 사용된 프로젝트](https://github.com/skykim/2024_UDay_Seoul_Industry_Sentis)

#### 모델 직렬화 사용하기

.onnx -> .sentis를 통해 모델의 확장성이 좋아진다.

* 디스크의 공간을 절약
* 에디터에서 로딩 속도 단축
* 유니티에서 모델을 한 번 더 검증
* 파일 공유에 용이 (StreamingAssets)

#### 양자화 모델 사용하기

* 직렬화된 모델(.sentis)에 대해서만 지원
* 부동소수점 가중치를 양자화해서 모델의 용량을 줄일 수 있음
* Sentis 양자화 모델은 추론 속도의 차이가 없음
* 정확도는 줄어들 수 있음
* 최대 75%까지 모델의 용량을 줄일 수 있음
* Float32, Float16(50%), Unit8(75%)

#### Fixed dimension 사용하기

추론 속도가 빨라짐

Fixed Dimension은 고정된 입력 값을 처리, Dynamic Dimension은 다양한 입력 값을 처리

#### Functional API를 이용해 Custom 모델 만들기

Functional Graph를 이용해서 모델에서 필요한 후처리를 빠르게 수행할 수 있다.

Pre-trained 모델에서 일부 Layer가 누락된 경우 (Relu, LeakyRelu 등등)
Bounding Box에 대한 후처리가 필요한 경우

그 외의 Layer를 사용하는 경우 직접 정의 필요

#### 내 시스템에 맞는 Graphics API를 선정하기

일반적으로 GPUCompute가 가장 빠르지만 일부 모델의 경우 CPU가 더 빠를 수 있다.

GPU를 지원하지 않는 Layer가 포함되어 있다면 CPU fallback이 발생해서 느릴 수 있음

Web 같은 경우 웹어셈블리에서 느려질 수 있어서 GPU 사용 추천

#### 첫 추론은 반드시 Dummy Execution

초기화 단계에서 미리 1번 더미 실행을 진행해야 그 다음 추론부터는 원래 속도로 실행된다.

첫 번째 스케출링은 항상 느리다.

* Code와 shader들을 컴파일하고 메모리에 처음 할당함
* 모든 딥러닝 라이브러리 공통 사항

#### Model의 Layer를 쪼개서 실행하기

ScheduleIterable을 사용하면 IEnumerator를 통해서 Layer 단위로 모델을 나눠서 실행 가능하다.

#### Await를 이용한 Main Thread Blocking 방지

Unity 6 부터 async/await를 정식 지원

`await ReadbackAndCloneAsync()` 사용

#### 화면에 출력하고자 하는 경우엔 Screen Texture에 직접 처리하기

렌더링 영상을 후처리 처리하는 경우 Screen Texture에 직접 처리 가능하다.

매 프레임마다 너무 잦은 Tensor, Texture를 할당하는 경우 성능에 지장을 줌
각 Render Pipeline에 맞게 Screen Texture에 직접 업데이트하면 속도 및 메모리 사용 개선

#### 사용한 Tensor는 안전하게 해제하기

사용한 Tensor는 using 또는 Dispose()를 사용해서 해제해야 Memory Leak이 발생하지 않음

## ML-Agents를 이용한 컨테이너 적재 최적화 연구 사례 분석

16:00 - 16:40, 전영재, Senior Software Development Consultant, Unity

실세계 문제를 강화학습으로 해결하게 위해 문제를 이해하고 프로그램적으로 정리하는 방법

#### ML-Agents란?

오픈소스 프로젝트로, 게임이나 시뮬레이션 등의 3차원 가상 환경을 인공지능 모델의 강화학습을 위한 환경으로 사용할 수 있도록 해주는 유니티 패키지

강화학습은 기계학습의 한 부류인데, 어떤 환경 안에서 정의된 에이전트가 현재의 상태를 인식하여, 선택 가능한 행동들 중 보상을 최대화하는 행동 혹은 순서를 선택하는 방법

1. 상태(환경)를 파악(관측)한다.
2. 적절한(이라고 판단되는) 행동을 한다.
3. 행동에 대한 보상을 받고 1로 돌아간다.

강화학습의 특징

* 스스로 학습
    * 학습 도중에 인간의 개입이 필요하지 않음
    * 대신 분명한 보상 기준을 정해주어야 함
* 보상 기반 행동
    * 최대 보상에 도달하기 위한 최선의 선택을 학습
    * 반대로 보상이 낮아지는 행동을 피하게 됨
* 환경 변화에 유연
    * 환경이 변화하더라도 상호작용하며 여전히 최고의 보상을 얻기 위해 행동

#### 컨테이너 적재 문제 정의

논문 "항만물류 환경에서 강화학습 기반 컨테이너 다단 적재 모델링 방법"에 기반

목표: 가능한 많은 컨테이너를 적재하면서 재취급 횟수는 최소화
재취급: 하단에 깔려있는 컨테이너를 취급(이동 혹은 반출)하기 위해서 상단에 놓여 있는 컨테이너들을 임시로 이동하는 행위

![문제 정의]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.11.36.png)

#### 강화학습 환경 구축

![워크플로우]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.14.48.png)

* 에이전트: 행동 주체
* 규칙: 보상 부여 기준
* 환경: 관측 대상

에이전트의 행동과 보상 부여 기준

* 행동한 가능한 작은 단위로 설계 (내려놓기만 하거나 올려놓기만 하거나)
* 보상은 잘할 때에만 주고 못할 때에는 벌(-보상)을 주어야 함
* 에피소드를 실패하는 경우에는 보상을 0으로 초기화하고 바로 종료하기
    * 에피소드: 업무 한 사이클 -> 예들 들어 75개 컨테이너를 최대한 많이 적재하기

에이전트 행동 설계

* 어떤 업무를
    * 내려놓기 -> 0
    * 들어올리기 -> 1
* 어느 위치에 행할 것인가?
    * 2차원 좌표 -> 1차원 좌표
* 몇 번이나 행할 것인가
    * 125회 = 75회 신규 전재 + 50회 재취급 기회 (미사용 횟수는 보상에 추가)
* 재취급은
    * 이미 놓여져 있는 컨테이너를 임시로 반출했다가 다시 적재하기
    * 두 단계 행동으로 진행하지만 행동 자체는 1회 한 것으로 처리 필요
    * 반출했던 위치와 다시 적재하는 위치는 다를 수 있음
    * 컨테이너의 반출 행동은 사실상 재취급을 위한 행동

규칙: 보상 부여 기준

* 입고 대상 컨테이너는 총 75개가 생성되며 각각 임의의 출하일을 부여받음
* 신규 입고 컨테이너를 출하일이 더 늦은 컨테이너 상단에 적재 -> 보상+1
* 신규 입고 컨테이너를 출하일이 더 이른 컨테이너 상단에 적재 -> 보상=0, 종료
* 컨테이너를 재취급하는 행동 -> 보상+0
* 컨테이너를 5층 초과하여 전재 -> 보상=0, 종료 -> 마스킹처리 함
* 입고 대상 컨테이너 전부 적재 -> 보너스 보상 부여, 종료
* 컨테이너 재취급을 위한 임시 출고 시도 실패 -> 보상=0, 종료
* 컨테이너 임시 출고한 후에 다시 임시 출고 시도 -> 보상=0, 종료
* 적재된 컨테이너들간의 층수 차이가 많이 난다면 -> 보상=0, 종료

마스킹 처리 관련

* 컨테이너 5층 초과 적재 -> 마스킹으로 행동 제약
* 어떤 행동의 경우의 수 중 어떤 경우의 수를 제외할 것인지 설정 가능

환경: 관측 대상

* 현재 입고 대상 컨테이너의 출하 일정
    * 0~7 사이의 정수형 숫자 1개
    * 이미 적재되어 있는 컨테이너들의 출하 일정과 비교 필요
* 이미 적재되어 있는 컨테이너들의 출하 일정
    * 얼마나 많이? 자세히?
    * 출하 일정 역전은 보상을 전부 잃고 실패하게 되는 주요 원인
* 이미 적재되어 있는 컨테이너들의 높이 분산
    * 0.67보다 크거나 같은 실수형 숫자 1개
    * 0.67이 최저치 -> 75개 컨테이너를 빈틈없이 5x5 크기의 3개 층에 적재

![관측 대상]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.26.49.png)

![Behavior Parameters]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.28.11.png)

![바뀐 워크플로우]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.29.41.png)

#### 학습과 튜닝 그리고 결과

![학습 환경]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.30.54.png)

![yaml 파일 비교]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.33.10.png)

![히스토그램]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.34.13.png)

![높이 분산 기준]({{site.baseurl}}/assets/study/unity_csharp/007_uday_seoul_industry_2024/2024-10-02-4.36.33.png)
