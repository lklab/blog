---
title: "캐릭터 페이지 디자인 2: 실전코딩 part 1"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
last_modified_at: 2024-06-09
---

[플러터 강좌](https://youtu.be/smRqtp5YKa4)를 보고 정리한 내용입니다.

![Complete]({{site.baseurl}}/assets/study/flutter/005_charactor_page_1/complete.png){: width="360" .custom-align-center-img}

오늘의 완성 화면이다.

{% highlight dart %}
return Scaffold(
  backgroundColor: Colors.amber[800],
  appBar: AppBar(
    title: const Text('BBANTO'),
    backgroundColor: Colors.amber[700],
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0.0,
  ),
  // body: { ... }
);
{% endhighlight %}

* `Scaffold`의 `backgroundColor` 파라미터를 통해 전체적인 배경색을 지정할 수 있다.
* `Colors.amber[700]`의 `[700]`과 같이 특정 색상 계열의 색을 지정할 수 있다.

{% highlight dart %}
body: const Padding(
  padding: EdgeInsets.fromLTRB(30.0, 40.0, 0.0, 0.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    // children: { ... }
  ),
),
{% endhighlight %}

* `Column` 위젯을 통해 위젯들을 세로로 배치한다.
* 자식 위젯들의 가로 길이가 서로 다른 경우 각 자식 위젯들의 왼쪽을 기준으로 맞추고 싶다면 `crossAxisAlignment`를 `CrossAxisAlignment.start`로 설정하면 된다.
* 참고로 `CrossAxisAlignment.end`로 설정한 경우 아래와 같이 된다.

![CrossAxisAlignment]({{site.baseurl}}/assets/study/flutter/005_charactor_page_1/CrossAxisAlignment.png){: width="360" .custom-align-center-img}

{% highlight dart %}
children: [
  Text(
    'NAME',
    style: TextStyle(
      color: Colors.white,
      letterSpacing: 2.0,
    ),
  ),
  SizedBox(
    height: 10.0,
  ),
  Text(
    'BBANTO',
    style: TextStyle(
      color: Colors.white,
      letterSpacing: 2.0,
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
  ),
],
{% endhighlight %}

* `TextStyle`을 통해 `Text` 위젯 텍스트의 스타일을 지정할 수 있다.
* 자식 위젯들의 간격을 늘리기 위해 중간에 `SizedBox` 위젯을 추가하고 높이 값을 지정하는 방법이 있다.
