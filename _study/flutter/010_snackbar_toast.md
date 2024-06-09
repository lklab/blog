---
title: "SnackBar & Toast"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/7E8l9ggxz-Q)를 보고 정리한 내용입니다.

![Complete]({{site.baseurl}}/assets/study/flutter/010_snackbar_toast/complete.png){: width="360" .custom-align-center-img}

오늘의 완성 화면이다.

## Snack Bar

{% highlight dart %}
Scaffold(
  appBar: AppBar(
    title: const Text('Snack Bar & Toast'),
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    centerTitle: true,
  ),
  body: const MySnackBar(),
);
{% endhighlight %}

이전 Build Context에 이어서.. 이렇게 `Scaffold` 위젯 안에 `MySnackBar` 커스텀 위젯을 만들면 `MySnackBar.build()` 함수의 `BuildContext`는 `MySnackBar`의 것이 되므로 `Scaffold.of(context);`를 통해 `Scaffold` 위젯을 찾을 수 있게 된다. 물론 이제는 `ScaffoldMessenger.of()`을 사용하므로 상관 없긴 하다.

{% highlight dart %}
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  content: Text(
    'Hello',
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.white,
    ),
  ),
  backgroundColor: Colors.teal,
  duration: Duration(
    milliseconds: 1000,
  ),
));
{% endhighlight %}

`SnackBar` 위젯의 다양한 파라미터를 통해 색상, 지속시간 등을 설정할 수 있다.

## Toast

`Toast`를 사용하기 위해서는 `pubspec.yaml` 파일에 `fluttertoast` 패키지를 추가해야 한다. (2024년 5월 기준 `^8.2.2` 버전 사용)

{% highlight yaml %}
dependencies:
  flutter:
    sdk: flutter


  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.6
  fluttertoast: ^8.2.2
{% endhighlight %}

그리고 main.dart 파일에 `fluttertoast` 패키지를 import 한다.

{% highlight dart %}
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
{% endhighlight %}

아래와 같이 함수를 선언하여 토스트를 사용할 수 있다.

{% highlight dart %}
void flutterToast() {
  Fluttertoast.showToast(
    msg: 'Hello',
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.redAccent,
    fontSize: 20.0,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}
{% endhighlight %}

`SnackBar`와 마찬가지로 색상, 폰트, 지속시간 등을 설정할 수 있다.
