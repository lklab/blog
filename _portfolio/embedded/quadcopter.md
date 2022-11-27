---
layout: portfolio
title: 스마트폰으로 조종하는 드론 개발
date: 2015-03-01
image: /assets/portfolio/quadcopter/architecture.png
tag:
  - 드론
summary:
  division: 학기 프로젝트
  period: 2015.03 - 2015.06 (4개월)
  platform: "드론 : Raspberry pi, STM32F4(ARM Cortex-M4)<br />조종 앱 : Android<br />제어 분석 프로그램 : Ubuntu Linux"
  environment: "드론 : Eclipse, GNU toolchain<br />조종 앱 : Eclipse<br />제어 분석 프로그램 : Eclipse"
  library: PyDev, Tkinter, HAL(Hardware abstract layer), Android SDK(API 19)
  language: "드론 : C, Python 2.7<br />조종 앱 : Java<br />제어 분석 프로그램 : Python 2.7"
  work: 드론 제어 알고리즘 개발, 제어 분석 프로그램 개발
---

## 주요 내용

* 최초에는 드론에 부착된 카메라를 스마트폰을 활용한 VR 화면으로 보면서 조종하는 것을 구상했으나, 드론 제어의 실패로 구현하지 못했음
* 드론의 제어 파라미터를 설정하고 센서값을 실시간으로 확인할 수 있도록 제어 분석 프로그램을 개발

## 개발 결과

* 하드웨어 구조도

![Architecture]({{site.baseurl}}/assets/portfolio/quadcopter/architecture.png)

* 제어 분석 프로그램 UI, 센서 값을 그래프로 보여주고 제어 파라미터를 설정

![UI]({{site.baseurl}}/assets/portfolio/quadcopter/ui.png)
