---
title: "BuildContext"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌 1](https://youtu.be/o-HpnWhI70U), [플러터 강좌 2](https://youtu.be/-zxGPfjiQQA)를 보고 정리한 내용입니다.

## BuildContext

위젯 클래스를 정의하는 경우 아래와 같이 `build()` 함수를 재정의해야 하는데 이 함수는 파라미터로 `BuildContext`를 받는다.

{% highlight dart %}
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}
{% endhighlight %}

[공식 문서](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)에 소개된 `BuildContext`의 정의는 다음과 같다.

> A handle to the location of a widget in the widget tree.

`BuildContext`는 위젯 트리에서 현재 위젯의 위치에 관한 정보라는 것이다.

그리고 중요한 내용이 나온다.

> Each widget has its own BuildContext, which becomes the parent of the widget returned by the StatelessWidget.build or State.build function. (And similarly, the parent of any children for RenderObjectWidgets.)

각 위젯은 자신만의 `BuildContext`를 갖고 있는데, 이것은 `StatelessWidget.build()` 또는 `State.build()` 함수에서 반환하는 위젯의 부모가 된다는 것이다. 위의 코드에서 보면 `MyPage.build()` 함수의 파라미터로 들어오는 `BuildContext`는 `Scaffold` 위젯의 부모, 즉 `MyPage`의 `BuildContext`다. 생각해보면 당연한게 `build()` 함수를 호출하는 시점에서는 이 함수가 어떤 위젯을 반환할지 모르는 상태이기 때문에 그 반환되는 위젯(여기서는 `Scaffold`)에 대한 정보가 `BuildContext`에 들어있을 수 없는 것이다.

## SnackBar를 통해 BuildContext를 더 알아보기

`Scaffold.of()` 함수는 파라미터로 들어오는 `BuildContext`를 기준으로 위로 올라가면서 `Scaffold` 위젯을 찾는 함수이다. 그런데 앞서 언급했다시피 `MyPage.build()`의 `BuildContext`에는 `Scaffold` 위젯이 없다. 따라서 아래와 같이 `Scaffold.of(context);` 함수를 호출하면 오류가 발생한다.

{% highlight dart %}
return Scaffold(
  // ...
  body: Center(
    child: ElevatedButton(
      onPressed: () {
        Scaffold.of(context); // error!
      },
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(
          fontSize: 15,
        )),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        backgroundColor: MaterialStateProperty.all(Colors.blue),
      ),
      child: const Text('Show me'),
    ),
  ),
);
{% endhighlight %}

`Scaffold.of() called with a context that does not contain a Scaffold.`

`BuildContext`에 `Scaffold` 위젯이 없기 때문에 `Scaffold.of()` 함수에서 오류가 발생하는 것이다.

이를 해결하기 위해 `Builder` 위젯을 활용할 수 있다. `Builder` 위젯은 `builder` 파라미터에 자신의 `BuildContext`를 파라미터로 제공하는 함수를 정의할 수 있다. 따라서 `MyPage` - `Scaffold` - `Builder`로 이어지는 위젯 트리 상에서 `Builder` 위젯의 `BuildContext`를 사용하면 `Scaffold.of()` 함수를 통해 성공적으로 `Scaffold` 위젯을 가져올 수 있게 된다.

{% highlight dart %}
return Scaffold(
  // ...
  body: Builder(
    builder: (BuildContext ctx) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Scaffold.of(ctx); // OK!
          },
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: 15,
            )),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          child: const Text('Show me'),
        ),
      );
    },
  ) 
);
{% endhighlight %}

그런데 강좌에서는 `Scaffold.of()`에 `showSnackBar` 함수가 없어서 찾아보니 현재는 `ScaffoldMessenger.of()` 함수를 사용해야 하는 것으로 변경되어 있었다. 그 동안 `SnackBar` 관련해서 위와 같은 오류가 많이 발생해서 변경된 것인가 싶다. `ScaffoldMessenger.of()` 함수를 사용하게 되면 `Builder` 위젯을 사용할 필요 없이 다음과 같이 `SnackBar`를 출력할 수 있게 된다.

`ScaffoldMessenger`는 `MaterialApp`이 관리하며 여러 `Scaffold`(추후에 나올 `Route`에 따라 페이지별로 각각 `Scaffold`를 보유하게 됨)를 가지고 있다. 따라서 페이지가 바뀌더라도(`Scaffold`가 바뀌어도) `SnackBar`를 지속적으로 출력할 수 있게 된다. [참고](https://youtu.be/IKpOAQJbADk?si=sSSQEIP20mdjljge)

만약 현재 페이지에서만 스낵바를 보여주고 싶다면 그 `Scaffold`를 `ScaffoldMessenger`로 감싸면 된다. 그렇게 하면 `ScaffoldMessenger.of()`가 `MaterialApp`의 `ScaffoldMessenger`가 아닌 현재 페이지에 새로 정의한 `ScaffoldMessenger`를 가리키게 되므로 현재 페이지를 벗어나면 스낵바가 사라지게 된다.

{% highlight dart %}
return Scaffold(
  // ...
  body: Center(
    child: ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Hello'),
        ));
      },
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(const TextStyle(
          fontSize: 15,
        )),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        backgroundColor: MaterialStateProperty.all(Colors.blue),
      ),
      child: const Text('Show me'),
    ),
  ),
);
{% endhighlight %}

![Complete]({{site.baseurl}}/assets/study/flutter/009_build_context/complete.png){: width="360" .custom-align-center-img}
