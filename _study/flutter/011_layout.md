---
title: "Layout"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌 1](https://youtu.be/RhEzrNTSW7c), [플러터 강좌 2](https://youtu.be/8ZpMFUlFcvo)를 보고 정리한 내용입니다.

## Container

`Container` 위젯은 child가 없을 경우 가능한 최대한의 공간을 차지한다.

{% highlight dart %}
Scaffold(
  backgroundColor: Colors.blue,
  body: Container(
    color: Colors.red,
  ),
);
{% endhighlight %}

![No children]({{site.baseurl}}/assets/study/flutter/011_layout/containers_with_no_children.png){: width="360" .custom-align-center-img}

child가 있을 경우 해당 child의 크기에 딱 맞는 크기가 된다.

{% highlight dart %}
Scaffold(
  backgroundColor: Colors.blue,
  body: Container(
    color: Colors.red,
    child: const Text(
      'Hello',
      style: TextStyle(
        backgroundColor: Colors.green,
      )
    ),
  ),
);
{% endhighlight %}

![Child]({{site.baseurl}}/assets/study/flutter/011_layout/container_with_child.png){: width="360" .custom-align-center-img}

`SafeArea` 위젯을 사용하면 child 위젯이 safe area 내에 배치되도록 할 수 있다.

{% highlight dart %}
Scaffold(
  backgroundColor: Colors.blue,
  body: SafeArea(
    child: Container(
      color: Colors.red,
      child: const Text(
        'Hello',
        style: TextStyle(
          backgroundColor: Colors.green,
        )
      ),
    ),
  ),
);
{% endhighlight %}

![Safe area]({{site.baseurl}}/assets/study/flutter/011_layout/safe_area.png){: width="360" .custom-align-center-img}

`margin`, `padding` 등을 사용하여 위젯의 위치와 child 위젯의 위치(여백) 등을 지정할 수 있다.

{% highlight dart %}
child: Container(
  color: Colors.red,
  width: 100,
  height: 100,
  margin: const EdgeInsets.symmetric(
    vertical: 80.0,
    horizontal: 20.0,
  ),
  padding: const EdgeInsets.all(20.0),
  child: const Text(
    'Hello',
    style: TextStyle(
      backgroundColor: Colors.green,
    )
  ),
),
{% endhighlight %}

![Margin]({{site.baseurl}}/assets/study/flutter/011_layout/margin.png){: width="360" .custom-align-center-img}

## Column & Row

`Column`, `Row` 위젯을 사용하면 위젯들을 세로, 가로 방향으로 정렬할 수 있다. 다음은 `Column` 위젯에 대해서만 설명하며 `Row` 위젯의 경우 세로, 가로 방향이 서로 반전된다고 이해하면 된다.

`Column` 위젯은 세로 방향으로 child 위젯들의 크기와 상관 없이 항상 가능한 최대 크기를 차지한다. 따라서 `Center` 위젯 안에 있어도 내부 위젯들이 세로 방향으로는 중앙으로 정렬되지 않는다.

{% highlight dart %}
child: Center(
  child: Column(
    children: [
      Container(
        width: 100,
        height: 100,
        color: Colors.white,
        child: const Text('Container 1'),
      ),
      Container(
        width: 100,
        height: 100,
        color: Colors.blue,
        child: const Text('Container 2'),
      ),
      Container(
        width: 100,
        height: 100,
        color: Colors.red,
        child: const Text('Container 3'),
      ),
    ],
  ),
),
{% endhighlight %}

![Column 0]({{site.baseurl}}/assets/study/flutter/011_layout/column00.png){: width="360" .custom-align-center-img}

세로 방향으로도 중앙 정렬하려면 `mainAxisAlignment` 파라미터를 활용하면 된다.

{% highlight dart %}
child: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(/* ... */),
      Container(/* ... */),
      Container(/* ... */),
    ],
  ),
),
{% endhighlight %}

![Column 1]({{site.baseurl}}/assets/study/flutter/011_layout/column01.png){: width="360" .custom-align-center-img}

`center` 대신 `spaceEvenly`, `spaceBetween`을 사용하면 위젯의 양쪽 끝 여백을 포함/제외하면서 각각의 위젯들의 간격을 동일하게 배치할 수 있다.

![Column 3]({{site.baseurl}}/assets/study/flutter/011_layout/column03.png){: width="360"}
![Column 4]({{site.baseurl}}/assets/study/flutter/011_layout/column04.png){: width="360"}

`verticalDirection`을 사용해서 순서를 변경할 수 있다.

{% highlight dart %}
child: Center(
  child: Column(
    verticalDirection: VerticalDirection.up,
    children: [
      Container(/* ... */),
      Container(/* ... */),
      Container(/* ... */),
    ],
  ),
),
{% endhighlight %}

![Column 2]({{site.baseurl}}/assets/study/flutter/011_layout/column02.png){: width="360" .custom-align-center-img}

`crossAxisAlignment`를 사용하면 위젯들의 가로 방향 정렬도 설정할 수 있다. (`Row` 위젯에서는 세로 방향 정렬) 다만 위젯들의 크기가 모두 같으면 정렬되는 것이 보이지 않기 때문에 가운데 위젯의 가로 크기를 변경하였다.

{% highlight dart %}
child: Center(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(/* ... */),
      Container(width: 300, /* ... */),
      Container(/* ... */),
    ],
  ),
),
{% endhighlight %}

![Column 5]({{site.baseurl}}/assets/study/flutter/011_layout/column05.png){: width="360" .custom-align-center-img}

`CrossAxisAlignment.stretch`를 각 위젯들의 가로 길이에 상관 없이 가능한 최대 크기로 화면을 채우게 된다.

{% highlight dart %}
child: Center(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(/* ... */),
      Container(/* ... */),
      Container(/* ... */),
    ],
  ),
),
{% endhighlight %}

![Column 6]({{site.baseurl}}/assets/study/flutter/011_layout/column06.png){: width="360" .custom-align-center-img}

`SizedBox` 위젯을 활용하면 child 위젯들 사이의 간격을 설정할 수 있다.

{% highlight dart %}
child: Center(
  child: Column(
    children: [
      Container(/* ... */),
      const SizedBox(height: 30.0),
      Container(/* ... */),
      Container(/* ... */),
    ],
  ),
),
{% endhighlight %}

![Column 7]({{site.baseurl}}/assets/study/flutter/011_layout/column07.png){: width="360" .custom-align-center-img}
