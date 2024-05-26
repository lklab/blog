---
title: "Navigator"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌 1](https://youtu.be/BWG9XS5ecig?si=t4onwXzB5rSE11j2), [플러터 강좌 2](https://youtu.be/rX2RZr6y8yM?si=rVN6G-aQ-nuFueKA)를 보고 정리한 내용입니다.

## Flutter의 페이지 이동

플러터에서는 `Navigator`를 통해 페이지를 이동할 수 있다. 각 페이지는 `Route` 객체를 의미한다. `Navigator`는 `Route`들을 stack 자료구조로 괸리하여 각각의 페이지를 '쌓는' 방식으로 전환한다. `Route`는 `Scaffold` 위젯을 반환하는 커스텀 위젯으로 구현된다. 모든 페이지는 `MaterialApp` 하위 위젯으로 들어간다.

## push & pop

`Navigator.push()` 함수를 호출하면 다른 페이지로 이동할 수 있다.`

{% highlight dart %}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const SecondPage(),
              )
            );
          },
          // ...
        ),
      ),
    );
  }
}
{% endhighlight %}

첫 번째 파라미터는 `BuildContext`를 받는데, 이 context에는 `MaterialApp` 위젯에 대한 정보가 있어야 한다. 두 번째 파라미터에는 `MaterialPageRoute` 객체를 전달하면 되는데, `builder`에 이동할 페이지를 리턴하는 함수를 작성하면 된다.

다시 원래 페이지로 돌아가려면 `Navigator.pop()` 함수를 호출하면 된다.

{% highlight dart %}
class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          // ...
        ),
      ),
    );
  }
}
{% endhighlight %}

두 번째 페이지에 `AppBar`가 있는 경우 앱바에 뒤로가기 버튼이 자동으로 생성된다.

![Back button]({{site.baseurl}}/assets/study/flutter/012_navigator/back_button.png){: width="360" .custom-align-center-img}

## pushNamed

`Navigator.push()` 함수 대신 `Navigator.pushNamed()` 함수로 페이지 이동을 할 수 있다.

여기서는 여러 개의 파일에 각각의 페이지 위젯을 구현하였다. 다른 파일에 정의된 위젯을 사용하려면 다음과 같이 import하면 된다.

{% highlight dart %}
import 'package:navigator/screen_a.dart';
{% endhighlight %}

`Navigator.pushNamed()` 함수를 사용하려면 먼저 각 페이지(`route`)의 이름과 `builder`를 연결짓는 `Map` 자료구조를 정의해야 한다.

{% highlight dart %}
MaterialApp(
  // ...
  // home: const FirstPage(),
  initialRoute: '/',
  routes: {
    '/' : (BuildContext _) => const ScreenA(),
    '/b' : (BuildContext _) => const ScreenB(),
    '/c' : (BuildContext _) => const ScreenC(),
  },
);

{% endhighlight %}

`MaterialApp`의 `routes` 파라미터에 위와 같이 정의한다. 일반적으로 최초 페이지의 이름으로는 `'/'`를 사용하며 다른 페이지들의 경우 그 경로를 고려하여 이름을 정의하면 된다. `initialRoute` 파라미터는 최초 페이지의 이름을 전달하면 되는데, `initialRoute` 파라미터는 `home` 파라미터와 동일한 역할을 하기 때문에 동시에 사용할 수 없다. 참고로 위의 builder 함수 정의와 같이 사용하지 않는 파라미터는 `_`로 선언하는 것이 좋다.

이제 `Navigator.pushNamed()` 함수에 이동하고자 하는 페이지의 이름을 전달하면 페이지 이동을 구현할 수 있다.

{% highlight dart %}
class ScreenA extends StatelessWidget {
  const ScreenA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      body: Center(
        child: Column(
          // ...
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/b');
              },
              // ...
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/c');
              },
              // ...
            ),
          ],
        ),
      ),
    );
  }
}
{% endhighlight %}
