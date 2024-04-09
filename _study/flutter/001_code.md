---
title: 플러터 코드 1
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/b5wbsJFXVTM?si=Ef4aZvWNS-g0fL-6)를 보고 정리한 내용입니다.

## 프로젝트 폴더 구성

### pubspec.yaml

프로젝트의 메타데이터를 정의하고 관리하는 파일이다. 프로젝트의 버전, 환경, 의존성과 서드파티 라이브러리를 여기에 정의한다.

### android, ios 폴더

각 플랫폼에 맞게 배포하기 위한 정보를 가지고 있다.

### test 폴더

개발하기 원하는 테스트 코드를 실행해볼 수 있다.

### lib 폴더

작업해야 하는 코드 파일이 들어있다.

## 기본 구성

가장 먼저 flutter material 라이브러리를 import해야 한다. 이렇게 해야 기본 위젯과 테마 요소를 사용할 수 있다. material 디자인은 모바일 데스크탑 등을 아우르는 일관된 디자인을 위해 구글이 제공한 가이드라인이다. 다음과 같이 import할 수 있다.

{% highlight dart %}
import 'package:flutter/material.dart';
{% endhighlight %}

메인 함수는 다음과 같이 작성한다. `MyApp()`은 커스텀 위젯이다.

{% highlight dart %}
void main() => runApp(MyApp())
{% endhighlight %}

명명법은 카멜 케이스를 사용하며, 함수명은 소문자로 시작하고 클래스명은 대문자로 시작한다.
