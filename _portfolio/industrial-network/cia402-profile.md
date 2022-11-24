---
layout: portfolio
title: 위치, 속도, 토크 프로파일 및 Homing 알고리즘 개발 (CiA 402 표준)
date: 2018-09-01
image: /assets/portfolio/cia402-profile/document.png
tag:
  - EtherCAT
  - CiA 402
summary:
  division: 연구 용역
  period: 2018.09 - 2018.11
  platform: AM4377 (ARM Cortex-A9)
  environment: CCS(Code Composer Studio)
  language: C
  work: 알고리즘 전체 개발 업무
---

※ [EtherCAT](https://www.ethercat.org/default.htm) : LAN(Local Area Network)에 사용되는 Ethernet 기술을 기반으로 실시간 성능을 높이도록 설계된 산업용 네트워크 기술

## 주요 내용

* 제어기와 모터드라이브의 동작 모드들이 정의된 문서인 CiA 402 표준 문서를 분석
* 표준 문서에 정의된 내용대로 모터의 위치, 속도, 토크 프로파일과 Homing 알고리즘을 개발
* 위치 프로파일의 경우 목표 위치, 최대 속도, 가/감속도 등을 받아 각 제어 주기별로 도달해야 하는 중간 위치들을 계산
* 기타 Halt 및 Quick stop(긴급 정지) 등의 상황별 기능 구현

## 개발 결과

* CiA 402에 정의된 프로파일 동작 방식 예

![Document]({{site.baseurl}}/assets/portfolio/cia402-profile/document.png)

* 개발 결과 측정 그래프

![Result]({{site.baseurl}}/assets/portfolio/cia402-profile/result.png)
