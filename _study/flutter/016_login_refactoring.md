---
title: "Login refactoring"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/tTA1Vxxi3mg)를 보고 정리한 내용입니다.

## 생성자 파라미터 선언

생성자의 파라미터를 선언할 때 아래와 같이 `required` 키워드를 붙이거나,

{% highlight dart %}
const MyButton({
  super.key,
  required this.radius,
});
{% endhighlight %}

아니면 기본값을 정해주거나,

{% highlight dart %}
const MyButton({
  super.key,
  this.radius = 5.0,
});
{% endhighlight %}

아니면 nullable하게 만들어주면 된다.

{% highlight dart %}
final double? radius;

const MyButton({
  super.key,
  this.radius,
});
{% endhighlight %}

## private 멤버

`_buildButton()`과 같이 언더바로 시작하는 함수는 private 멤버가 되며, **같은 파일** 안에서만 접근이 가능해진다.

## 리팩토링

그 외의 내용은 중복되는 코드를 따로 빼고, 파라미터를 통해 다양한 상황에서 활용할 수 있게 하는 리팩토링 과정에 관한 내용이다.
