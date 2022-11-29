---
layout: portfolio
title: 오픈 소스 통합개발환경을 활용한 실시간 임베디드 제어기 HMI 개발
date: 2017-03-01
image: /assets/portfolio/hmi/hmi.png
tag:
  - PLC
  - HMI
summary:
  division: 논문
  period: 2017.03 - 2017.04 (2개월)
  platform: Beaglebone black, Xenomai
  environment: Beremiz
  library: PLCopen, wxPython
  language: IEC 61131-3, Python 2.7
  work: Beremiz를 사용하여 HMI를 포함하는 제어 프로그램 개발, 실시간 성능 측정 및 분석
  result: 대한기계학회 춘계학술대회 논문
---

※ HMI(Human Machine Interface : 기계 제어에 사용되는 데이터를 인간에게 친숙한 형태(UI)로 변환하여 보여주는 장치

## 주요 내용

* 산업용 제어 프로그램은 실시간 성능이 중요한데, 이를 저해하지 않는 구조를 갖는 HMI 프로그램을 개발
* 개발된 결과물이 실제 산업 시설에 적용될 수 있을 정도의 실시간 성능을 갖는지 분석
* 테스트를 위한 HMI는 사용자로부터 모터가 이동할 위치, 속도 명령을 받고, 현재 모터의 위치와 속도 정보를 화면에 표시하도록 구현하였음

## 개발 결과

* 실시간 성능을 고려한 소프트웨어 구조 설계 및 개발된 HMI

![Architecture]({{site.baseurl}}/assets/portfolio/hmi/architecture.png)
![HMI]({{site.baseurl}}/assets/portfolio/hmi/hmi.png)

* 실시간 성능 분석

![Evaluation]({{site.baseurl}}/assets/portfolio/hmi/evaluation.png)

## 논문

* [오픈 소스 통합개발환경을 활용한 실시간 임베디드 제어기 HMI 개발](http://www.dbpia.co.kr/Journal/ArticleDetail/NODE07182217?TotalCount=0&Seq=4&isIdentifyAuthor=1&Collection=0&isFullText=0&specificParam=0&SearchMethod=0&Page=1&PageSize=20)
