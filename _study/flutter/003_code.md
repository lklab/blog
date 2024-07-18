---
title: 기본 코드 3
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/AXFV1JOr6_Q)를 보고 정리한 내용입니다.

## Scaffold

{% highlight dart %}
class MyHomePage extends StatelessWidget
{
    const MyHomePage({super.key});

    @override
    Widget build(BuildContext context)
    {
        return Scaffold(

        );
    }
}
{% endhighlight %}

`Scaffold` 위젯은 앱 화면에 다양한 요소를 배치하고 그릴 수 있도록 도와주는 빈 도화지 같은 역할을 한다.

## AppBar

{% highlight dart %}
return Scaffold(
    appBar: AppBar(
        title: const Text('App bar title'),
    ),
);
{% endhighlight %}

`appBar` 파라미터에 `AppBar` 위젯을 전달해서 앱바를 만들 수 있다. `AppBar`의 `title` 파라미터에는 `Text` 위젯을 전달해서 앱바에 텍스트를 표시하도록 한다.

![App bar]({{site.baseurl}}/assets/study/flutter/003_code/appbar.png){: width="360" .custom-align-center-img}

강의와 다르게 앱바에 배경색이 표시되지 않는다.. 플러터 시작 앱에 예시로 나와있는 것 처럼 다음과 같이 `ThemeData`와 `AppBar`의 파라미터를 설정하면 색상이 나오긴 한다. 이 부분은 좀 더 알아봐야 할 듯.

{% highlight dart %}
@override
Widget build(BuildContext context)
{
    return MaterialApp(
        title: 'First App',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
    );
}
{% endhighlight %}

{% highlight dart %}
return Scaffold(
    appBar: AppBar(
        title: const Text('App bar title'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
);
{% endhighlight %}

## body

{% highlight dart %}
return Scaffold(
    appBar: AppBar(
        title: const Text('App bar title'),
    ),
    body: const Center(
        child: Column(
            children: [
                Text('Hello'),
                Text('Hello'),
                Text('Hello'),
            ],
        ),
    ),
);
{% endhighlight %}

`body`에는 `Scaffold` 위젯 내에서 메인이 되는 위젯이 들어간다. 여기서는 모든 위제를 중앙에 배치하는 `Center` 위젯을 전달한다. `Center` 위젯은 하위 위젯을 `child` 파라미터로 받는데 여기서는 대표적으로 많이 쓰이는 `Column` 위젯을 사용하였다. `Column` 위젯은 자신 내 모든 위젯을 세로로 배치하는 기능을 갖는다. 따라서 `Column` 위젯은 여러 위젯을 `children` 파라미터에 배열로 받는다.

![Body]({{site.baseurl}}/assets/study/flutter/003_code/body.png){: width="360" .custom-align-center-img}
