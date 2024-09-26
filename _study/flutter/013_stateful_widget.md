---
title: "Stateful widget"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
last_modified_at: 2024-06-16
---

[플러터 강좌 1](https://youtu.be/StvbitxUKSo), [플러터 강좌 2](https://youtu.be/OvWrOKMqSG0)를 보고 정리한 내용입니다.

## Hot reload

Widget tree외에 Element tree와 Render tree가 있다. 이 두 tree는 시스템이 자동으로 생성한다. Element tree는 Widget tree와 Render tree를 연결하며, 각각 위젯에 1:1 대응하는 element를 생성한다. 각각의 element는 Render tree의 Render object와 역시 1:1 대응하여 화면에 그려지게 된다. [참고](https://youtu.be/StvbitxUKSo?t=465)

Reload는 전체적인 것은 그대로 둔 채 부수적인 것만 바꾸는 것이고 Rebuild는 전체적으로 바꾸는 것이다. Hot reload 시 Widget tree가 rebuild 될 때 element tree는 특정 element에 해당하는 widget의 위치나 타입 속성 등이 일치하는 경우 rebuild 되지 않고 widget에 대한 링크만 업데이트된다. 이 때 바뀐 정보가 화면에 표시되도록 Render object에게 다시 그리도록 한다.

Stateless widget은 rebuild 되어야만 state를 변경할 수 있다.

## Stateful Widget

Stateful Widget은 데이터와 연동이 된다. State는 UI가 변경되도록 영향을 미치는 데이터다. App 수준과 Widget 수준의 데이터가 있다. Stateless Widget은 State가 변하지 않는 위젯이다.

Stateful Widget은 Stateless Widget과 다르게 State 클래스를 갖고 있으며, 이 State 클래스가 build method를 호출하여 화면에 그리도록 한다. Stateful Widget은 Widget을 상속받기 때문에 기본적으로 불변이다. 그렇기 때문에 State 클래스를 따로 두어서 state의 변화에 따라 위젯을 다시 그리도록 하는 방법으로 위젯이 변경되도록 하는 것이다. 다음의 예시를 보자.

{% highlight dart %}
import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainAppState();
  }
}

class _MainAppState extends State<MainApp> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World! $counter'),
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            counter++;
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}
{% endhighlight %}

`MainApp`은 `StatefulWidget` 위젯을 상속받는다. 이제 `build` 함수를 오버라이드하지 않고 대신 `createState` 함수를 오버라이드한다. 이 함수에서는 `MainApp`과 관련된 state 객체를 반환해야 한다. 이를 위해 아래쪽에 `_MainAppState` 클래스를 선언하였다. 이 클래스는 `State`를 상속 받는데 제네릭 타입으로 `MainApp`을 전달해서 이 클래스는 `MainApp`의 state임을 플러터에 알려준다. `_MainAppState`는 기존의 stateless widget 처럼 `build` 함수를 오버라이드한다. `floatingActionButton`의 `onPressed`에 전달한 함수를 보면 `setState()` 함수를 호출하고 있다. `counter` 변수만 업데이트하면 widget이 rebuild 되지 않기 때문에 `setState()` 함수를 호출해서 관련된 widget이 rebuild 되도록 한다.
