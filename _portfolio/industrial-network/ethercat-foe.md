---
layout: portfolio
title: EtherCAT FoE 기반 장치 펌웨어 관리 기능 개선
date: 2017-03-01
image: /assets/portfolio/ethercat-foe/ui.png
tag:
  - EtherCAT
  - FoE
summary:
  division: 논문
  period: 2017.03 - 2017.04 (2개월)
  platform: Windows 7
  environment: Visual studio
  library: SOEM (Simple Open EtherCAT Master)
  language: C++
  work: PM, 아이디어 제공, 시스템 설계, 논문 작성 (개발은 다른 팀원이 담당)
  result: 대한기계학회 춘계학술대회 논문
---

## 주요 내용

* 기존 문제점
  * EtherCAT 장치의 펌웨어 버전 관리를 사용자가 직접 해야 함
  * 잘못된 펌웨어를 적용했을 경우 장치가 동작하지 않음
* 개선
  * 프로그램이 제조사에서 제공하는 "펌웨어 데이터베이스"에 접속하여 현재 장치의 펌웨어 버전과 최신 버전을 비교
  * "일괄 업데이트" 기능 수행 시 각 장치에 맞는 펌웨어를 최신 버전으로 자동 업데이트

## 시스템 구조

![Architecture]({{site.baseurl}}/assets/portfolio/ethercat-foe/architecture.png)

* 펌웨어 관리 프로그램과 펌웨어 데이터베이스는 HTTP로 통신
* 펌웨어 데이터베이스에는 지원되는 장치들의 펌웨어가 버전별로 정리되어 있음

## UI 및 주요 기능

![UI]({{site.baseurl}}/assets/portfolio/ethercat-foe/ui.png)

* 현재 연결된 EtherCAT 장치들의 펌웨어 버전과 최신 버전 표시
* 각 장치마다 교체 가능한 펌웨어 버전들의 리스트 표시
* 각 장치의 펌웨어를 특정한 버전의 펌웨어로 교체
* 모든 장치의 펌웨어를 최신 버전의 펌웨어로 업데이트

## 논문

* [EtherCAT FoE 기반 장치 펌웨어 관리 기능 개선](http://www.dbpia.co.kr/Journal/ArticleDetail/NODE07182218)
