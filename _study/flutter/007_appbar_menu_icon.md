---
title: "앱바(app bar) 메뉴 아이콘 추가하기"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/ze0t5gWKBvE?si=FHNve8pLtsPmJiKN)를 보고 정리한 내용입니다.

![Complete]({{site.baseurl}}/assets/study/flutter/007_appbar_menu_icon/complete.png){: width="360" .custom-align-center-img}

오늘의 완성 화면이다.

## leading

`AppBar`의 `leading` 파라미터를 사용하면 앱바의 완쪽에 위젯을 배치할 수 있다.

{% highlight dart %}
return Scaffold(
  appBar: AppBar(
    // ...
    leading: IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        print('menu button is clicked');
      },
    ),
  ),
);
{% endhighlight %}

위 코드를 실행해 보면 앱바의 왼쪽에 메뉴 버튼이 추가된다. 버튼을 클릭했을 때의 동작은 `IconButton`의 `onPressed` 파라미터를 통해 정의할 수 있다.

## actions

`AppBar`의 `actions` 파라미터를 사용하면 앱바의 오른쪽에 여러 개의 위젯을 배치할 수 있다.

{% highlight dart %}
return Scaffold(
  appBar: AppBar(
    // ...
    actions: [
      IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () {
          print('cart button is clicked');
        },
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          print('search button is clicked');
        },
      ),
    ],
  ),
);
{% endhighlight %}
