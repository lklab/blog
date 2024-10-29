---
title: "Stream builder"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
last_modified_at: 2024-10-12
---

[플러터 강좌](https://youtu.be/YojoXx383TI)를 보고 정리한 내용입니다.

## Stream\<T\>

`Stream<T>`은 데이터의 흐름이 발행되는 객체이다.

{% highlight dart %}
Stream<int> addStreamValue() {
  return Stream<int>.periodic(
    Duration(seconds: 1),
    (count) {
      return price + count;
    },
  );
}
{% endhighlight %}

## StreamBuilder

`StreamBuilder`는 `Stream<T>`에 따라 내용을 업데이트할 수 있는 위젯이다.

{% highlight dart %}
StreamBuilder<int>(
  initialData: price,
  stream: addStreamValue(),
  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
    final priceNumber = snapshot.data.toString();
    return Center(
      child: Text(
        priceNumber,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40,
          color: Colors.blue,
        ),
      ),
    );
  },
),
{% endhighlight %}
