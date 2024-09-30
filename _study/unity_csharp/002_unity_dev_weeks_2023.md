---
title: Unity Dev Weeks 2023
image: /assets/study/unity_csharp/002_unity_dev_weeks_2023/title.jpg
author: khlee
layout: post
last_modified_at: 2024-07-18
---

## 유니티 프로파일링의 모든 것

* 프로파일링 마커를 수동으로 추가하면 프로파일링 오버헤드를 줄일 수 있음
* 문제 지점을 점점 좁혀가기
* 병목 찾기
  * 메인 스레드, 워커 스레드, 렌더 스레드, GPU
* Vsync 기다리는지가 중요한 듯
  * Vsync 마커가 있으면 유휴 시간이 있다는 것 -> 시간이 여유롭다
* 사례
  * 카메라는 각각이 렌더링 파이프라인을 전부 사용하기 때문에 카메라가 여러개 있으면 성능에 큰 부하를 줌
  * 마젠타 색상은 매니지드 힙을 사용한다는 뜻
  * Gfx.WaitFor~~ 이거는 다른 스레드를 기다린다는 뜻으로 다른 스레드가 병목일 수 있다는 뜻
  * 메인 스레드 Wait, 렌더 스레드 Gfx.PresentFrame이면 GPU 병목
* Profiler Analyzer
  * 여러 개의 프로파일링 데이터를 비교하고 분석할 수 있음
  * 패키지 매니져를 통해 설치해야 함
* 메모리 누수
  * 씬을 언로드하고 메모리 누수 발생 여부 확인
  * Diff 보가: 두 시점의 메모리 양을 캡쳐해서 메모리 누수 확인할 수 있음
* Deep profiling
  * 모든 함수의 시작과 끝에 마커 삽입되어서 세부사항 캡쳐 가능

## 유니티 프로젝트 프로파일링 랩

* UI Rebuild
  * C# 그래픽 컴포넌트의 레이아웃과 메시가 다시 계산되는 행위
  * 프로파일러에서 UI Rebuild 작업 관련 마커를 확인할 수 있음
    * CanvasUpdate.PreLayout 등
* UI Profiler는 에디터에서 해야 함
* 프레임디버거처럼 UI 그리는 과정을 볼 수 있음
* 메모리 프로파일러
  * 트리맵 보면 타일 형태로 각 요소가 메모리를 어느정도 사용하는지 알 수 있음음
  * 렌더 텍스쳐: 렌더 타겟. 기기 해상도가 높으면 이게 커질수 있음
  * 텍스쳐
    * 아틀라스 같은 경우에는 텍스쳐 하나가 메모리를 많이 차지할 수 있음
  * 스테틱배칭: 드로우콜은 줄일 수 있는데 메모리 양이 커짐 -> 메모리 프로파일러로 확인 가능
* GPU 병목
  * Fragment or Vertex

## 서머너즈 워: 크로니클에서 사용한 렌더링기법과 최적화 기능개발기

* 그냥 사례들 나열한거라 나중에 정리해야 할듯

## 나의 게임에 빛을 담아 그림자를 빚다

* APV
  * Adaptive Probe Volume
  * 자동으로 라이팅 프로브 배치해주는거

## [UGS 특집] 1. 사례로 보는 UGS / 2. 멀티플레이어 게임 런칭의 마스터되기

* 백엔드 개발에 도움이 됨
* 크게 4가지 서비스가 있음
  * 멀티플레이: 멀티플레이 서버, 음성 채팅 등
  * 백엔드: 클라우드 세이브, 치팅 방지 등
  * 아날리틱스: 푸시 메시지, 게임 크래시 관리
  * 수익화
* 일부는 프리티어, 무료로 사용할 수 있음
* Vivox: Voice Chat
  * TTS 기능도 있음
  * 신고할 경우 일정 부분 녹음해서 게임사에 제공할 수 있음 
* A/B 테스트 지원
* 배틀패스
* 클라우드 AI 미니 게임
* 샘플 프로젝트
  * [https://youtube.com/live/vug6Ky0uyHM?feature=share](https://youtube.com/live/vug6Ky0uyHM?feature=share)

## 애니메이션 및 영상 제작 패키지 Unity Anime Toolbox

* 깃헙에 패키지 공개되어 있음

## URP Forward+ 따라가보기

* Tile Based Rendering
  * 화면을 일정 크기 타일로 나누고 타일마다 영향을 주는 라이트 리스트를 저장
  * 해당 타일에 영향을 주는 라이트만 연산에 사용됨
* Clustered Rendering
  * Tile based + z 에 따른 추가 공간 분할
  * 더 개선된 형태임
* Forward+ 는 클러스터드 렌더링을 사용
* 특징
  * 오브젝트당 라이트 제한 없음
  * 대신 카메라 당 라이팅 제한 있음
  * 2개 이상 Reflection Probe 블렌딩 지원
  * 컴퓨트쉐이더 대신 Jobs를 활용함
  * XR, 직교카메라 지원하지 않음 -> 이제 지원함
  * Light culling 비용 부분은 포워드보다 더 비용이 큼
* 4가지 작업으로 구성됨
* Light MinMaxZ
  * 라이트의 최소, 최대 z 값을 light lindex 순서대로 저장 -> 다음 스텝에서 활용
* Z Binning
  * 각 Z 영역마다 영향을 주는 라이트 리스트 결정
* Tiling
  * 라이트마다 타일 영역 계산
* Tile Range Expansion
  * 선택 타일영역을 라이트 영역에 맞도록 확장
* 셰이더
  * ScreenSpace UV를 통해 현재 타일 판별
  * z bin 판별
  * 등등..
* Additional Light, GI(Reflection Probe) 호환 X

## 살아 움직이는 인터랙티브 미디어 아트월

* [https://blog.naver.com/kimsung4752/223100329469](https://blog.naver.com/kimsung4752/223100329469)
* 포인트 캐시
* 비주얼 이펙트 그래프
