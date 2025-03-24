---
layout: portfolio
title: 산업용 AR 솔루션 개발
date: 2023-05-01
image: /assets/about/platforms/unity.png
tag:
  - 맥스트
  - Unity
  - Csharp
  - UGUI
  - AR
  - 모바일
  - Android
  - WebGL
  - 서버 연동
  - 지역화
  - WebRTC
  - LiveKit
  - 납품
summary:
  division: 정규 프로젝트
  period: 2023.05 - 2024.08 (1년 4개월)
  platform: Android, WebGL, AR Glasses
  environment: Unity 2022.2.5f1
  library: UniTask, Maxst AR SDK, WebRTC, LiveKit
  language: C#
  work: 클라이언트 개발
---

## 개요

* Unity를 이용한 산업용 설비점검/원격지원 솔루션 개발
* S사, C사에 성공적으로 납품

## 솔루션 특징

* 설비점검 기능과 원격지원 기능이 있음
* 설비점검
  * 특정 설비에 대해 해당 설비에 대한 가이드 등 컨텐츠를 저작할 수 있는 WebGL 툴 제공
  * 위 툴에서 저작한 컨텐츠를 AR 기능을 활용하여 실제 설비 상에 증강할 수 있는 앱 제공
* 원격지원
  * 여러 명의 사용자가 음성 통화를 할 수 있는 모바일 앱 및 WebGL 앱 제공
  * 화면 공유를 통해 통화 참여자가 설비를 함께 볼 수 있음
  * 드로잉 기능을 제공하여, 사용자가 터치 입력을 통해 화면에 드로잉하면 그 드로잉이 실제 3D 공간 상에 증강되어 모든 참여자에게 공유됨
  * 채팅 기능 및 글로벌 사용자를 위한 번역 기능 제공

## 개발 내용

* AR 기술을 활용하여 설비 점검 및 원격 지원(통화) 기능을 개발
* 기존 프로젝트에 내장되어 있던 드로잉 기능을 '드로잉 모듈'로 분리하고 다양한 프로젝트에서 활용할 수 있도록 함
  * 펜 또는 스탬프를 골라서 캔버스에 드로잉하는 기능 개발
  * 화면 공유를 할 때, 다양한 비율의 화면에서 배경 이미지 기준으로 모두 동일한 위치에 드로잉이 그려지도록 좌표변환 기능 개발
* 각 고객사별 납품을 위해 안정화 및 커스텀 기능 개발
