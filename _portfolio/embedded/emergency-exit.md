---
layout: portfolio
title: 화재 상황을 대비한 동적 비상구 방향지시 시스템 개발
date: 2014-06-01
image: /assets/portfolio/emergency-exit/product.png
tag:
  - 학부
  - C
  - Python
  - Raspberry pi
  - Arduino
  - Tkinter
summary:
  division: 교내 대회
  period: 2014.06 - 2014.09 (4개월)
  platform: "상황실 프로그램 : Raspberry pi<br />비상구 지시등 제어 장치 : Arduino due"
  environment: "상황실 프로그램 : Eclipse<br />비상구 지시등 제어 장치 : Arduino IDE"
  library: Tkinter
  language: "상황실 프로그램 : Python 2.7<br />비상구 지시등 제어 장치 : C"
  work: 상황실 프로그램 개발
---

## 주요 내용

* 화재 발생 시 화재 센서 정보를 토대로, 가장 최적의 경로를 계산하여 이를 2가지 이상의 방향을 표시할 수 있는 비상구 지시등에 표시하여 생존자들의 안전한 대피 유도
* 상황실 프로그램은 현재 화재 상황 및 비상구 지시등의 표시 방향을 UI에 출력
* 최적 경로 알고리즘은 경로의 가중치를 반영할 수 있는 Dijkstra 알고리즘을 사용하였으며, 상황실 프로그램에서 계산이 이루어짐

## 개발 결과

* 상황실 프로그램의 알고리즘 순서도 및 UI

![Flow chart]({{site.baseurl}}/assets/portfolio/emergency-exit/flow.png)
![UI]({{site.baseurl}}/assets/portfolio/emergency-exit/ui.png)

* 건물 모형을 포함한 전제 시스템 사진

![Product]({{site.baseurl}}/assets/portfolio/emergency-exit/product.png)
