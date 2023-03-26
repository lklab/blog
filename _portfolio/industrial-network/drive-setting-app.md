---
layout: portfolio
title: EtherCAT 기반 모터드라이브 설정 프로그램 개발
date: 2018-06-01
image: /assets/portfolio/drive-setting-app/ui.png
tag:
  - 하이젠모터
  - C
  - Java
  - Windows
  - CMake
  - EtherCAT
  - SOEM
  - Java swing
summary:
  division: 연구 용역
  period: "2018.06 - 2018.07 (2개월) - 기본 개발<br />2018.12 - 2019.01 (2개월) - 추가 개선 개발"
  platform: Windows 7
  environment: Visual studio 2017 community, CMake 3.11.2, Eclipse oxygen.3a
  library: SOEM (Simple Open EtherCAT Master)
  language: C, Java 8
  work: 프로그램 전체 개발 업무
---

※ [EtherCAT](https://www.ethercat.org/default.htm) : LAN(Local Area Network)에 사용되는 Ethernet 기술을 기반으로 실시간 성능을 높이도록 설계된 산업용 네트워크 기술

## 주요 내용

* UI는 Java로 개발하며, C로 작성된 SOEM과 연결하기 위해 JNI 활용

![Architecture]({{site.baseurl}}/assets/portfolio/drive-setting-app/architecture.png)

* Java와 SOEM 버전 변경에 쉽게 대응할 수 있도록 소프트웨어를 설계함

## UI

![UI]({{site.baseurl}}/assets/portfolio/drive-setting-app/ui.png)

## 주요 기능

* 연결된 EtherCAT 네트워크를 스캔
* 각 모터드라이브의 설정 파라미터를 읽기/쓰기
* 모터드라이브의 동작을 확인하기 위한 테스트용 모터 구동 기능
* 모터드라이브 펌웨어 업데이트 기능
