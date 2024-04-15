---
title: "캐릭터 페이지 디자인 1: 위젯 정리"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/gUVAUOvPm_c?si=C2KMKBUr_6F5iAOJ)를 보고 정리한 내용입니다.

## 앱바 색상 및 정렬

{% highlight dart %}
return Scaffold(
  appBar: AppBar(
    title: const Text('BBANTO'),
    centerTitle: true,
    backgroundColor: Colors.redAccent,
    foregroundColor: Colors.white,
    elevation: 0.0,
  ),
);
{% endhighlight %}

* `centerTitle`: 앱 타이틀을 가운데 정렬한다.
* `backgroundColor`: 앱바의 배경색을 지정한다.
* `foregroundColor`: 앱바의 포그라운드 색상을 지정한다.
* `elevation`: 뭔가 드롭쉐도우 효과를 주는 거라는데 큰 차이를 모르겠음

![App bar]({{site.baseurl}}/assets/study/flutter/004_align_widget/appbar.png){: width="360" .custom-align-center-img}

## Padding

{% highlight dart %}
body: const Padding(
  padding: EdgeInsets.fromLTRB(30.0, 40.0, 0.0, 0.0),
  child: Column(
    children: [
      Text('Hello'),
      Text('Hello'),
      Text('Hello'),
    ],
  ),
),
{% endhighlight %}

`EdgeInsets.fromLTRB(30.0, 40.0, 0.0, 0.0)`를 통해 패딩 값을 지정할 수 있다. 여기서는 left=30, top=40을 지정하고 나머지는 모두 0으로 설정했다. 실행해보면 다음과 같이 텍스트들이 좌상단에 일정 거리만큼 떨어진 상태로 세로로 배치된다.

![Padding]({{site.baseurl}}/assets/study/flutter/004_align_widget/padding.png){: width="360" .custom-align-center-img}

{% highlight dart %}
body: const Padding(
  padding: EdgeInsets.fromLTRB(30.0, 40.0, 0.0, 0.0),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('Hello'),
      Text('Hello'),
      Text('Hello'),
    ],
  ),
),
{% endhighlight %}

`mainAxisAlignment`는 `Column` 위젯 자체를 화면 세로축 기준으로 상단, 중앙, 하단에 배치할 수 있는 옵션이다. `MainAxisAlignment.center`로 설정하면 다음과 같이 텍스트들이 화면 세로축 기준 중앙에 배치된다.

![MainAxisAlignment]({{site.baseurl}}/assets/study/flutter/004_align_widget/mainAxisAlignment.png){: width="360" .custom-align-center-img}

## Center

만약 화면 가로축 기준으로 중앙에 배치하고 싶다면 `Padding` 위젯 대신 `Center` 위젯을 사용하면 된다.

{% highlight dart %}
body: const Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('Hello'),
      Text('Hello'),
      Text('Hello'),
    ],
  ),
),
{% endhighlight %}

![Center]({{site.baseurl}}/assets/study/flutter/004_align_widget/center.png){: width="360" .custom-align-center-img}
