---
title: "Dice login app"
image: /assets/study/main/flutter_logo.png
author: khlee
layout: post
last_modified_at: 2024-06-23
---

다음 플러터 강좌들을 보고 정리한 내용입니다.
* [Part 1](https://youtu.be/mQX_kJKnZzk)
* [Part 2](https://youtu.be/6-1PGcPgF9M)
* [Part 3](https://youtu.be/mmR2u8TgoCk)

## 로그인 페이지 구현하기

아래와 같은 화면을 구현할 것이다. [전체 코드](https://github.com/lklab/flutter-test/blob/master/login_dice/lib/main.dart)

![Login complete]({{site.baseurl}}/assets/study/flutter/014_dice_app/login_complete.png){: width="360" .custom-align-center-img}

#### Form 위젯

{% highlight dart %}
Form(
  child: Theme(
    data: ThemeData(
      primaryColor: Colors.teal,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: Colors.teal,
          fontSize: 15.0,
        ),
      ),
    ),
    child: // ...
  ),
),
{% endhighlight %}

`TextField` 위젯으로 정보를 입력 받을 때 일반적으로 `Form` 위젯을 사용한다. 여기서는 `ThemeData`를 사용해서 입력 필드가 선택되었을 때의 강조 색상을 설정하고 레이블의 색상과 크기도 설정하였다.

#### TextField 위젯

{% highlight dart %}
TextField(
  decoration: InputDecoration(
    labelText: 'Enter "dice"',
  ),
  keyboardType: TextInputType.emailAddress,
  // obscureText: true,
),
{% endhighlight %}

`InputDecoration`의 `labelText` 속성을 통해 레이블 텍스트를 설정할 수 있고, `keyboardType` 속성을 통해 키보드 타입(키보드 자판의 구성)을 지정할 수 있다. 비밀번호와 같이 입력된 내용을 안 보이게 하려는 경우 `obscureText` 속성을 `true`로 설정하면 된다.

#### SingleChildScrollView 위젯

키보드가 화면에 올라와서 위젯의 일부가 가려진 경우 디버그 모드에서 아래와 같은 경고 문구가 출력된다.

![View overflowed]({{site.baseurl}}/assets/study/flutter/014_dice_app/login_overflow.png){: width="360" .custom-align-center-img}

여기서는 `SingleChildScrollView` 위젯을 사용해서 스크롤될 수 있게 하는 방법으로 해결하였다. 앱바를 제외한 화면 전체에 적용되어야 하므로 `Scaffold`의 `body`로 `SingleChildScrollView`을 사용하고 모든 컨텐츠를 그 `child`로 넣었다.

{% highlight dart %}
return Scaffold(
  appBar: // ...
  body: SingleChildScrollView(
    child: Column(
      children: [
        // ...
        Form(
          // ...
        ),
      ],
    ),
  ),
);
{% endhighlight %}

#### TextField 값 가져오기

`TextField`의 값은 `TextEditingController`를 통해 가져올 수 있다. 먼저 아래와 같이 `TextEditingController` 변수를 선언하고

{% highlight dart %}
class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}
{% endhighlight %}

`TextField`의 `controller` 속성에 해당 변수를 대입하면 된다.

{% highlight dart %}
TextField(
  // ...
  controller: controller,
),
TextField(
  // ...
  controller: controller2,
),
{% endhighlight %}

값을 가져올 때에는 다음과 같이 하면 된다.

{% highlight dart %}
bool isDice = controller.text == 'dice';
bool isPw = controller2.text == '1234';
{% endhighlight %}

#### TextField 외부를 터치했을 때 키보드 닫기

키보드를 닫으려면 현재 선택되어 있는 `TextField`의 focus를 해제하면 된다. 우선 터치 이벤트를 받기 위해 `SingleChildScrollView`를 `GestureDetector`로 감싼다. 그 후 `onTap` 속성에 다음과 같이 focus를 해제하는 함수를 정의한다.

{% highlight dart %}
body: GestureDetector(
  onTap: () {
    FocusScope.of(context).unfocus();
  },
  child: SingleChildScrollView(
    // ...
  ),
),
{% endhighlight %}

참고로 페이지가 켜졌을 때 특정 `TextField`를 focus된 상태로 두고 싶다면 `autofocus` 속성을 `true`로 지정하면 된다.

{% highlight dart %}
TextField(
  // ...
  autofocus: true,
),
{% endhighlight %}

## 주사위 페이지 구현하기

아래와 같은 화면을 구현할 것이다. [전체 코드](https://github.com/lklab/flutter-test/blob/master/login_dice/lib/dice.dart)

![Dice complete]({{site.baseurl}}/assets/study/flutter/014_dice_app/dice_complete.png){: width="360" .custom-align-center-img}

#### 화면에 균등하게 이미지 배치하기

`Expanded` 위젯을 사용하면 해당 위젯이 차지할 수 있는 최대한의 공간으로 위젯의 크기를 확장한다. 만약 아래와 같이 `Row` 위젯 안에 `Expanded` 위젯이 여러 개가 있는 경우 기본적으로 동일한 크기로 확장한다.

{% highlight dart %}
Row(
  children: [
    Expanded(
      child: Image.asset('image/dice$leftDice.png'),
    ),
    SizedBox(
      width: 20.0,
    ),
    Expanded(
      child: Image.asset('image/dice$rightDice.png'),
    ),
  ],
),
{% endhighlight %}

`flex` 속성을 사용해서 여러 위젯 간의 크기 비율을 지정할 수 있다.

{% highlight dart %}
Row(
  children: [
    Expanded(
      flex: 2,
      child: Image.asset('image/dice$leftDice.png'),
    ),
    SizedBox(
      width: 20.0,
    ),
    Expanded(
      flex: 1,
      child: Image.asset('image/dice$rightDice.png'),
    ),
  ],
),
{% endhighlight %}

#### 랜덤으로 이미지 바꾸기

랜덤 기능을 사용하기 위해 `dart:math` import 한다.

{% highlight dart %}
import 'dart:math';
{% endhighlight %}

버튼의 `onPressed`를 다음과 같이 구현한다.

{% highlight dart %}
onPressed: () {
  setState(() {
    leftDice = Random().nextInt(6) + 1;
    rightDice = Random().nextInt(6) + 1;
  });

  showToast('Left dice: {$leftDice}, Right dice: {$rightDice}');
},
{% endhighlight %}

참고: `showToast`

{% highlight dart %}
void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.white,
    textColor: Colors.black,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}
{% endhighlight %}
