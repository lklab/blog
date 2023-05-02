---
layout: portfolio
title: 서보모터 드라이브 사용자 메뉴 기능을 위한 OLED 출력 알고리즘 개발
date: 2018-03-01
image: /assets/portfolio/drive-oled/oled-03.jpg
tag:
  - 하이젠모터
  - C
  - CCS
  - HMI
  - 펌웨어
summary:
  division: 연구 용역
  period: 2018.03 (1개월)
  platform: TMS320F28377S
  environment: CCS(Code Composer Studio)
  language: C
  work: OLED 출력 및 버튼 입력 제어 파트 개발, 메뉴 알고리즘을 구현하여 입출력 연결
---

## 주요 내용

* 기존에 사용자 메뉴가 7 segment로 출력되는 서보모터 드라이브 모델을 개선하여 동일한 사용자 메뉴 알고리즘에 출력 장치만 OLED로 변경하는 작업
* OLED에 폰트 출력
* 5개 버튼 입력
* OLED 장치와 버튼 장치는 모두 MCU와 I2C로 연결됨
* 디스플레이 버퍼에 폰트와 몇 가지 효과를 렌더링하는 렌더링 엔진 구현
* I2C 통신 대역폭 및 메모리를 고려하여 적당한 refresh 주기와 폰트 텍스쳐의 크기를 결정하였음

## 개발 결과

* 하드웨어 및 소프트웨어 구조

![Architecture]({{site.baseurl}}/assets/portfolio/drive-oled/architecture.png)

* 렌더링 엔진 구조
  * Display buffer에 먼저 렌더링을 한 후 모두 그려지면 I2C를 통해 OLED의 GDDRAM에 버퍼의 값을 쓰는 구조
  * OLED_Clear(), OLED_PrintString() 등 Display buffer에 렌더링하는 API를 구현
  * OLED_Invert(), OLED_Blink() 등 반전, 깜빡임, 애니메이션과 같은 효과를 출력하는 API를 구현
  * OLED_PeriodicProcess() 함수는 주기적으로 실행되어 Display buffer의 값을 OLED에 출력하며, 깜빡임이나 애니메이션의 업데이트도 수행함

![Rendering engine]({{site.baseurl}}/assets/portfolio/drive-oled/rendering.png){: width="480"}

* 동작 화면

![OLED 1]({{site.baseurl}}/assets/portfolio/drive-oled/oled-01.jpg)
![OLED 2]({{site.baseurl}}/assets/portfolio/drive-oled/oled-02.jpg)
![OLED 3]({{site.baseurl}}/assets/portfolio/drive-oled/oled-03.jpg)
![OLED 4]({{site.baseurl}}/assets/portfolio/drive-oled/oled-04.jpg)
![OLED 5]({{site.baseurl}}/assets/portfolio/drive-oled/oled-05.jpg)
{: .custom-disable-p-align}
