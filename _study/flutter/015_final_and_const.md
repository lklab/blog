---
title: "final and const"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

[플러터 강좌](https://youtu.be/akc51-j84os)를 보고 정리한 내용입니다.

`final` 변수와 `const` 변수 모두 할당된 값을 변경할 수 없다는 공통점이 있다. 차이점은 `const`는 컴파일 타임의 상수여야 하지만 `final`은 그럴 필요가 없다는 점이다. 따라서 `final` 변수는 다음과 같이 생성자에서 초기화할 수 있고 각 객체마다 다른 값을 가질 수 있다.

{% highlight dart %}
class Person {
    final int age;
    String name;

    Person(this.age, this.name);
}

void main() {
    Person p1 = new Person(21, 'Tom');
    print(p1.age);
}
{% endhighlight %}

`final` 변수는 `StatelessWidget`과 비슷하게 값을 변경하려면 rebuild 되어야 한다.

`const` 변수는 컴파일 타임의 상수이기 때문에 다음과 같이 초기화할 수 없다.

{% highlight dart %}
const time = DateTime.now();
{% endhighlight %}
