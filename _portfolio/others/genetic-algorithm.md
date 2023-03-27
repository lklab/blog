---
layout: portfolio
title: Genetic algorithm을 이용한 automatic rule acquisition 알고리즘 구현
date: 2016-04-01
image: /assets/portfolio/genetic-algorithm/algorithm.png
tag:
  - 대학원
  - R
  - R Studio
  - Optimization
  - Genetic algorithm
summary:
  division: 학기 프로젝트
  period: 2016.04 - 2016.06 (3개월)
  platform: R Studio
  language: R
  work: 알고리즘 전체 개발 업무
---

## 주요 내용

* Rule acquisition : 훈련 데이터들의 규칙을 찾아내는 알고리즘
* 포커의 카드 5장(원인)과 그 결과(원 페어, 투 페어 등)가 쌍으로 이루어진 데이터들로 훈련
* 규칙을 찾아내는 최적화 알고리즘은 Genetic algorithm으로 구현
* Genetic algorithm : 생물의 진화 이론을 모방한 최적화 기법으로 다양한 규칙들의 집합인 "세대"에서 "선택", "교차", "변이" 등의 연산을 통해 세대를 거듭할수록 더 최적화된 규칙들로 이루어진 세대를 얻어내는 방법

## 개발 결과

* R로 작성된 최적화 알고리즘

![Algorithm]({{site.baseurl}}/assets/portfolio/genetic-algorithm/algorithm.png)
![Functions]({{site.baseurl}}/assets/portfolio/genetic-algorithm/functions.png)

* 최적화 결과
  * 최적화된 알고리즘이 거의 모든 입력 데이터에 대해 "해당 규칙이 아님"만을 판단함
  * 한 예로 Straight에 대해 테스트 데이터를 입력한 결과, 데이터들에 대해 대부분 "Straight 가 아님"을 판단함
  * 이것은 훈련 데이터가 Straight에 대한 내용을 많이 담고 있지 않아 발생하는 현상으로 생각됨
  * 알고리즘의 개선이 필요함
