---
title: "Drawer 메뉴 만들기"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌 1](https://youtu.be/8gDhEdFhfys?si=9gLZq4VihAZtOh1r), [플러터 강좌 2](https://youtu.be/j5O49p7CL1o?si=AQcRqG-yTCwD5bOM)를 보고 정리한 내용입니다.

![Complete]({{site.baseurl}}/assets/study/flutter/008_drawer/complete.png){: width="360" .custom-align-center-img}

오늘의 완성 화면이다.

이미지 출처
* [https://assetstore.unity.com/packages/2d/environments/2d-space-kit-27662](https://assetstore.unity.com/packages/2d/environments/2d-space-kit-27662)

## Drawer

{% highlight dart %}
Scaffold(
  drawer: Drawer(
    child: 
  ),
);
{% endhighlight %}

`Scaffold` 위젯의 `drawer` 파라미터에 `Drawer` 위젯을 전달하고 이 위젯의 `child` 파라미터에 우리가 원하는 위젯을 추가하여 Drawer를 구현할 수 있다. `drawer` 파라미터를 사용하는 경우 자동으로 앱바의 좌상단에 메뉴 아이콘이 생기기 때문에, 이전 강좌에서 추가했던 `AppBar` 위젯의 `leading` 파라미터에 들어간 `IconButton` 위젯은 제거하도록 한다.

{% highlight dart %}
child: ListView(
  padding: EdgeInsets.zero,
  children: [
    // ...
  ],
),
{% endhighlight %}

`child` 파라미터에 `ListView` 위젯을 둬서 리스트 형식으로 출력되도록 한다.

## UserAccountsDrawerHeader

{% highlight dart %}
children: [
  UserAccountsDrawerHeader(
    currentAccountPicture: const CircleAvatar(
      backgroundImage: AssetImage('assets/Cruiser3.png'),
      backgroundColor: Colors.white,
    ),
    otherAccountsPictures: const [
      CircleAvatar(
        backgroundImage: AssetImage('assets/Destroyer1.png'),
        backgroundColor: Colors.white,
      ),
    ],
    accountName: const Text('BBANTO'),
    accountEmail: const Text('bbanto@bbanto.com'),
    onDetailsPressed: () {
      print('arrow is clicked');
    },
    decoration: BoxDecoration(
      color: Colors.red[200],
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40.0),
        bottomRight: Radius.circular(40.0),
      ),
    ),
  ),
  // ...
],
{% endhighlight %}

`children`의 첫 번째 위젯으로 `UserAccountsDrawerHeader`를 사용한다.

* `currentAccountPicture`를 통해 현재 사용자의 프로필 이미지를 지정할 수 있다.
* `otherAccountsPictures`를 통해 다른 사용자들의 프로필 이미지를 지정할 수 있다. 오른쪽에 작게 출력된다.
* `accountName`, `accountEmail`은 사용자의 이름과 메일인데, `UserAccountsDrawerHeader`의 생성자 정의를 보면 `required`로 되어 있어서 반드시 값을 지정해주어야 한다.
* `onDetailsPressed`를 설정하면 이름과 메일 오른쪽에 화살표 버튼이 생기는데 이를 눌렀을 때의 동작을 지정할 수 있다.
* `decoration`을 통해 `UserAccountsDrawerHeader` 위젯에 디자인적 요소를 더해줄 수 있다. 여기서는 하단 모서리를 라운드 처리하고 색상을 지정하였다.

## ListTile

{% highlight dart %}
children: [
  // ...
  ListTile(
    leading: Icon(
      Icons.home,
      color: Colors.grey[850],
    ),
    title: const Text('Home'),
    onTap: () {
      print('Home is clicked');
    },
    trailing: const Icon(Icons.add),
  ),
  ListTile(
    leading: Icon(
      Icons.settings,
      color: Colors.grey[850],
    ),
    title: const Text('Setting'),
    onTap: () {
      print('Setting is clicked');
    },
    trailing: const Icon(Icons.add),
  ),
  ListTile(
    leading: Icon(
      Icons.question_answer,
      color: Colors.grey[850],
    ),
    title: const Text('Q&A'),
    onTap: () {
      print('Q&A is clicked');
    },
    trailing: const Icon(Icons.add),
  ),
],
{% endhighlight %}

`children`의 나머지 위젯으로는 `ListTile`를 사용하였는데, 아이콘과 텍스트 및 클릭 이벤트를 지정할 수 있도록 되어 있어서 `ListView`와 함께 잘 사용된다.

* `leading`을 통해 왼쪽에 출력되는 아이콘(위젯)을, `trailing`을 통해 오른쪽에 출력되는 아이콘(위젯)을 지정할 수 있다.
* `title`을 통해 텍스트를 지정할 수 있다.
* `onTab`을 통해 클릭 이벤트 시 처리할 코드를 지정할 수 있다.
* `onTab`과 `onPressed`는 모두 사용자의 클릭 입력을 받는다는 것은 동일하지만 `onTab`의 경우 더블탭이나 제스쳐 이벤트를 받을 수 있다는 점이 다르다.
