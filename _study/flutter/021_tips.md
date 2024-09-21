---
title: "Flutter tips"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
---

플러터 공부하면서 기억할만한 팁들 정리

### 기기 스크린 크기 가져오기

기기 스크린의 크기를 가져오고 싶으면 `MediaQuery.of(context).size`를 사용하면 된다.

{% highlight dart %}
MediaQuery.of(context).size.width
{% endhighlight %}

### 인라인 조건문

인라인 조건문을 사용해서 조건에 따라 특정 위젯을 보이거나 안 보이게 할 수 있다.

{% highlight dart %}
if (!isSignupScreen)
Container(
  // ...
),
{% endhighlight %}

### 애니메이션

`Animated{Widget}` 위젯을 사용하면 위젯의 속성이 변경될 때 그 값을 애니메이팅할 수 있다. 이 경우 `duration` 속성과 `curve` 속성을 필수로 지정해줘야 한다.

{% highlight dart %}
AnimatedContainer(
  duration: Duration(milliseconds: 500),
  curve: Curves.easeIn,
  height: isSignupScreen ? 280.0 : 250.0,
  // ...
)
{% endhighlight %}

### TextFormField

유효성 검사를 하려면 `TextFormField`의 `validator` 파라미터에 함수를 등록하면 된다.

{% highlight dart %}
TextFormField(
  validator: (value) {
    if (value!.isEmpty || value.length < 4) {
      return 'Please enter at least 4 characters.';
    }
    return null;
  },
{% endhighlight %}

`null`이 아닌 값을 반환하면 텍스트 아래에 메시지가 표시된다.

![유효성 검사 텍스트]({{site.baseurl}}/assets/study/flutter/021_tips/2024-09-21-12.29.53.png){: width="360"}

유효성 검사는 `FormState`의 `validate()` 함수를 호출하여 실행할 수 있는데, `FormState`를 가져오기 위해서는 `Form`에 `GlobalKey`를 등록하면 된다.

{% highlight dart %}
final _formKey = GlobalKey<FormState>();

void _tryValidation() {
  final bool isValid = _formKey.currentState!.validate();
}

@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
  );
}
{% endhighlight %}

`FormState`의 `save()` 함수를 호출하면 `TextFormField`의 `onSaved` 파라미터에 등록된 함수가 호출된다.

{% highlight dart %}
String userName = '';

void _tryValidation() {
  final bool isValid = _formKey.currentState!.validate();
  if (isValid) {
    _formKey.currentState!.save();
  }
}

@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: Column(
      children: [
        TextFormField(
          key: ValueKey(1),
          onSaved: (value) {
            userName = value!;
          },
        ),
      ],
    ),
  );
}
{% endhighlight %}
