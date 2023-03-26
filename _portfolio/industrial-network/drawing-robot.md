---
layout: portfolio
title: Beremiz IDE를 사용하여 그림을 그리는 3축 로봇 응용 개발
date: 2014-10-01
image: /assets/portfolio/drawing-robot/test.jpg
tag:
  - 학부
  - Python
  - Linux
  - Xenomai
  - PLC
  - Beremiz
  - IEC 61131-3
  - Tkinter
summary:
  division: 학기 프로젝트
  period: 2014.10 - 2014.12 (3개월)
  platform: "그림 그리는 프로그램 : Ubuntu Linux<br />제어기 : Xenomai"
  environment: "그림 그리는 프로그램 : 텍스트 편집기<br />제어기 : Beremiz"
  library: PLCopen, Tkinter
  language: "그림 그리는 프로그램 : Python 2.7<br />제어기 : IEC 61131-3"
  work: 그림 그리는 프로그램, 로봇 제어 알고리즘 개발
---

## 주요 내용

* Python으로 그림을 그리는 프로그램을 개발
* 그림 그리는 프로그램은 사용자가 그린 그림을 제어 프로그램이 알 수 있도록 각 지점을 CSV 형태의 데이터로 가공하여 파일로 전달
* 제어 프로그램은 전달된 파일을 읽어서 사용자가 그린 그림대로 로봇을 구동
* 로봇의 end point에 있는 LED 빛을 카메라에 노출시켜서 사용자가 그린 그림이 그려지는지 사진을 통해 확인

## 개발 결과

* 그림 그리는 프로그램 개발

![UI]({{site.baseurl}}/assets/portfolio/drawing-robot/ui.png)

* 동작 결과

![Test]({{site.baseurl}}/assets/portfolio/drawing-robot/test.jpg)

* ※ 왼쪽 입 부분은 로봇 제어 알고리즘의 버그로 인해 제대로 그려지지 않았음
