---
layout: portfolio
title: UPPAAL2C를 이용하여 정형 모델 기반의 검증된 일체형 드라이브 상태머신 개발
date: 2016-04-01
image: /assets/portfolio/uppaal2c/model.png
tag:
  - 대학원
  - C
  - Xenomai
  - UPPAAL
  - Timed automata
  - UPPAAL2C
  - Beremiz
summary:
  division: 학기 프로젝트
  period: 2016.04 - 2016.06 (3개월)
  platform: Xenomai
  environment: UPPAAL 4.1, 텍스트 편집기, Beremiz
  language: Timed automata, C
  work: UPPAAL2C 수정, 제어 프로그램 개발
---

## 주요 내용

* Timed automata 기반 소프트웨어 모델링 툴인 UPPAAL로 작성된 모델로부터, C 언어로 변환하는 오픈소스인 [UPPAAL2C](https://github.com/arieleiz/UPPAAL2C)를 수정
* 수정된 UPPAAL2C를 이용하여 일체형 드라이브 상태머신 코드를 생성
* 생성된 코드를 이용하여, Beremiz 상에서 PLC 프로그램을 개발, 동작 확인

※ 일체형 드라이브 : 기존에는 하나의 제어기에 여러 드라이브가 연결되어 있는 구조이나, 일체형 드라이브는 제어기와 드라이브가 일체형으로, ["모션 레시피"]({{site.baseurl}}/portfolio/industrial-network/motion-recipe/)로 정의되는 동작 모드를 입력 받으면 그에 따라 모터가 미리 정의된 동작대로 구동되는 드라이브

## 개발 결과

* 일체형 드라이브 상태머신 모델링 (팀원이 수행)

![Model]({{site.baseurl}}/assets/portfolio/uppaal2c/model.png)

* 수정된 UPPAAL2C를 이용하여 생성된 프로그램을 실제 시스템 상에서 구동

![Testbed]({{site.baseurl}}/assets/portfolio/uppaal2c/testbed.png)
![Test]({{site.baseurl}}/assets/portfolio/uppaal2c/test.png)

* 기존에 개발된 [모션 레시피]({{site.baseurl}}/portfolio/industrial-network/motion-recipe/)의 동작과 동일함을 확인
