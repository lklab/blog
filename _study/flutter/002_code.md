---
title: 플러터 코드 2
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/bapuCsJXBdc?si=FKnDl7BNH93siC9V)를 보고 정리한 내용입니다.

## MyApp 위젯 작성

{% highlight dart %}
class MyApp extends StatelessWidget
{
	const MyApp({super.key});

	@override
	Widget build(BuildContext context)
	{
		return MaterialApp();
	}
}
{% endhighlight %}

`MyApp` 위젯은 최상위 위젯이다. 앱의 레이아웃을 만다는 역할만 하기 때문에 `StatelessWidget`으로 지정한다.

`build()`는 또다른 커스텀 위젯을 리턴하는 역할을 한다. 여기서는 flutter material 라이브러리를 사용할 수 있는 기능을 가진 `MaterialApp`위젯을 리턴한다. 이제 flutter가 제공하는 모든 기본 위젯과 디자인을 사용할 수 있게 된다. 그리고 `MaterialApp`은 `MyApp`을 이거 위젯 트리의 두 번째 위젯이 된다.

## MaterialApp 위젯 세팅

{% highlight dart %}
@override
Widget build(BuildContext context)
{
	return MaterialApp(
		title: 'First App',
		theme: ThemeData(
			primarySwatch: Colors.blue
		),
		home: MyHomePage(),
	);
}
{% endhighlight %}

`title`을 통해 앱의 타이틀을 지정할 수 있다.

`theme`를 통해 앱의 테마를 지정할 수 있다. 여기서 `primarySwatch`를 통해 메인 컬러 견본을 설정할 수 있다.

`home`을 통해 앱 실행 후 가장 먼저 보일 화면을 지정할 수 있다. 여기서는 `MyHomePage`라는 커스텀 위젯을 지정했다.
