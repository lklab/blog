---
title: "Flutter tips"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

플러터 공부하면서 기억할만한 팁들 정리

기기 스크린의 크기를 가져오고 싶으면 `MediaQuery.of(context).size`를 사용하면 된다.

{% highlight dart %}
MediaQuery.of(context).size.width
{% endhighlight %}

인라인 조건문을 사용해서 조건에 따라 특정 위젯을 보이거나 안 보이게 할 수 있다.

{% highlight dart %}
if (!isSignupScreen)
Container(
  // ...
),
{% endhighlight %}

`Animated{Widget}` 위젯을 사용하면 위젯의 속성이 변경될 때 그 값을 애니메이팅할 수 있다. 이 경우 `duration` 속성과 `curve` 속성을 필수로 지정해줘야 한다.

{% highlight dart %}
AnimatedContainer(
  duration: Duration(milliseconds: 500),
  curve: Curves.easeIn,
  height: isSignupScreen ? 280.0 : 250.0,
  // ...
)
{% endhighlight %}
