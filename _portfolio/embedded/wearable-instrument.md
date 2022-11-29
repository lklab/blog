---
layout: portfolio
title: 스마트폰 연동 연주용 장갑(웨어러블 디바이스) 개발
date: 2015-09-01
image: /assets/portfolio/wearable-instrument/architecture.png
tag:
  - 웨어러블
summary:
  division: 학부 졸업작품
  period: 2015.09 - 2015.12 (4개월)
  platform: "재생 앱 : Android<br />연주용 장갑 : Arduino nano"
  environment: "재생 앱 : Eclipse<br />연주용 장갑 : Arduino IDE"
  library: Android SDK(API 19) 및 SDK에서 제공되는 midi API
  language: "재생 앱 : Java<br />연주용 장갑 : C"
  work: 장갑과 재생 앱 사이의 블루투스 프로토콜 설계 및 구현, 재생 앱의 UI 및 소리 출력 알고리즘 구현
---

## 주요 내용

* 손가락 구부림을 통해 연주할 코드 정의
* 구부린 손가락과 코드를 규칙성 있게 매치하여 처음 배우기 쉽도록 설계
* 손가락 구부림은 구부림 센서(가변저항)을 통해 감지
* 장갑과 앱은 블루투스로 통신
* 앱은 구부림 정보를 받아 해당하는 코드의 소리를 출력

## 개발 결과

* 하드웨어 구조 및 회로 설계

![Architecture]({{site.baseurl}}/assets/portfolio/wearable-instrument/architecture.png)
![Circuit]({{site.baseurl}}/assets/portfolio/wearable-instrument/circuit.png)

* 소프트웨어 구조 및 개발된 앱의 화면

![Class diagram]({{site.baseurl}}/assets/portfolio/wearable-instrument/class-diagram.png)
![UI]({{site.baseurl}}/assets/portfolio/wearable-instrument/ui.png){: width="320"}
