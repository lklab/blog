---
title: 위젯
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/jI4kqLdqXic)를 보고 정리한 내용입니다.

## 위젯이란?

위젯은 독립적으로 실행되는 작은 프로그램으로 그래픽이나 데이터를 처리하는 함수(기능)를 가지고 있다. 플러터에서 위젯은 UI를 만들고 구성하는 기본 단위 요소다. (이미지, 텍스트, 아이콘, 텍스트필드, 버튼 등등) 또한 눈에 보이지 않는 레이아웃도 위젯이다.

플러터에서는 코드만으로 위젯을 구현한다.

플러터 위젯의 종류
* Stateless widget
* Stateful widget
* Inherited widget

## Stateless widgets, Stateful widgets

Stateless는 상태가 없다는 뜻으로 어떤 실시간 데이터도 저장하지 않고 정적인 위젯이며, Stateful은 상태를 가지고 있어서 이전 입력 값이나 현재 상태에 따라 변화하는 동적인 위젯이다.

Stateless widgets 예시
* 텍스트
* 정적인 이미지

Stateful widgets 예시
* 체크박스, 라디오 버튼
* 텍스트필드

## Widget tree

위젯들은 계층 구조를 가지고 있으며 이를 tree 구조로 표현된다. 한 위젯 내에 다른 여러 위젯들이 포함될 수 있다.
