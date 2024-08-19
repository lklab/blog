---
title: "Weather app"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

다음 플러터 강좌들을 보고 정리한 내용입니다.

* [강좌 13 \| 날씨 앱(weather app) 만들기 1](https://youtu.be/YqKMBQYZSmw)

## Widget lifecycle

Stateless widget은 한 번 생성되면 바뀌지 않기 때문에 바꾸고 싶다면 destroy 하고 rebuild해야 한다. 그리고 Stateful widget은 state object와 결합하여 위젯이 변경될 때 state object가 이를 감지해서 내용을 업데이트할 수 있다. 따라서 Stateful widget은 Stateless widget 보다 더 긴 생명주기를 가지고 더 많은 lifecycle method를 갖는다. 다음은 대표적인 3개의 lifecycle method다.

* `initState()`: state가 최초로 초기화될 때 호출됨
* `build()`: 위젯이 빌드될 때 호출됨
* `dispose()`: 위젯이 제거될 때 호출됨

{% highlight dart %}
import 'package:flutter/material.dart';

class ScreenB extends StatefulWidget {
  const ScreenB({super.key});

  @override
  State<ScreenB> createState() => _ScreenBState();
}

class _ScreenBState extends State<ScreenB> {
  @override
  void initState() {
    super.initState();
    print('initState is called');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose is called');
  }

  @override
  Widget build(BuildContext context) {
    print('build is called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen B'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Go to the Screen A',
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
{% endhighlight %}

위 코드는 `StatefulWidget`의 lifecycle method를 사용하는 방법을 보여준다.

`Navigator`를 통해 다른 페이지에서 `Screen B`로 진입할 때 `initState()`와 `build()`가 순서대로 호출되어서 로그에 `initState is called`와 `build is called`가 출력된다. 그 다음 `Go to the Screen A` 버튼을 클릭해서 `Screen B`에서 벗어나면 `dispose()`가 호출되어서 로그에 `dispose is called`가 출력된다.

## 현재 위치 가져오기

[geolocator](https://pub.dev/packages/geolocator) 패키지를 설치한다. `pubspec.yaml` 파일에 다음과 같이 `geolocator: ^13.0.1`를 추가하면 된다.

{% highlight yaml %}
dependencies:
  flutter:
    sdk: flutter
  geolocator: ^13.0.1
{% endhighlight %}

## API

API를 호출할 때에는 key가 필요하다.

## Exception handling

## Http package

## Json parsing

## Passing data
