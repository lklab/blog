---
layout: portfolio
title: 실버케어 모바일 앱 개발
date: 2021-09-01
image: /assets/portfolio/silver-care/main.jpg
tag:
  - 원더풀플랫폼
  - Csharp
  - UGUI
  - Java
  - 모바일
  - Android
  - iOS
  - 서버 연동
  - 라이브
  - 지역화
summary:
  division: 정규 프로젝트
  period: 2021.09 - 2023.05 (1년 9개월)
  platform: Android, iOS
  environment: Unity 2020.3.19f1
  language: C#, Java, Kotlin, Objective-C, Swift
  work: UI 기능 개발, 서버 연동, 네이티브 인터페이스 개발
---

## 업무 내용

* 소프트웨어는 유니티 파트와 Android/iOS 네이티브 파트로 나뉘어짐
* 유니티 파트는 UI 기능, 서버 통신, 아바타 렌더링 등의 기능들을 담당함
* 네이티브 파트는 음성인식, 영상처리, 영상통화를 포함하여 유니티에서 직접 제어할 수 없는 하드웨어 관련 처리를 담당함
* 주로 유니티 파트에 해당하는 업무를 담당했으나, 필요시 네이티브 파트도 일부 작업하였음

## 세부 작업 내용

* 기획 및 디자인 사양에 따라 UI 기능을 개발
* 서버와의 통신 및 오류 처리를 체계적으로 관리하기 위한 시스템을 개발
* "프로세스 시스템" 개발
  * 기존에 여러 기능들이 규칙성 없이 사용하던 제한된 자원(마이크, 아바타, 화면 등)들을 체계적으로 사용하도록 함
* "디버깅 도구 시스템" 개발
  * 비개발자가 앱의 오류를 발견했을 때 앱의 로그를 개발자에게 전달할 수 있게 하는 기능
  * 앱을 다시 빌드하지 않고도 각종 파라미터를 변경할 수 있는 기능
  * 개발/운영 서버 중 어떤 서버를 사용할지 설정할 수 있는 기능
  * 위의 방법으로 효율적으로 앱을 테스트하고 디버깅할 수 있도록 함
* 버전 업그레이드 및 빌드 관리
  * 프로젝트의 유니티 버전을 2019.2.17에서 LTS 버전인 2020.3.19로 변경하고 그와 관련된 troubleshooting을 수행함
  * 안드로이드 API level을 30으로 변경했을 때 발생했던 빌드 dependancy 오류를 해결함
  * iOS Xcode 버전 변경에 따른 빌드 오류를 해결함

## 앱 특징

* 실버 케어 앱으로 어르신의 긴급상황, 복약 알람 등을 관리할 수 있음
* 음성 인식을 통해 앱의 기능을 사용할 수 있음
* 보호자 앱과 연동되어 보호자가 어르신의 현재 상태를 확인하거나 영상통화, 모니터링 등의 기능을 사용할 수 있음
* 유튜브 재생, 커뮤니티(다대다 음성통화), 건강관리 등의 기능 제공

## 앱 화면

![UI 1]({{site.baseurl}}/assets/portfolio/silver-care/ui-01.jpg){: width="320"}
![UI 2]({{site.baseurl}}/assets/portfolio/silver-care/ui-02.jpg){: width="320"}
![UI 3]({{site.baseurl}}/assets/portfolio/silver-care/ui-03.jpg){: width="320"}
