---
title: "Null safety"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
last_modified_at: 2024-08-18
---

[플러터 강좌 1](https://youtu.be/0LNUSnmzDg4), [플러터 강좌 2](https://youtu.be/QP0THWoDeag)를 보고 정리한 내용입니다.

##  Null safety

모든 nullable 하지 않는 클래스 멤버 변수는 선언과 동시에 초기화해야 하지만 `late` 키워드를 사용하면 해당 변수를 참조하기 전까지만 초기화하면 된다.

{% highlight dart %}
class Person {
  late int age;
  
  int sum(int age, int num) {
    this.age = age;
    int total = age + num;
    return total + age;
  }
}

void main() {
  Person p = Person();
  print(p.sum(100, 50));
}
{% endhighlight %}

만약 다음과 같이 초기화하지 않고 사용한다면

{% highlight dart %}
int sum(int age, int num) {
//  this.age = age;
  int total = age + num;
  return total + this.age;
}
{% endhighlight %}

런타임에 `LateError`를 발생시킨다.

{% highlight txt %}
DartPad caught unhandled LateError:
LateInitializationError: Field 'age' has not been initialized.
{% endhighlight %}

Nullable 변수를 non-nullable 변수에 대입할 때 이 변수의 값이 반드시 null이 아님을 컴파일러에게 알려주려면 다음과 같이 `!`를 사용한다. (`!`를 exclamation 또는 bang이라고 읽는다고 한다.)

{% highlight dart %}
int x = 50;
int? y;
if (x > 0) {
  y = 10;
}
int value = y!;
{% endhighlight %}

Named parameter는 optional하기 때문에 기본 값을 넣어 주거나, `required` 키워드를 추가하거나, nullable하게 만들어야 한다.

오류!

{% highlight dart %}
int add({int a, int b})
{
  return a + b;
}
{% endhighlight %}

해결 방법 1: 기본 값 넣어주기

{% highlight dart %}
int add({int a = 1, int b = 2})
{
  return a + b;
}
{% endhighlight %}

해결 방법 2: `required` 키워드를 추가하기

{% highlight dart %}
int add({required int a, required int b})
{
  return a + b;
}
{% endhighlight %}

해결 방법 3: nullable하게 만들기

{% highlight dart %}
int add({int? a, int? b})
{
  if (a != null && b != null) {
    return a + b;
  }
  else {
    return 0;
  }
}
{% endhighlight %}

## Lazy initialization

다음 코드를 실행하면 `Person` 인스턴스를 생성할 때 `calculation()` 함수가 실행되어서 `'calculate'` 다음에 `'Person created'`가 출력된다.

{% highlight dart %}
class Person {
  int age = calculation();
}

int calculation() {
  print('calculate');
  return 30;
}

void main() {
  Person p = Person();
  print('Person created');
  print(p.age);
}
{% endhighlight %}

{% highlight txt %}
calculate
Person created
30
{% endhighlight %}

하지만 다음과 같이 `age`에 `late` 키워드를 실행한 경우 `age`를 참조하는 시점에 `calculation()` 함수가 실행되어서 `'Person created'` 다음에 `'calculate'`가 출력된다.

{% highlight dart %}
class Person {
  late int age = calculation();
}

int calculation() {
  print('calculate');
  return 30;
}

void main() {
  Person p = Person();
  print('Person created');
  print(p.age);
}
{% endhighlight %}

{% highlight txt %}
Person created
calculate
30
{% endhighlight %}
