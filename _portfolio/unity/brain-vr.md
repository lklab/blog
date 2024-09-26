---
layout: portfolio
title: 뇌과학 연구용 VR 게임 개발
date: 2018-12-01
image: /assets/portfolio/brain-vr/gear_vr.png
tag:
  - 겜브릿지
  - Csharp
  - VR
  - Oculus
  - 모바일
  - REST API
  - 납품
summary:
  division: 용역
  period: 2018.12 - 2019.08 (9개월)
  platform: Android (Oculus Gear VR)
  environment: Unity 2018.3.1f1
  library: Oculus Unity SDK
  language: C#
  work: 클라이언트 개발
---

## 개발 내용

* 두뇌 인지 테스트를 위한 14개 게임 개발
* 데이터베이스 서버와 연동
  * 로그인, 각 게임 결과 기록, 난이도 파라미터
* 문장 따라 읽기 기능을 위한 마이크 녹음 기능 구현
* VR을 위한 그래픽 및 UI 구성
* Gear VR controller 연동

![Gear VR]({{site.baseurl}}/assets/portfolio/brain-vr/gear_vr.png){: .custom-align-center-img .custom-disable-img-margin}
*\<Gear VR controller\>*{: .custom-caption}

## 게임 특징

* 처음 게임 시작 시 인트로 재생 및 기초문답/문장 따라읽기 진행
* 메인 홀과 과제 방으로 구성되며, 메인 홀에서 원하는 과제 방에 입장하여 해당하는 게임 수행
* 각 과제 방은 튜토리얼 방과 게임 화면으로 구성되어 사용자가 게임을 플레이하기 전에 게임 방법을 알 수 있음
* 과제 방은 열쇠로 열기 전에는 입장할 수 없으며, 열쇠는 기초문답 및 문장 따라 읽기를 일정량 완료할 때마다 얻을 수 있음
* 모든 과제를 수행하면 최종 결과 방에서 통계를 확인할 수 있음

![Architecture]({{site.baseurl}}/assets/portfolio/brain-vr/architecture.png){: .custom-align-center-img .custom-disable-img-margin}
*\<게임 진행 플로우\>*{: .custom-caption}
