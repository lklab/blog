---
title: UDay Seoul 2024
image: /assets/study/unity_csharp/005_uday_seoul_2024/title.jpg
author: khlee
layout: post
---

# 1일차

## Unity 6, 그 이후: Unity 엔진 및 서비스 로드맵

* Web 개선함
  * 모바일 네이티브 브라우져에서 실행 (마치 네이티브 앱처럼)
* Multiplayer VR Template
  * VR용 멀티플레이
* Apple Vision Pro
  * 에디터에서 변경한 사항이 실시간으로 비전프로에 적용됨

## Unity 6과 함께 모바일, VR, PC, 콘솔에서 고화질 그래픽 구현

* APV
  * 라이팅 프로브 관련 유용한 것들
* 물표현 짱임

![물표현]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-22-132438.png)

## Dave, a 2D-Diver in a 3D-Land - 데이브 더 다이버 포스트모템

* 3D에 2D 콜라이더
  * 지형생성 콜라이더 체크 수동으로 하면 오래걸림
* 2D 콜라이더 회전
  * 절단면을 사용
* 2D 콜라이더는 Orthgraphic을 사용함. Perspective 카메라와는 안 맞을 수 있음

## Unity의 PolySpatial를 통한 Apple Vision Pro용 공간 앱 제작기 소개

* PolySpatial은 MR 대상
  * VR, Windowed APP 등은 대상이 아님

## Unity Sentis 상세 기술 설명과 게임 콘텐츠 적용 튜토리얼

* 유니티 6에서 정식 패키지로 제공
* 딥러닝 모델이 할 수 있는 모든 기능 할 수 있음
  * 이미지 세그멘테이션, 오브젝트 디텍션, 제스쳐, 랜드마크, 텍스트 요약, TTS/STT, 생성 등등
* AI 모델 선택 -> 임포트/최적화 -> 추론 코드 작성 -> 배포
  * AI 모델을 만들어서 ONNX로 변환하거나 다운로드받기
  * Hugging Face에 다양한 모델이 공개되어 있음
    * [https://huggingface.co/models?library=unity-sentis](https://huggingface.co/models?library=unity-sentis)
* 모델 암호화 기능 제공
* Neural Rendering

![Neural Rendering]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-22-155312.png)

* 고급 렌더링을 사용할 수 있음 (물체의 위치를 가지고 라이트맵 생성)

## 인디게임 산나비 포스트모템

* 경쟁을 피하기 위한 대체 불가능한 게임을 만들어야 한다.
* 스토리
  * 스토리랑 스토리텔링은 너무 다름
* 조작감
  * 개인차, 게임차 큼
  * 플레이 경험과 복잡하게 엮여 있음
  * 상상하는 대로 움직인다. (누른 대로 정직하게 움직인다가 아님)
    * ref 갓오브워
    * 보정된 조작감 = 쾌적함
  * 때리고 싶은 애가 잘 맞고 원하는대로 움직이고 키를 누르면 피드백이 오고 약간의 오차는 봐준다
  * 지원사업

![지원사업]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-22-163240.png)

* 인디게임에서는 좋다
  * 모두가 만족하는 방법보다 한 명이 결정권을 가지는게 방향성을 유지할 수 있기 때문에 더 좋음
  * 실력은 필수
  * 다른 사람에게 신뢰를 주어야 함

## 모바일과 XR을 위한, URP 쉐이더 그래프 튜토리얼

## (Unity Cloud와 함께) 만들고 관리하고 빌드하라

<br/>
<br/>

# 2일차

## 프로젝트 콘텐츠를 편리하게 다국어화 할 수 있는 Localization 사용법 소개

* 메타데이터
  * 플랫폼 오버라이드: 플랫폼별로 다르게 하고 싶을 때
* Game  Object Localizer
  * 언어마다 폰트, 폰트크기 등 개별 속성을 지정할 수 있음
* 스마트 문자열
  * string.Format처럼 사용할 수 있는 방법
  * Localize String Event의 Local Variables에 변수 입력
  * 조건 연산 가능 (choose 연산 사용)
  * 전역 저장소에서 변수 가져올 수 있음 (Nested Variables Group 쓰면 됨)
* 스크립트
  * 언어 변경
    * LocalizationSettings.InitializationOperation 먼저 기다린 후 LocalizationSettings.SelectedLocale을 설정하기
  * 언어 변경 이벤트
    * LocalizationSettings.SelectedLocaleChanged
* 확장
  * 구글 스프레드시트 연동

## PiXYZ - 리토폴로지와 자동 LOD 생성으로 개발 속도 향상 시키기

* CAD와 메쉬의 차이점
  * CAD 모델은 표면이 연속적이며 메쉬 모델은 단순화 됨
  * CAD는 BREP, 메쉬는 폴리곤

![CAD와 메쉬]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-23-110030.png)

* Pixyz 장점
  * 넙스 모델 -> 폴리곤 잘 함
  * 지원하는 CAD 모델이 다양함
    * 일단 뭐든 열어서 볼 수 있음
  * 테셀레이션: 쪼개진 폴리곤을 최적화하는 것임
    * LOD 생성 등
    * 리메싱
* Pixyz studio
  * CAD 파일을 FBX로 바꿔준다!
  * 모든 기능들은 API로 열려 있어서 python 스크립트로 실행 가능
    * pixyz scenario processor: 간편하게 대량 파일 처리 등 할 수 있음 -> 일반적인 industry의 워크플로우임
  * pixyz plugin은 유니티에서 그냥 바로 사용할 수 있는 것

![Data Preparation]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-23-110731.png)

* Data Preparation
  * Repair CAD: 폴리곤 사이 벌어지는 것들 잡아주기
  * Repair Mesh: 폴리곤의 앞/뒤가 반대로 된 것 잡아주기
  * 테셀레이션
    * CAD 표면과 폴리곤의 최대 차이를 조절: Max Sag
    * length: 평면을 폴리곤으로 나눌 때 최대 길이
* More Optimazations
  * Hidden Removal
    * 안 보이는 부분 제거하기
  * Remove Z-fighting
  * LOD Chain
  * Retopology
    * instant meshes
  * 임포스터
    * 폴리곤 2개 4개 등만 씀. 평면 몇개로 표현하는것
    * 모델 주변 시점에서 본 텍스쳐들을 다 만들어 둠 (Diffuse, Depth, Normal)
* Muse 사용해서 텍스쳐 자동으로 만들 수 있음

## Batch Renderer Group 파헤치기

## Optimization: Memory Management

* Addressable 관련 Native 메모리
  * AssetBundle, SerializedFile, PersistentManager.Remapper
  * 에셋 번들을 어떻게 사용하는지에 따라 메모리 사용량이 크게 차이 나는 항목들 1메가 ~ 50메가

![Addressables 관련 팁]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-23-134339.png)

* 팁
  * Unload(false) 하면 instatiate된 오브젝트는 제외하고 에셋 번들만 언로드할 수 있음
    * Release() 내부적으로 Unload(true)가 호출됨
* 마무리

![Memory Management 요약]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-23-135700.png)

## 에버퍼플 포스트모텀 - 버추얼 콘서트를 위한 툰 렌더링 개발기

* OIT 여러 겹의 반투명 오브젝트를 순서대로 렌더링할 수 있음
  * Order Independent Transparency
* Face SDF Texture
  * 얼굴 부분 그림자

## Unity Muse in Action!

![Muse]({{site.baseurl}}/assets/study/unity_csharp/005_uday_seoul_2024/2024-05-23-151510.png)

## 유니티 게이밍 서비스 - 멀티플레이어, 커뮤니티 솔루션 업데이트와 로드맵

## 유니티 ECS 개발 시작하기

## 타임 사용을 위한 Unity UI Toolkit 소개
